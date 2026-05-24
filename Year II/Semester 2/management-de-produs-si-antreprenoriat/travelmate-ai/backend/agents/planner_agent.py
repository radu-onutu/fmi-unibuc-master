"""
TravelMate AI — Agent 2 (Itinerary Planner)

CrewAI agent that turns Agent 1's `Agent1Output` into a validated
`Itinerary`. Public entry point is `plan_itinerary(prefs, options)`,
called by the orchestrator. Running this module directly executes
`run()`, which exercises the same path against mock Agent 1 output
from `_planner_mocks.py`.

LLM keys come from `.env` via `python-dotenv` (see orchestrator).
Switch the planner's model with `AGENT2_MODEL`:
    AGENT2_MODEL=gpt-4o-mini                              (default)
    AGENT2_MODEL=gpt-4.1-mini                             (better instructions)
    AGENT2_MODEL=anthropic/claude-haiku-4-5-20251001
    AGENT2_MODEL=anthropic/claude-sonnet-4-6              (smartest sweet spot)
"""

import math
import os
from datetime import date, timedelta

from dotenv import load_dotenv

load_dotenv()

from crewai import Agent, Crew, Task, LLM
from crewai.tools import tool

from backend.shared.schemas import Agent1Output, Itinerary, UserPreferences


# =============================================================================
# Tools — Python functions the agent can call when reasoning
# =============================================================================

@tool("Calculate travel time between two GPS coordinates")
def calculate_travel_time(
    from_lat: float, from_lng: float,
    to_lat: float, to_lng: float,
    mode: str,
) -> str:
    """
    Estimate travel time and cost between two GPS points using the haversine
    formula and average urban speeds.

    Args:
        from_lat, from_lng: starting coordinates (decimal degrees)
        to_lat, to_lng:     destination coordinates (decimal degrees)
        mode:               'walk', 'metro', 'bus', or 'taxi'

    Returns:
        JSON string: {"duration_minutes": N, "estimated_cost_eur": X, "distance_km": Y, "mode": "..."}
    """
    R = 6371.0
    lat1, lng1 = math.radians(from_lat), math.radians(from_lng)
    lat2, lng2 = math.radians(to_lat), math.radians(to_lng)
    dlat, dlng = lat2 - lat1, lng2 - lng1
    a = math.sin(dlat / 2) ** 2 + math.cos(lat1) * math.cos(lat2) * math.sin(dlng / 2) ** 2
    distance_km = 2 * R * math.asin(math.sqrt(a))

    speeds = {"walk": 5.0, "metro": 25.0, "bus": 18.0, "taxi": 22.0}
    rates = {"walk": 0.0, "metro": 0.5, "bus": 0.3, "taxi": 1.5}
    floors = {"walk": 0.0, "metro": 1.50, "bus": 1.50, "taxi": 4.00}

    mode = mode.lower()
    if mode not in speeds:
        mode = "walk"

    duration_minutes = max(int((distance_km / speeds[mode]) * 60), 1)
    cost = max(round(distance_km * rates[mode], 2), floors[mode])

    return (
        f'{{"duration_minutes": {duration_minutes}, '
        f'"estimated_cost_eur": {cost}, '
        f'"distance_km": {round(distance_km, 2)}, '
        f'"mode": "{mode}"}}'
    )


# =============================================================================
# Helpers — pre-compute deterministic facts so the LLM never has to
# =============================================================================

WEEKDAY_NAMES = ["Monday", "Tuesday", "Wednesday", "Thursday",
                 "Friday", "Saturday", "Sunday"]


def _trip_dates(prefs: UserPreferences) -> list[date]:
    out: list[date] = []
    d = prefs.start_date
    while d <= prefs.end_date:
        out.append(d)
        d += timedelta(days=1)
    return out


def _build_date_table(dates: list[date]) -> str:
    return "\n".join(
        f"  - {d.isoformat()} ({WEEKDAY_NAMES[d.weekday()]})"
        for d in dates
    )


def _build_availability_table(dates: list[date], options: Agent1Output) -> str:
    """For each activity, show which trip dates it's open vs closed on."""
    lines: list[str] = []
    for act in options.activities:
        open_strs: list[str] = []
        closed_strs: list[str] = []
        for d in dates:
            wd = d.weekday()
            if act.opening_hours[wd] is None:
                closed_strs.append(d.isoformat())
            else:
                open_strs.append(f"{d.isoformat()} ({act.opening_hours[wd]})")
        lines.append(
            f"  - {act.id} \"{act.name}\":\n"
            f"      OPEN on   [{', '.join(open_strs) or 'NONE'}]\n"
            f"      CLOSED on [{', '.join(closed_strs) or 'NONE'}]"
        )
    return "\n".join(lines)


