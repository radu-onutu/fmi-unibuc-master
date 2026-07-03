"""
TravelMate AI — Orchestrator

Ties together Agent 1 (search) and Agent 2 (itinerary planner).
Agent 1 searches flights via Travelpayouts and hotels via OSM Overpass.
Agent 2 uses CrewAI to build a day-by-day itinerary from those results.
"""

import argparse
import logging
import os
from datetime import date

from dotenv import load_dotenv

from backend.agents.search_agent import TravelSearchAgent
from backend.shared.schemas import (
    Agent1Output,
    Itinerary,
    TravelStyle,
    UserPreferences,
)

load_dotenv()

logging.basicConfig(level=logging.INFO, format="%(name)s | %(message)s")
log = logging.getLogger(__name__)


def run_agent1(prefs: UserPreferences) -> Agent1Output:
    """Run Agent 1 — search flights, accommodation, and activities."""
    agent = TravelSearchAgent()
    return agent.search(prefs)


def run_agent2(prefs: UserPreferences, search_results: Agent1Output) -> Itinerary:
    """Run Agent 2 — build a day-by-day itinerary from Agent 1's results."""
    from backend.agents.planner_agent import plan_itinerary
    return plan_itinerary(prefs, search_results)


def run_pipeline(prefs: UserPreferences) -> Itinerary | Agent1Output:
    """Run the full pipeline: Agent 1 search, then Agent 2 itinerary planning.

    Returns the Agent 1 output (instead of an Itinerary) when:
      - no LLM key is set (OPENAI_API_KEY / ANTHROPIC_API_KEY), or
      - Agent 1 returned no flights — without a flight there's nothing for
        Agent 2 to plan around, and we'd rather skip the LLM call than
        produce a flightless itinerary.
    """
    log.info("Starting pipeline for %s (%s – %s)", prefs.destination, prefs.start_date, prefs.end_date)

    search_results = run_agent1(prefs)
    log.info(
        "Agent 1 complete: %d flights, %d accommodations, %d activities",
        len(search_results.flights),
        len(search_results.accommodations),
        len(search_results.activities),
    )

    if not (os.getenv("OPENAI_API_KEY") or os.getenv("ANTHROPIC_API_KEY")):
        log.warning("No LLM key set — skipping Agent 2. Set OPENAI_API_KEY or ANTHROPIC_API_KEY to plan an itinerary.")
        return search_results

    if not search_results.flights:
        log.warning(
            "No flights found from %s to %s — skipping Agent 2. "
            "Try different dates or a nearby airport.",
            prefs.departure_airport, prefs.destination,
        )
        return search_results

    itinerary = run_agent2(prefs, search_results)
    log.info(
        "Agent 2 complete: %d days, total estimated cost %.2f EUR",
        len(itinerary.days),
        itinerary.trip_summary.total_estimated_cost_eur,
    )
    return itinerary


def _parse_args(argv: list[str] | None = None) -> UserPreferences:
    """Build UserPreferences from CLI args, with Lisbon defaults for a no-arg run."""
    parser = argparse.ArgumentParser(
        prog="python -m backend.orchestrator",
        description="Run the TravelMate AI pipeline (Agent 1 search -> Agent 2 itinerary).",
    )
    parser.add_argument("destination", nargs="?", default="Lisbon",
                        help="Destination city name. Defaults to Lisbon.")
    parser.add_argument("--start", type=date.fromisoformat, default=date(2026, 6, 1),
                        help="Trip start date as YYYY-MM-DD. Default 2026-06-01.")
    parser.add_argument("--end", type=date.fromisoformat, default=date(2026, 6, 5),
                        help="Trip end date as YYYY-MM-DD. Default 2026-06-05.")
    parser.add_argument("--budget", type=float, default=1500.0,
                        help="Budget in EUR. Default 1500.")
    parser.add_argument("--party-size", type=int, default=2,
                        help="Number of travelers. Default 2.")
    parser.add_argument("--style", type=TravelStyle, default=TravelStyle.CULTURAL,
                        choices=list(TravelStyle),
                        metavar="{" + ",".join(s.value for s in TravelStyle) + "}",
                        help="Travel style. Default cultural.")
    parser.add_argument("--from", dest="departure_airport", default="OTP",
                        help="Departure airport IATA code. Default OTP (Bucharest).")
    args = parser.parse_args(argv)
    return UserPreferences(
        destination=args.destination,
        start_date=args.start,
        end_date=args.end,
        budget_eur=args.budget,
        party_size=args.party_size,
        travel_style=args.style,
        departure_airport=args.departure_airport,
    )


def main(argv: list[str] | None = None):
    prefs = _parse_args(argv)
    result = run_pipeline(prefs)
    print(result.model_dump_json(indent=2))


if __name__ == "__main__":
    main()
