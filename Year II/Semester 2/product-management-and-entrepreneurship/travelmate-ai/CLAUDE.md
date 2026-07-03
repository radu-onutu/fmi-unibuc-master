# CLAUDE.md

This file gives Claude Code the context it needs to work in this repo. Keep it short — if something here can be inferred from the code, delete it.

## Project state (2026-05-04)

End-to-end pipeline works and is deployed:
- Backend → Azure Container Apps (`travelmate-api`); image in ACR `travelmateacr9643`
- Frontend → Azure Static Web Apps; auto-deploys from `main`

The API exposes three endpoints (`backend/api.py`): `/search` (Agent 1 only),
`/plan` (full pipeline), and `/plan-from-search` (Agent 2 only, takes pre-fetched
Agent 1 output). The frontend uses the two-step flow: `/search` first to show
results, then `/plan-from-search` so Agent 1 doesn't re-run.

Agent 1 runs flight, hotel, and activity searches in parallel via
`ThreadPoolExecutor` (~5–8s vs ~15s sequential). Activities come from a
`gpt-4o-mini` call with a `_sanity_filter` that drops fabrications outside
`MAX_DISTANCE_FROM_CITY_KM` of the destination. Architectural rules below are
authoritative; consult them before changing schemas or the planner prompt.

## Project

**TravelMate AI** — a startup-style university project for the MPA 2026 course at the University of Bucharest. It plans trips end-to-end using two cooperating agents:

- **Agent 1 (Search)** — fetches flights via Travelpayouts, hotels via OpenStreetMap Overpass, and activities via a `gpt-4o-mini` call.
- **Agent 2 (Planner)** — uses CrewAI to turn Agent 1's results into a day-by-day itinerary.

The two agents communicate via shared Pydantic schemas. They do **not** call each other directly; the orchestrator (or `backend/api.py`) runs them in sequence.

## Stack

- Python 3.10–3.13 (CrewAI does not yet support 3.14)
- Pydantic v2 — `backend/shared/schemas.py` is the single source of truth for all data contracts
- CrewAI — Agent 2's framework
- `requests` + Travelpayouts (flights) + OSM Overpass (hotels) — Agent 1's data sources
- `openai` SDK — used directly by `services/activities.py` to generate activity options for Agent 1
- FastAPI + Uvicorn — REST API in `backend/api.py` (for the future frontend)
- LLM: defaults to OpenAI `gpt-4o-mini` via the `OPENAI_API_KEY` env var; Agent 2's model is switchable via `AGENT2_MODEL`, Agent 1's via `AGENT1_MODEL`

## Repo layout

```
backend/
├── orchestrator.py          # CLI entry point — Agent 1 -> Agent 2 chain
├── api.py                   # FastAPI app: /search, /plan, /plan-from-search (Cristina)
├── agents/
│   ├── search_agent.py      # Agent 1 (Cristina) — parallel flight/hotel/activity search
│   ├── planner_agent.py     # Agent 2 (Radu) — runnable standalone with mock data
│   └── _planner_mocks.py    # mock Agent 1 output for the standalone Agent 2 run
├── services/                # Agent 1's data sources (Cristina)
│   ├── flights.py           # Travelpayouts flight search (date-filtered)
│   ├── accommodation.py     # OSM Overpass hotel search + heuristic pricing
│   ├── accommodation_pricing.py  # per-country nightly-price heuristic
│   ├── activities.py        # gpt-4o-mini activity generator + sanity filter
│   ├── overpass_client.py   # OpenStreetMap Overpass HTTP client
│   └── travelpayouts_client.py
└── shared/
    └── schemas.py           # ALL data contracts live here (cross-team)

frontend/                    # React + Vite + Tailwind (Denisa)
├── src/
│   ├── api.js               # axios client for the FastAPI backend
│   ├── App.jsx              # router (landing / planner / learn)
│   └── pages/               # LandingPage, PlannerPage, LearnPage
└── package.json

docs/                        # course deliverables, pitch deck
.github/workflows/           # Static Web Apps deployment for the frontend
Dockerfile                   # backend image (Container Apps target)
```

