import logging
from concurrent.futures import ThreadPoolExecutor, as_completed

import requests

from backend.shared.schemas import Agent1Output, UserPreferences
from backend.services.accommodation import search_hotels
from backend.services.activities import search_activities
from backend.services.flights import search_flights
from backend.services.travelpayouts_client import resolve_iata_code

log = logging.getLogger(__name__)


class TravelSearchAgent:
    """Agent 1 — searches flights, accommodation, and activities.

    Accepts UserPreferences and returns Agent1Output that Agent 2
    can consume directly. Runs all three searches in parallel.
    """

    def search(self, prefs: UserPreferences) -> Agent1Output:
        dest_iata = resolve_iata_code(prefs.destination)
        if not dest_iata:
            raise ValueError(
                f"Could not resolve IATA code for '{prefs.destination}'"
            )

        log.info(
            "Searching %s (%s) -> %s (%s), %s – %s",
            prefs.departure_airport,
            prefs.departure_airport,
            prefs.destination,
            dest_iata,
            prefs.start_date,
            prefs.end_date,
        )

        flights = []
        accommodations = []
        activities = []

        with ThreadPoolExecutor(max_workers=3) as pool:
            future_flights = pool.submit(
                search_flights,
                origin=prefs.departure_airport,
                destination=dest_iata,
                departure_date=str(prefs.start_date),
                return_date=str(prefs.end_date),
            )
            future_hotels = pool.submit(
                search_hotels,
                city=prefs.destination,
                check_in=str(prefs.start_date),
                check_out=str(prefs.end_date),
            )
            future_activities = pool.submit(
                search_activities,
                destination=prefs.destination,
                travel_style=prefs.travel_style.value,
            )

            try:
                flights = future_flights.result()
            except Exception as exc:
                log.warning("Flight search failed: %s", exc)

            try:
                accommodations = future_hotels.result()
            except requests.RequestException as exc:
                log.warning("Hotel search failed: %s", exc)

            try:
                activities = future_activities.result()
            except Exception as exc:
                log.warning("Activity search failed: %s", exc)

        result = Agent1Output(
            flights=flights,
            accommodations=accommodations,
            activities=activities,
        )

        log.info(
            "Agent1 result: %d flights, %d accommodations, %d activities",
            len(result.flights),
            len(result.accommodations),
            len(result.activities),
        )
        return result
