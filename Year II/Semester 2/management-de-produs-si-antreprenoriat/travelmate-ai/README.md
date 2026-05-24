# travelmate-ai

AI-powered travel planning with two cooperating agents:
- **Agent 1 (Search)** — finds flights via Travelpayouts, hotels via OpenStreetMap Overpass, and activities via GPT (all searched in parallel)
- **Agent 2 (Planner)** — builds a day-by-day itinerary using CrewAI, with grounding checks to reject hallucinated options
- **`backend/api.py`** — FastAPI wrapper exposing the pipeline as `POST /search` (Agent 1 only) and `POST /plan` (full pipeline)

## Prerequisites

- Python 3.10–3.13 (CrewAI does not yet support 3.14)
- A Travelpayouts API token and marker (see `.env` setup below)
- An OpenAI API key (required for activity generation and Agent 2 planning)

## Setup

```bash
# 1. Clone the repo
git clone https://github.com/radu-onutu-aera/travelmate-ai.git
cd travelmate-ai

# 2. Create and activate a virtual environment
python -m venv .venv

# Windows
.\.venv\Scripts\Activate.ps1
# macOS / Linux
source .venv/bin/activate

# 3. Install dependencies
pip install -r requirements.txt

# 4. Create the .env file in the project root
cp .env.example .env
# Then fill in your credentials (see below)
```

## Environment Variables

Create a `.env` file in the project root. The orchestrator and Agent 2 load
it automatically via `python-dotenv`, so keys do not have to be exported in
your shell.

```
TRAVELPAYOUTS_API_TOKEN=<your_token>
TRAVELPAYOUTS_MARKER=<your_marker>

# Agent 2 needs ONE of these LLM keys:
OPENAI_API_KEY=sk-...           # default, used with gpt-4o-mini
ANTHROPIC_API_KEY=sk-ant-...    # set AGENT2_MODEL to a Claude model to use it
```

## Running

### API server (recommended)

```bash
uvicorn backend.api:app --reload --port 8000
```

Then open http://localhost:8000/docs for the Swagger UI, or use Postman.

### API endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/health` | Health check |
| POST | `/search` | Agent 1 only — returns flights, hotels, activities |
| POST | `/plan` | Full pipeline — Agent 1 + Agent 2, returns itinerary |
| POST | `/plan-from-search` | Agent 2 only — pass pre-fetched `/search` results to skip re-running Agent 1 |

All POST endpoints accept `UserPreferences` JSON:

```json
{
  "destination": "Lisbon",
  "start_date": "2026-06-01",
  "end_date": "2026-06-05",
  "budget_eur": 1500,
  "party_size": 2,
  "travel_style": "cultural",
  "departure_airport": "OTP"
}
```

`/plan-from-search` takes a different body — the user preferences plus the full `/search` response:

```json
{
  "prefs": {
    "destination": "Lisbon",
    "start_date": "2026-06-01",
    "end_date": "2026-06-05",
    "budget_eur": 1500,
    "party_size": 2,
    "travel_style": "cultural",
    "departure_airport": "OTP"
  },
  "search_results": {
    "flights": [ "... paste the flights array from /search response ..." ],
    "accommodations": [ "... paste the accommodations array ..." ],
    "activities": [ "... paste the activities array ..." ]
  }
}
```

This is designed for the frontend: call `/search` first, display results to the user, then pass them to `/plan-from-search` to generate the itinerary without re-running Agent 1.

### CLI (standalone)

```bash
# Full pipeline with default Lisbon trip
python -m backend.orchestrator

# Different destination (positional arg)
python -m backend.orchestrator Krakow

# Custom dates, budget, style, and origin airport
python -m backend.orchestrator Tallinn \
  --start 2026-07-10 --end 2026-07-14 \
  --budget 900 --style foodie --from OTP

# See all options
python -m backend.orchestrator --help

# Agent 2 standalone, with mock Agent 1 output (no Travelpayouts call)
python -m backend.agents.planner_agent

# REST API server (for the future frontend)
uvicorn backend.api:app --reload
# Then: curl http://127.0.0.1:8000/health
```

## Testing the pipeline

Smallest-blast-radius first; each step adds an external dependency:

```bash
# 1. Schemas only — instant, no network, no LLM
python backend/shared/schemas.py
# Expected: prints sample UserPreferences JSON

# 2. Agent 2 standalone — exercises CrewAI on hardcoded mocks
#    (~30-60s, ~1c on gpt-4o-mini)
python -m backend.agents.planner_agent
# Expected: ends with "Days planned: 4" and a validated Itinerary JSON

# 3. Full pipeline — Agent 1 (Travelpayouts + OSM + LLM activities) -> Agent 2
#    (~30-90s, ~2c on gpt-4o-mini because Agent 1 also calls the LLM)
python -m backend.orchestrator
# Expected: ends with "Agent 2 complete: N days, total estimated cost X EUR"
```

If step 3 succeeds, paste the final `Itinerary` JSON into a viewer; the
`accommodation` should be a real OSM hotel id (`osm-node-...` or
`osm-way-...`) and the `flight` id should be one of the UUIDs Agent 1
returned. The grounding check in `plan_itinerary()` rejects anything else.

## Project Structure

```
travelmate-ai/
├── backend/
│   ├── api.py                       # FastAPI app — REST endpoints for the frontend
│   ├── orchestrator.py              # Pipeline glue: Agent 1 -> Agent 2
│   ├── agents/
│   │   ├── search_agent.py          # Agent 1 — parallel flight/hotel/activity search
│   │   ├── planner_agent.py         # Agent 2 — CrewAI itinerary planner
│   │   └── _planner_mocks.py        # Mock Agent 1 output for standalone Agent 2 runs
│   ├── services/                    # Agent 1's data sources
│   │   ├── flights.py               # Travelpayouts flight search (date-filtered)
│   │   ├── accommodation.py         # OSM Overpass hotel search + heuristic pricing
│   │   ├── accommodation_pricing.py # Per-country nightly-price heuristic by stars
│   │   ├── activities.py            # GPT-generated activities + sanity filter
│   │   ├── overpass_client.py       # OpenStreetMap Overpass HTTP client
│   │   └── travelpayouts_client.py  # Travelpayouts API client + city coord resolver
│   └── shared/
│       └── schemas.py               # Pydantic models (cross-team data contracts)
├── frontend/                        # React + Vite + Tailwind UI (see frontend/README.md)
│   ├── src/
│   │   ├── api.js                   # axios client for the FastAPI backend
│   │   ├── App.jsx                  # router (landing / planner / learn)
│   │   └── pages/                   # LandingPage, PlannerPage, LearnPage
│   └── package.json
├── docs/                            # Course deliverables and pitch deck
├── .github/workflows/               # Azure Static Web Apps deploy for the frontend
├── Dockerfile                       # Backend image (Azure Container Apps target)
├── CLAUDE.md
├── .env.example
├── .python-version
├── requirements.txt
└── README.md
```

## Key Design Decisions

- **Hotels from OpenStreetMap, not a booking API.** Hotellook was shut down in October 2025. Accommodation search now queries OSM Overpass for `tourism=hotel` near the destination and applies an offline heuristic price table keyed on `(country_code, stars)`. These are planning estimates, not bookable rates.
- **Flight date filtering.** Travelpayouts returns cached fares for the whole month. Results are now filtered client-side: exact date match → ±2 days fallback → all cached options (last resort).
- **Grounding check.** After CrewAI returns an itinerary, `plan_itinerary()` verifies every flight/accommodation/activity id actually came from Agent 1's output, rejecting hallucinated options.
- **Capacity-aware prompting.** The planner pre-computes `activities / days` in Python and injects the math into the LLM prompt so it won't duplicate activities to fill slots.
- **Shared Pydantic contract.** `schemas.py` is the single source of truth. Agent 1 produces `Agent1Output`; Agent 2 consumes it and returns `Itinerary`.
- **Activities via GPT.** With no free activities API available, Agent 1 calls `gpt-4o-mini` to generate 10 real, well-known attractions per destination with coordinates, prices, and opening hours. Results are cached in-memory per `(destination, travel_style)`.
- **Parallel search.** Agent 1 runs flight, hotel, and activity searches concurrently via `ThreadPoolExecutor`, cutting search time from ~15s to ~5-8s.
- **Two-step planning.** The frontend can call `/search` (fast) to show results immediately, then `/plan-from-search` to generate the itinerary without re-running Agent 1.