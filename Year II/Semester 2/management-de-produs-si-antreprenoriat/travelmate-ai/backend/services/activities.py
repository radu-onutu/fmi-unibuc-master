import json
import logging
import math
import os
from functools import lru_cache

from openai import OpenAI

from backend.services.travelpayouts_client import resolve_city_coords
from backend.shared.schemas import ActivityOption

log = logging.getLogger(__name__)

# Number of activities to generate per destination
NUM_ACTIVITIES = 10

# Sanity-filter bounds. Activities outside these are dropped before being
# returned to Agent 2 — the LLM occasionally invents attractions in the
# wrong city or with absurd prices/durations. Keep these wide enough that
# they only catch obvious fabrications, not edge cases.
MAX_DISTANCE_FROM_CITY_KM = 50
MAX_PRICE_EUR = 500
MIN_DURATION_MINUTES = 5
MAX_DURATION_MINUTES = 600  # 10 hours


@lru_cache(maxsize=32)
def _cached_generate(destination: str, travel_style: str) -> str:
    """Call OpenAI and return the raw JSON string. Cached by (dest, style)."""
    api_key = os.getenv("OPENAI_API_KEY")
    client = OpenAI(api_key=api_key)
    response = client.chat.completions.create(
        model=os.getenv("AGENT1_MODEL", "gpt-4o-mini"),
        messages=[{"role": "user", "content": _build_prompt(destination, travel_style)}],
        temperature=0.7,
    )
    return response.choices[0].message.content.strip()


def _build_prompt(destination: str, travel_style: str) -> str:
    return f"""Generate exactly {NUM_ACTIVITIES} real tourist activities/attractions in {destination} \
suitable for a "{travel_style}" travel style.

Return a JSON array where each element has these exact fields:
- "id": a unique string like "act-1", "act-2", etc.
- "name": the real name of the place/activity
- "category": one of "museum", "restaurant", "outdoor", "tour", "nightlife", "shopping", "landmark", "other"
- "description": 1 sentence describing the activity
- "location": {{"lat": float, "lng": float}} — real coordinates
- "address": the real street address
- "price_eur": estimated entry/participation cost in EUR (0 if free)
- "duration_minutes": typical visit duration in minutes
- "rating": a realistic rating from 1.0 to 5.0
- "opening_hours": array of 7 strings (Mon-Sun), each "HH:MM-HH:MM" or null if closed that day. NEVER set the entire array to null.
- "best_time_of_day": "morning", "afternoon", or "evening"

Use real, well-known places. Return ONLY the JSON array, no markdown fences or commentary."""


def search_activities(
    destination: str,
    travel_style: str = "mixed",
) -> list[ActivityOption]:
    """Generate activities for a destination using OpenAI (cached per dest+style)."""
    api_key = os.getenv("OPENAI_API_KEY")
    if not api_key:
        log.warning("No OPENAI_API_KEY set — skipping activity generation")
        return []

    try:
        content = _cached_generate(destination, travel_style)

        # Strip markdown fences if present
        if content.startswith("```"):
            content = content.split("\n", 1)[1]
            content = content.rsplit("```", 1)[0]

        raw = json.loads(content)
        activities = []
        for item in raw:
            # GPT sometimes returns null for opening_hours; default to all-day open
            if item.get("opening_hours") is None:
                item["opening_hours"] = ["09:00-21:00"] * 7
            activities.append(ActivityOption(**item))
        log.info("Generated %d activities for %s (%s style)", len(activities), destination, travel_style)
        return _sanity_filter(activities, destination)

    except Exception as e:
        log.exception("Activity generation failed: %s", e)
        return []


def _sanity_filter(activities: list[ActivityOption], destination: str) -> list[ActivityOption]:
    """Drop obviously-fabricated activities before they reach Agent 2.

    Three checks: location is within MAX_DISTANCE_FROM_CITY_KM of the city
    center, price is within bounds, duration is within bounds. The
    location check is skipped (with a warning) if geocoding fails, so a
    network blip can't empty the list — we still return whatever the LLM
    produced rather than silently degrading the demo.
    """
    if not activities:
        return activities

    # Resolve city coords for the geo distance check. If geocoding fails or
    # the city can't be resolved, we still apply price+duration filters but
    # skip the geo check rather than empty the list.
    city_lat: float | None = None
    city_lon: float | None = None
    try:
        place = resolve_city_coords(destination)
    except Exception as exc:
        log.warning("Geocoding failed for '%s' (%s); skipping geo sanity filter", destination, exc)
        place = None
    if place is not None:
        city_lat, city_lon, _ = place

    kept: list[ActivityOption] = []
    dropped: list[tuple[str, str]] = []
    for act in activities:
        reason = _filter_reason(act, city_lat, city_lon)
        if reason is None:
            kept.append(act)
        else:
            dropped.append((act.name, reason))

    if dropped:
        log.warning(
            "Sanity filter dropped %d/%d activities for %s: %s",
            len(dropped), len(activities), destination,
            "; ".join(f"{name!r} ({reason})" for name, reason in dropped),
        )
    return kept


def _filter_reason(
    act: ActivityOption,
    city_lat: float | None,
    city_lon: float | None,
) -> str | None:
    """Return a short reason string if `act` should be dropped, else None."""
    if act.price_eur < 0 or act.price_eur > MAX_PRICE_EUR:
        return f"price {act.price_eur} EUR outside [0, {MAX_PRICE_EUR}]"
    if act.duration_minutes < MIN_DURATION_MINUTES or act.duration_minutes > MAX_DURATION_MINUTES:
        return f"duration {act.duration_minutes}min outside [{MIN_DURATION_MINUTES}, {MAX_DURATION_MINUTES}]"
    if city_lat is not None and city_lon is not None:
        dist_km = _haversine_km(city_lat, city_lon, act.location.lat, act.location.lng)
        if dist_km > MAX_DISTANCE_FROM_CITY_KM:
            return f"{dist_km:.1f}km from city center (max {MAX_DISTANCE_FROM_CITY_KM})"
    return None


def _haversine_km(lat1: float, lon1: float, lat2: float, lon2: float) -> float:
    """Great-circle distance in kilometers between two GPS coordinates."""
    R = 6371.0
    p1, p2 = math.radians(lat1), math.radians(lat2)
    dlat = math.radians(lat2 - lat1)
    dlon = math.radians(lon2 - lon1)
    a = math.sin(dlat / 2) ** 2 + math.cos(p1) * math.cos(p2) * math.sin(dlon / 2) ** 2
    return 2 * R * math.asin(math.sqrt(a))