## Team and ownership

Edit files in your own area; coordinate before touching shared code.

| Person | Role | Owns |
|---|---|---|
| Adina | Product Owner / Business Lead | Business Foundation doc, Lean Canvas, pitch narrative |
| Cristina | AI/Backend — Agent 1 + API | `backend/agents/search_agent.py`, `backend/services/*`, `backend/api.py` |
| Radu | AI/Backend — Agent 2 | `backend/agents/planner_agent.py`, orchestration glue |
| Denisa | Frontend | `frontend/` — React + Vite + Tailwind (landing, planner, learn pages) |
| Melania | Project Manager / Pitch Lead | Gantt, integration, presentation |

`backend/shared/schemas.py` is **shared** — changes here can break both agents and the (future) frontend. Discuss before modifying.

## Architectural rules Claude must respect

1. **The schemas in `backend/shared/schemas.py` are the contract between agents.** Never change a field name, type, or remove a field without updating both `search_agent.py` (Agent 1's producer side) and `planner_agent.py` (Agent 2's consumer side) in the same change. As of 2026-04-28, both `Itinerary.flight` and `Itinerary.accommodation` are `Optional` — frontend renderers must handle `null` for either. The orchestrator bails to the Agent 1 output before calling Agent 2 if no flights are returned, so a flightless `Itinerary` should be rare in practice but is schema-permitted.

2. **Agent 1 returns `Agent1Output`. Agent 2 returns `Itinerary`.** Both are Pydantic models. CrewAI uses `output_pydantic=Itinerary` to force the LLM into the right shape — preserve this pattern.

3. **Times in `TimeSlot.start_time` / `end_time` are `"HH:MM"` strings, not `datetime.time` objects.** This is intentional: CrewAI's internal JSON logger cannot serialize `time`. Keep it as strings with the `TIME_HHMM_PATTERN` regex validator.

4. **`Itinerary` has a `@model_validator` that rejects duplicate activity_ids.** If a CrewAI run fails this validator, the fix is in the prompt (`build_planning_task` in `planner_agent.py`), not the validator.

5. **Pre-compute deterministic facts in Python and inject them into the LLM prompt.** Example: weekday lookups and per-date activity availability tables are built in Python and pasted into the task description. Do not ask the LLM to do work that Python can do correctly for free. This is the project's main reliability pattern.