# =============================================================================
# Agent + LLM
# =============================================================================

llm = LLM(
    model=os.getenv("AGENT2_MODEL", "gpt-4o-mini"),
    temperature=0.3,
)

itinerary_planner = Agent(
    role="Travel itinerary planner",
    goal=(
        "Build a realistic, day-by-day itinerary that respects the user's "
        "budget, travel style, opening hours, and geographic logic."
    ),
    backstory=(
        "You are a meticulous trip planner. A great itinerary is not just a "
        "list of attractions — it is a sequence that flows geographically, "
        "respects opening hours, allows time for meals and transit, and "
        "never overloads any single day. You always check travel time "
        "between consecutive activities and verify the running cost."
    ),
    tools=[calculate_travel_time],
    llm=llm,
    verbose=os.getenv("AGENT2_VERBOSE", "0") == "1",
    allow_delegation=False,
    max_iter=8,
)


# =============================================================================
# Task builder — now with pre-computed availability table
# =============================================================================

def build_planning_task(prefs: UserPreferences, options: Agent1Output) -> Task:
    dates = _trip_dates(prefs)
    date_table = _build_date_table(dates)
    availability_table = _build_availability_table(dates, options)

    prefs_json = prefs.model_dump_json(indent=2)
    options_json = options.model_dump_json(indent=2)

    num_activities = len(options.activities)
    num_days = len(dates)
    avg_per_day = num_activities / num_days if num_days else 0
    capacity_note = (
        f"You have {num_activities} unique activities for {num_days} days "
        f"(~{avg_per_day:.1f} per day on average). Some day-slots will be "
        f"empty (set to null) — that is correct. Do NOT pad by repeating an "
        f"activity. The Pydantic validator rejects any duplicate activity_id."
    )

    activity_ids = [a.id for a in options.activities]
    activity_id_checklist = "\n".join(f"  [ ] {aid}" for aid in activity_ids)
    used_pool_note = (
        f"BEFORE writing each TimeSlot, mentally tick off the activity_id from "
        f"this checklist. Once ticked, that id is GONE — never reuse it, even "
        f"if it seems like the only option for a slot. Leaving a slot null is "
        f"ALWAYS preferred over reusing an id.\n\n"
        f"ACTIVITY_ID CHECKLIST (each may be used at most once):\n"
        f"{activity_id_checklist}"
    )

    description = f"""
Plan a complete day-by-day itinerary for the user's trip.

USER PREFERENCES:
{prefs_json}

AVAILABLE OPTIONS (from Agent 1):
{options_json}

TRIP DATES (pre-computed — trust these):
{date_table}

ACTIVITY AVAILABILITY (pre-computed — trust these, do NOT recompute):
{availability_table}

CRITICAL CONSTRAINTS (read before anything else):
- GROUNDING: the chosen flight, accommodation, and every activity_id MUST
  come from AVAILABLE OPTIONS above. Use the exact ids verbatim. Do NOT
  invent fields, ids, names, or addresses. If AVAILABLE OPTIONS has no
  accommodations, set accommodation to null. If it has no activities,
  every TimeSlot is null. The post-CrewAI grounding check rejects any
  invented id and the run will fail.
- ACTIVITY FIELD CONSISTENCY: when you place an activity in a TimeSlot,
  copy its `name` into `activity_name` and its `address` into `address`
  VERBATIM from the matching id in AVAILABLE OPTIONS. Do NOT mix id from
  one activity with name/address from another.
- UNIQUENESS: every activity_id appears AT MOST ONCE across the entire
  days[] list. No exceptions. The Pydantic validator hard-fails duplicates.
- CAPACITY: {capacity_note}
- Empty TimeSlots are allowed: set morning/afternoon/evening to null when
  no suitable activity remains. A short, valid itinerary beats a padded,
  invalid one.

{used_pool_note}

WORKED EXAMPLE of the uniqueness rule (read carefully):
  Suppose only ONE activity has evening hours (e.g. a Fado show, 19:00-20:30).
  CORRECT behavior: place it in evening on Day 1 only. Days 2-N evening = null.
  WRONG behavior: place the same activity_id on Day 1 evening AND Day 2 evening
  "because nothing else fits the evening slot." This will hard-fail the run.
  The validator does not care that the slot would otherwise be empty —
  empty is correct, duplicate is fatal.

PLANNING RULES:

1. Pick exactly ONE flight from AVAILABLE OPTIONS that fits the budget.
   Pick ONE accommodation from AVAILABLE OPTIONS, or null if the
   accommodations list is empty. Prefer higher-rated options when prices
   are similar.

2. Schedule UP TO 3 activities per day (morning, afternoon, optionally
   evening). Fewer is fine. If you have already used every unique activity,
   leave the remaining slots null — do NOT reuse one to fill a slot.

3. UNIQUENESS (repeat from prelude): each activity_id appears at most once
   across all days. The validator will reject duplicates and the run will
   fail. Track which activity_ids you have already placed before adding a
   new TimeSlot.

4. AVAILABILITY: Use the ACTIVITY AVAILABILITY table above. NEVER schedule
   an activity on a date listed in its CLOSED set. Look up each activity
   in the table before placing it.

5. DAY-PART TIME WINDOWS — every TimeSlot's start_time and end_time must
   fit inside its slot's window:
       morning:   09:00 - 12:00
       afternoon: 13:00 - 17:30
       evening:   18:00 - 22:00
   If an activity would naturally fall outside its window, move it to the
   correct slot or pick a different activity.

6. Cluster geographically: activities on the same day should be near each
   other. Use calculate_travel_time to verify travel between consecutive
   activities is reasonable (under 30 minutes ideally).

7. Allow at least 60 minutes between an activity's end_time and the next
   activity's start_time, for meals or rest.

8. Day 1 and the LAST day are real travel days, not throwaways. Plan
   activities around the flight times shown in AVAILABLE OPTIONS:
   - Day 1: skip slots that overlap the arrival flight, but fill the
     remaining slots. A morning arrival still leaves afternoon and
     evening; an afternoon arrival still leaves evening.
   - LAST day: skip slots that overlap the return flight, but fill the
     earlier slots. Most return flights are afternoon/evening, so the
     morning of the last day is almost always usable — schedule a light
     activity there (a museum, a café, a short walk near the hotel).
     Only leave the entire last day empty if the return flight is
     genuinely early-morning (before 11:00 local time).
   Do NOT schedule activities during flight times themselves.

9. Keep total cost under the user's budget_eur (sum: chosen flight +
   accommodation_per_night × nights + all activity and transport costs).

10. Match travel_style — '{prefs.travel_style.value}' should bias activity
    selection (CULTURAL prefers museums and landmarks; FOODIE prefers
    restaurants; ADVENTURE prefers outdoor activities; etc.).

For each consecutive pair of activities on the same day, call the
calculate_travel_time tool to choose a sensible TransportMode and produce
the TransportSegment that links them.
"""

    return Task(
        description=description.strip(),
        expected_output=(
            "A complete Itinerary object: trip_summary (with totals), the "
            "chosen flight, the chosen accommodation (or null), and a days[] list. "
            "Each DayPlan has morning/afternoon/evening TimeSlots (null when "
            "no activity is available), transport segments linking consecutive "
            "activities, an estimated_cost_eur, and a 1-2 sentence narrative "
            "summary. No activity_id may appear more than once. If there are "
            "ZERO activities in the input, ALL TimeSlots MUST be null."
        ),
        agent=itinerary_planner,
        output_pydantic=Itinerary,
    )


