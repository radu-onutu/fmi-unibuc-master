"""
Per-country nightly-price heuristic for accommodations.

OSM/Overpass returns hotel names, locations, and stars but not prices, so
we estimate nightly EUR cost as a function of (country_code, stars). These
numbers are intentionally rough — adequate for a planning demo, not a
booking system. When a booking provider is wired in later, this module
goes away.

Picked by hand from rough European city averages mid-2024 onward; deliberately
slightly conservative (tends low) so budgets aren't overshot in the demo.
"""

# Default tier used when the destination's country isn't in the table.
# Anchored on European mid-tier cities.
DEFAULT_PRICES_EUR: dict[int, float] = {
    1: 40.0,
    2: 60.0,
    3: 90.0,
    4: 140.0,
    5: 220.0,
}

# Per-country overrides. Add entries here as the demo expands to new
# destinations. Country codes are ISO 3166-1 alpha-2 from Travelpayouts.
PRICES_BY_COUNTRY_EUR: dict[str, dict[int, float]] = {
    "PT": {1: 35.0, 2: 55.0, 3: 85.0, 4: 130.0, 5: 210.0},   # Portugal
    "ES": {1: 40.0, 2: 60.0, 3: 90.0, 4: 140.0, 5: 220.0},   # Spain
    "IT": {1: 45.0, 2: 70.0, 3: 110.0, 4: 170.0, 5: 280.0},  # Italy
    "FR": {1: 50.0, 2: 80.0, 3: 120.0, 4: 180.0, 5: 300.0},  # France
    "GB": {1: 55.0, 2: 85.0, 3: 130.0, 4: 200.0, 5: 320.0},  # UK
    "DE": {1: 45.0, 2: 70.0, 3: 105.0, 4: 160.0, 5: 250.0},  # Germany
    "NL": {1: 50.0, 2: 80.0, 3: 120.0, 4: 180.0, 5: 280.0},  # Netherlands
    "GR": {1: 35.0, 2: 55.0, 3: 80.0, 4: 130.0, 5: 220.0},   # Greece
    "RO": {1: 25.0, 2: 40.0, 3: 60.0, 4: 95.0, 5: 160.0},    # Romania
    "PL": {1: 30.0, 2: 45.0, 3: 70.0, 4: 110.0, 5: 180.0},   # Poland
    "CZ": {1: 35.0, 2: 50.0, 3: 75.0, 4: 115.0, 5: 190.0},   # Czechia
    "AT": {1: 50.0, 2: 75.0, 3: 110.0, 4: 165.0, 5: 270.0},  # Austria
}

# Used when an OSM hotel has no `stars` tag. Reasonable midpoint for a
# generic urban hotel; documented so the heuristic stays auditable.
DEFAULT_STARS_WHEN_MISSING = 3


def estimate_nightly_price_eur(country_code: str | None, stars: int | None) -> float:
    """Estimate nightly EUR price from (country_code, stars).

    Falls back to a default European tier when the country isn't tabulated,
    and to a 3-star midpoint when the OSM entry has no stars tag.
    """
    table = PRICES_BY_COUNTRY_EUR.get(country_code or "", DEFAULT_PRICES_EUR)
    effective_stars = stars if stars and 1 <= stars <= 5 else DEFAULT_STARS_WHEN_MISSING
    return table[effective_stars]