6. **`backend/services/activities.py` generates activities with a separate `gpt-4o-mini` call (Cristina's design, commit `6026d5e0`).** It returns `[]` on missing key or LLM error, so Agent 2 must still handle empty lists gracefully. The activities are LLM-hallucinated (real-sounding names, plausibly-wrong addresses) — same hallucination tradeoff we deliberately avoided for hotel pricing. A `_sanity_filter` runs after generation to drop fabrications outside `MAX_DISTANCE_FROM_CITY_KM` of the destination, with absurd prices, or with implausible durations. The filter degrades gracefully if geocoding fails. Tune the bounds at the top of the file if the demo expands to new edge cases.

7. **Hotels come from OpenStreetMap Overpass, not a booking provider.** Travelpayouts shut down Hotellook in October 2025. `accommodation.py` queries OSM for `tourism=hotel` near the destination's coords; nightly prices are an offline heuristic in `accommodation_pricing.py` keyed on `(country_code, stars)`. These are placeholder estimates, not bookable rates. When a real provider is integrated, the heuristic module goes away — keep the `AccommodationOption` shape intact so the swap is local.

## Setup

> ⚠️ **PYTHON VERSION GOTCHA — ALWAYS REMIND RADU.** When Radu asks how to run the app (backend, orchestrator, full pipeline, anything that hits `pip install -r requirements.txt`), **explicitly call out the Python version requirement before giving run instructions.** His system Python is 3.9, and `.venv` has been recreated on 3.9 by accident before — `pip install -r requirements.txt` then fails with `Could not find a version that satisfies the requirement crewai>=0.80.0` (and a wall of "Requires-Python" rejections). CrewAI needs **Python 3.10–3.13**. If `.venv` is already on 3.9, the fix is to recreate it: `deactivate && rm -rf .venv && python3.12 -m venv .venv && source .venv/bin/activate && pip install -r requirements.txt`. Verify with `python --version` after activating.

```bash
python3.12 -m venv .venv           # MUST be 3.10–3.13, not system 3.9
source .venv/bin/activate          # Windows: .\.venv\Scripts\Activate.ps1
python --version                   # confirm 3.10–3.13 before installing
pip install -r requirements.txt
cp .env.example .env               # then fill in the keys
```

The orchestrator and `api.py` call `load_dotenv()` at startup, so all keys
(`TRAVELPAYOUTS_API_TOKEN`, `TRAVELPAYOUTS_MARKER`, `OPENAI_API_KEY` /
`ANTHROPIC_API_KEY`) live in `.env`. No shell `export` needed.

## Running

```bash
# Full pipeline as a one-shot CLI run (Agent 1 search -> Agent 2 itinerary)
python -m backend.orchestrator

# Agent 2 standalone, with mock Agent 1 output (no Travelpayouts/OSM call)
python -m backend.agents.planner_agent

# REST API server (used by the future frontend)
uvicorn backend.api:app --reload
```

## Verification before committing

There's no formal test suite yet. At minimum, before a commit that touches code:

```bash
python backend/shared/schemas.py        # smoke test — must print sample JSON
python -m backend.orchestrator          # if you touched Agent 1 or services/
python -m backend.agents.planner_agent  # if you touched Agent 2 or schemas
```

The full-pipeline run is the most thorough check — it exercises Travelpayouts (flights), OSM Overpass (hotels), Cristina's activity generator, the orchestrator chain, the prompt, the duplicate-id validator, and the post-CrewAI grounding check. ~30-90s and ~2¢ on `gpt-4o-mini`.

## Azure deployment

The app is split across two Azure services in resource group `travelmate-rg`:

- **Backend API** → Container Apps (`travelmate-api`) in a Container Apps Environment, image hosted in ACR `travelmateacr9643.azurecr.io`. Logs go to a Log Analytics workspace.
- **Frontend** → Static Web Apps. Deploys automatically via `.github/workflows/azure-static-web-apps.yml` on push to `main`. No manual command — push the frontend change and the workflow ships it.

### Pushing a backend change

**Backend deploys are manual — no GitHub Actions workflow.** Radu deploys from his laptop every time. Build for `linux/amd64` (his Mac is arm64; without the flag the image crashes in Azure with `exec format error`). Bump the tag every deploy — Container Apps may not pull a new revision if you reuse a tag.

```bash
docker build --platform linux/amd64 -t travelmateacr9643.azurecr.io/travelmate-api:vN .
az acr login --name travelmateacr9643
docker push travelmateacr9643.azurecr.io/travelmate-api:vN
az containerapp update -g travelmate-rg -n travelmate-api \
  --image travelmateacr9643.azurecr.io/travelmate-api:vN
```

When Radu asks "how do I push my changes" or "how do I deploy": ask whether the change is backend or frontend. Backend → the four commands above. Frontend → `git push` to `main` and the Static Web Apps workflow handles it.

## Things to leave alone unless explicitly asked

- `.env` and any real API keys — never commit, never echo to terminal output
- `backend/shared/schemas.py` — don't refactor the field shapes; this is a cross-team contract
- The CrewAI version pin in `requirements.txt` — `output_pydantic` behavior varies between versions

## Course context (in case it matters for a decision)

This is an academic deliverable, not a product. Optimize for: a coherent demo, readable code, and material that can be explained in a 10-minute pitch. Avoid over-engineering — no microservices, no Kubernetes, no abstract base classes "for future flexibility". The grade rubric weights MVP at 4/10 points, so the bar is "works in a live demo", not "production-ready".