# =============================================================================
# Public entry point — used by the orchestrator and the standalone runner
# =============================================================================

def plan_itinerary(prefs: UserPreferences, options: Agent1Output) -> Itinerary:
    """Run Agent 2 and return a validated, grounded Itinerary with correct costs.

    Pure function — no prints, no mocks. The orchestrator calls this with
    real Agent 1 output; the standalone runner below calls it with mocks.

    After CrewAI returns, we cross-check grounding (every id came from
    Agent 1's options) and then overwrite the LLM's cost fields with
    Python-computed totals. The model reliably produces the right
    activity_ids and TimeSlots but consistently understates the trip
    total — usually by forgetting to add accommodation x nights, and
    sometimes by missing transport. Pre-computing the math is the same
    "Python does what Python can do correctly" pattern we use for the
    availability table.
    """
    task = build_planning_task(prefs, options)
    crew = Crew(
        agents=[itinerary_planner],
        tasks=[task],
        verbose=os.getenv("AGENT2_VERBOSE", "0") == "1",
    )
    result = crew.kickoff()
    itinerary: Itinerary = result.pydantic
    _assert_grounded(itinerary, options)
    _relabel_activities(itinerary, options)
    _recompute_costs(itinerary)
    return itinerary


def _relabel_activities(itinerary: "Itinerary", options: Agent1Output) -> None:
    """Overwrite each TimeSlot's activity_name/address from the canonical
    activity matched by id. The LLM occasionally pairs a correct activity_id
    with a name/address borrowed from a different option (e.g. id=act-7 with
    name="Palácio da Pena" instead of "LX Factory"). The id is the source of
    truth; everything human-readable is derived."""
    by_id = {a.id: a for a in options.activities}
    for day in itinerary.days:
        for slot in (day.morning, day.afternoon, day.evening):
            if slot is None:
                continue
            canonical = by_id.get(slot.activity_id)
            if canonical is None:
                continue
            slot.activity_name = canonical.name
            slot.address = canonical.address


