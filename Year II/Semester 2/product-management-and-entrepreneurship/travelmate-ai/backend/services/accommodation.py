"""
Hotel search via OpenStreetMap Overpass + a per-country price heuristic.

Travelpayouts shut down Hotellook in October 2025, so this module no
longer hits a booking provider. It pulls real hotel names, addresses and
coordinates from OSM, and estimates nightly prices from (country, stars)
in accommodation_pricing. Prices are placeholders, not bookable rates —
swap in a real provider when one is available.
"""

import logging
from uuid import uuid4

from backend.shared.schemas import AccommodationOption, GeoPoint
from backend.services.accommodation_pricing import estimate_nightly_price_eur
from backend.services.overpass_client import find_hotels_near
from backend.services.travelpayouts_client import resolve_city_coords

log = logging.getLogger(__name__)


def search_hotels(
    city: str,
    check_in: str,
    check_out: str,
    currency: str = "eur",
    limit: int = 10,
) -> list[AccommodationOption]:
    """Find hotels near `city` from OSM, with heuristic nightly prices.

    `check_in`/`check_out`/`currency` are accepted for interface
    compatibility with the previous Hotellook implementation but are not
    used: OSM has no real-time pricing or availability.
    """
    place = resolve_city_coords(city)
    if place is None:
        log.warning("Could not resolve coords for '%s'; no hotels returned", city)
        return []
    lat, lon, country_code = place

    elements = find_hotels_near(lat, lon, radius_meters=5000, limit=30)

    hotels: list[AccommodationOption] = []
    for el in elements:
        hotel = _osm_to_accommodation(el, country_code)
        if hotel is not None:
            hotels.append(hotel)
        if len(hotels) >= limit:
            break

    log.info("Built %d accommodation options for %s (%s)", len(hotels), city, country_code)
    return hotels


def _osm_to_accommodation(element: dict, country_code: str) -> AccommodationOption | None:
    """Map a single OSM element to an AccommodationOption, or None to skip."""
    tags = element.get("tags") or {}
    name = tags.get("name")
    if not name:
        # Skip hotels with no name — useless in the demo UI.
        return None

    # Nodes carry lat/lon directly; ways/relations carry it under `center`.
    lat = element.get("lat")
    lon = element.get("lon")
    if lat is None or lon is None:
        center = element.get("center") or {}
        lat = center.get("lat")
        lon = center.get("lon")
    if lat is None or lon is None:
        return None

    stars = _parse_stars(tags.get("stars"))
    price = estimate_nightly_price_eur(country_code, stars)
    rating = float(stars) if stars is not None else 3.0

    return AccommodationOption(
        id=f"osm-{element['type']}-{element['id']}",
        name=name,
        type=_infer_type_from_stars(stars),
        location=GeoPoint(lat=float(lat), lng=float(lon)),
        address=_build_address(tags) or name,
        price_per_night_eur=price,
        rating=rating,
        amenities=_extract_amenities(tags),
    )


def _parse_stars(value: str | None) -> int | None:
    if not value:
        return None
    try:
        n = int(str(value).strip()[0])
    except (ValueError, IndexError):
        return None
    return n if 1 <= n <= 5 else None


def _infer_type_from_stars(stars: int | None) -> str:
    if stars is None:
        return "hotel"
    if stars >= 3:
        return "hotel"
    if stars >= 1:
        return "hostel"
    return "apartment"


def _build_address(tags: dict) -> str:
    parts: list[str] = []
    street = tags.get("addr:street")
    number = tags.get("addr:housenumber")
    city = tags.get("addr:city")
    postcode = tags.get("addr:postcode")
    if street:
        parts.append(f"{street} {number}".strip() if number else street)
    if postcode and city:
        parts.append(f"{postcode} {city}")
    elif city:
        parts.append(city)
    return ", ".join(parts)


# OSM tags worth surfacing as amenities. The values are mostly free-form,
# so we just record the tag's presence rather than its exact value.
_AMENITY_TAGS = {
    "internet_access": "wifi",
    "wheelchair": "wheelchair_access",
    "breakfast": "breakfast",
    "swimming_pool": "pool",
    "air_conditioning": "air_conditioning",
}


def _extract_amenities(tags: dict) -> list[str]:
    out: list[str] = []
    for tag, label in _AMENITY_TAGS.items():
        value = tags.get(tag)
        if value and value not in ("no", "none"):
            out.append(label)
    return out
