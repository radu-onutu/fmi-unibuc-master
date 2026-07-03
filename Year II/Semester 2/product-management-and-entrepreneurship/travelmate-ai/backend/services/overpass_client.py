"""
Thin client for the OpenStreetMap Overpass API.

Overpass is a public, free, rate-limited service. Responses can be slow
(several seconds) and occasionally time out under load. For a course demo
this is fine; for production it would need caching and a fallback host.
"""

import logging

import requests

OVERPASS_URL = "https://overpass-api.de/api/interpreter"
OVERPASS_TIMEOUT_SECONDS = 30

# Overpass blocks the default python-requests User-Agent (returns 406).
# Identify ourselves per OSM's API etiquette so they can contact us if the
# demo ever misbehaves.
USER_AGENT = "travelmate-ai/0.1 (https://github.com/radu-onutu-aera/travelmate-ai)"

log = logging.getLogger(__name__)


def find_hotels_near(
    lat: float,
    lon: float,
    radius_meters: int = 5000,
    limit: int = 30,
) -> list[dict]:
    """Return OSM hotel elements (nodes + ways) near (lat, lon).

    Each element has at least 'type', 'id', 'tags'. Nodes have 'lat'/'lon'
    directly; ways have 'center.lat'/'center.lon' (we request `out center`).
    """
    query = f"""
[out:json][timeout:25];
(
  node["tourism"="hotel"](around:{radius_meters},{lat},{lon});
  way["tourism"="hotel"](around:{radius_meters},{lat},{lon});
);
out center {limit};
""".strip()

    resp = requests.post(
        OVERPASS_URL,
        data={"data": query},
        headers={"User-Agent": USER_AGENT},
        timeout=OVERPASS_TIMEOUT_SECONDS,
    )
    resp.raise_for_status()
    payload = resp.json()
    elements = payload.get("elements", []) or []
    log.info("Overpass returned %d hotel elements within %dm of (%.4f, %.4f)",
             len(elements), radius_meters, lat, lon)
    return elements
