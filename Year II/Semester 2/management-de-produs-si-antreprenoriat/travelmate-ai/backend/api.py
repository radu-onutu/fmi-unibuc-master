"""
TravelMate AI — FastAPI application.

Exposes the orchestrator pipeline as a REST API for the frontend.

Run with:
    uvicorn backend.api:app --reload
"""

import logging
import os

from dotenv import load_dotenv
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel

load_dotenv()

from backend.orchestrator import run_agent1, run_agent2
from backend.shared.schemas import Agent1Output, Itinerary, UserPreferences


class PlanFromSearchRequest(BaseModel):
    """Accept pre-fetched search results so Agent 1 doesn't re-run."""
    prefs: UserPreferences
    search_results: Agent1Output

logging.basicConfig(level=logging.INFO, format="%(name)s | %(message)s")
log = logging.getLogger(__name__)

app = FastAPI(
    title="TravelMate AI",
    description="AI-powered trip planner — search flights/hotels and generate day-by-day itineraries.",
    version="0.1.0",
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # tighten in production
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.get("/health")
def health():
    """Health check endpoint."""
    return {"status": "ok"}


@app.post("/search", response_model=Agent1Output)
def search(prefs: UserPreferences):
    """Run Agent 1 only — returns flights, accommodations, and activities."""
    try:
        return run_agent1(prefs)
    except ValueError as e:
        raise HTTPException(status_code=422, detail=str(e))
    except Exception as e:
        log.exception("Agent 1 failed")
        raise HTTPException(status_code=500, detail="Search failed. Please try again.")


@app.post("/plan", response_model=Itinerary)
def plan(prefs: UserPreferences):
    """Run the full pipeline: Agent 1 search, then Agent 2 itinerary planning.

    Requires OPENAI_API_KEY or ANTHROPIC_API_KEY to be set.
    """
    if not (os.getenv("OPENAI_API_KEY") or os.getenv("ANTHROPIC_API_KEY")):
        raise HTTPException(
            status_code=503,
            detail="No LLM key configured. Set OPENAI_API_KEY or ANTHROPIC_API_KEY.",
        )

    try:
        search_results = run_agent1(prefs)
    except ValueError as e:
        raise HTTPException(status_code=422, detail=str(e))
    except Exception as e:
        log.exception("Agent 1 failed")
        raise HTTPException(status_code=500, detail="Search failed. Please try again.")

    if not search_results.flights:
        raise HTTPException(
            status_code=404,
            detail=f"No flights found from {prefs.departure_airport} to {prefs.destination}. Try different dates or a nearby airport.",
        )

    try:
        return run_agent2(prefs, search_results)
    except Exception as e:
        log.exception("Agent 2 failed")
        raise HTTPException(status_code=500, detail="Itinerary planning failed. Please try again.")


@app.post("/plan-from-search", response_model=Itinerary)
def plan_from_search(body: PlanFromSearchRequest):
    """Run Agent 2 only, using pre-fetched Agent 1 results.

    Use this after calling /search: pass the search results directly
    so Agent 1 doesn't re-run. Much faster than /plan.
    """
    if not (os.getenv("OPENAI_API_KEY") or os.getenv("ANTHROPIC_API_KEY")):
        raise HTTPException(
            status_code=503,
            detail="No LLM key configured. Set OPENAI_API_KEY or ANTHROPIC_API_KEY.",
        )

    if not body.search_results.flights:
        raise HTTPException(status_code=404, detail="No flights in search results.")

    try:
        return run_agent2(body.prefs, body.search_results)
    except Exception as e:
        log.exception("Agent 2 failed")
        raise HTTPException(status_code=500, detail="Itinerary planning failed. Please try again.")
