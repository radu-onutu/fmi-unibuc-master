import os
import logging

import requests
from dotenv import load_dotenv

load_dotenv()

API_TOKEN = os.getenv("TRAVELPAYOUTS_API_TOKEN")
MARKER = os.getenv("TRAVELPAYOUTS_MARKER")

FLIGHT_BASE_URL = "https://api.travelpayouts.com"

log = logging.getLogger(__name__)


def flight_get(endpoint: str, params: dict) -> dict:
    params["token"] = API_TOKEN
    params["marker"] = MARKER
    url = f"{FLIGHT_BASE_URL}{endpoint}"
    log.debug("GET %s", url)
    resp = requests.get(url, params=params, timeout=15)
    resp.raise_for_status()
    return resp.json()


def resolve_iata_code(city_name: str) -> str | None:
    """Resolve a city name to its IATA code via Travelpayouts autocomplete."""
    place = _resolve_place(city_name)
    return place.get("code") if place else None


def resolve_city_coords(city_name: str) -> tuple[float, float, str] | None:
    """Resolve a city name to (lat, lon, country_code) via the same autocomplete.

    Returns None if the city can't be resolved. Country code is ISO 3166-1
    alpha-2 (e.g. 'PT' for Portugal); used by the accommodation pricing
    heuristic to pick a per-country nightly price band.
    """
    place = _resolve_place(city_name)
    if not place:
        return None
    coords = place.get("coordinates") or {}
    lat = coords.get("lat")
    lon = coords.get("lon")
    cc = place.get("country_code")
    if lat is None or lon is None or not cc:
        return None
    return float(lat), float(lon), cc


def _resolve_place(city_name: str) -> dict | None:
    resp = requests.get(
        "https://autocomplete.travelpayouts.com/places2",
        params={"term": city_name, "locale": "en", "types[]": "city"},
        timeout=10,
    )
    resp.raise_for_status()
    results = resp.json()
    return results[0] if results else None