def _recompute_costs(itinerary: "Itinerary") -> None:
    """Overwrite the LLM-produced cost fields in-place with arithmetic facts.

    Per-day cost = sum of activity TimeSlot costs + sum of transport costs.
    Trip total   = flight + accommodation per night x nights + sum of days.
    """
    for day in itinerary.days:
        slot_costs = sum(
            slot.cost_eur
            for slot in (day.morning, day.afternoon, day.evening)
            if slot is not None
        )
        transport_costs = sum(seg.cost_eur for seg in day.transport)
        day.estimated_cost_eur = round(slot_costs + transport_costs, 2)

    flight_cost = itinerary.flight.total_price_eur if itinerary.flight is not None else 0.0
    nights = (itinerary.trip_summary.end_date - itinerary.trip_summary.start_date).days
    accommodation_cost = (
        itinerary.accommodation.price_per_night_eur * nights
        if itinerary.accommodation is not None else 0.0
    )
    days_cost = sum(d.estimated_cost_eur for d in itinerary.days)

    itinerary.trip_summary.total_estimated_cost_eur = round(
        flight_cost + accommodation_cost + days_cost, 2
    )


def _assert_grounded(itinerary: Itinerary, options: Agent1Output) -> None:
    """Reject hallucinated ids. Raises ValueError if any id was invented."""
    flight_ids = {f.id for f in options.flights}
    accommodation_ids = {a.id for a in options.accommodations}
    activity_ids = {a.id for a in options.activities}

    if itinerary.flight is not None:
        if itinerary.flight.id not in flight_ids:
            raise ValueError(
                f"Itinerary chose flight id '{itinerary.flight.id}', which is "
                f"not in Agent 1's flights. Available ids: {sorted(flight_ids)}"
            )

    if itinerary.accommodation is not None:
        if itinerary.accommodation.id not in accommodation_ids:
            raise ValueError(
                f"Itinerary chose accommodation id "
                f"'{itinerary.accommodation.id}', which is not in Agent 1's "
                f"accommodations. Available ids: {sorted(accommodation_ids)}"
            )

    for day in itinerary.days:
        for slot in (day.morning, day.afternoon, day.evening):
            if slot is None:
                continue
            if slot.activity_id not in activity_ids:
                raise ValueError(
                    f"Itinerary day {day.day_number} references activity_id "
                    f"'{slot.activity_id}' ({slot.activity_name}), which is "
                    f"not in Agent 1's activities. Available ids: "
                    f"{sorted(activity_ids) or 'NONE'}"
                )


# =============================================================================
# Standalone runner — exercises Agent 2 with mock Agent 1 output
# =============================================================================

def run() -> Itinerary:
    from backend.agents._planner_mocks import MOCK_AGENT1_OUTPUT, MOCK_USER_PREFS

    print("=" * 70)
    print("Agent 2 — Itinerary Planner (stub run)")
    print("=" * 70)
    print(f"Destination:          {MOCK_USER_PREFS.destination}")
    print(f"Dates:                {MOCK_USER_PREFS.start_date} to {MOCK_USER_PREFS.end_date}")
    print(f"Budget:               {MOCK_USER_PREFS.budget_eur} EUR")
    print(f"Party size:           {MOCK_USER_PREFS.party_size}")
    print(f"Travel style:         {MOCK_USER_PREFS.travel_style.value}")
    print(f"Activities available: {len(MOCK_AGENT1_OUTPUT.activities)}")
    print(f"Model:                {llm.model}")
    print()

    itinerary = plan_itinerary(MOCK_USER_PREFS, MOCK_AGENT1_OUTPUT)

    print("\n" + "=" * 70)
    print("FINAL ITINERARY (validated against schemas.Itinerary)")
    print("=" * 70)
    print(itinerary.model_dump_json(indent=2))
    print()
    print(f"Total estimated cost: {itinerary.trip_summary.total_estimated_cost_eur} EUR "
          f"(budget: {itinerary.trip_summary.budget_eur} EUR)")
    print(f"Days planned:         {len(itinerary.days)}")
    return itinerary


if __name__ == "__main__":
    run()
