"""
TravelMate AI — shared data schemas.

Defines the data contracts between:
  - the frontend (sends UserPreferences)
  - Agent 1 (returns Agent1Output)
  - Agent 2 (returns Itinerary)

Why Pydantic: runtime validation, free JSON (de)serialization, and CrewAI
can produce structured outputs that conform to these exact shapes.

Place at: backend/shared/schemas.py
Run a smoke test with: python schemas.py
"""

from datetime import date, datetime
from enum import Enum
from typing import Optional

from pydantic import BaseModel, Field, model_validator


# =============================================================================
# Enums — closed sets of values the LLM cannot invent new entries for
# =============================================================================

class TravelStyle(str, Enum):
    RELAXED = "relaxed"
    CULTURAL = "cultural"
    FOODIE = "foodie"
    ADVENTURE = "adventure"
    MIXED = "mixed"


class ActivityCategory(str, Enum):
    MUSEUM = "museum"
    RESTAURANT = "restaurant"
    OUTDOOR = "outdoor"
    TOUR = "tour"
    NIGHTLIFE = "nightlife"
    SHOPPING = "shopping"
    LANDMARK = "landmark"
    OTHER = "other"


class TransportMode(str, Enum):
    WALK = "walk"
    METRO = "metro"
    BUS = "bus"
    TAXI = "taxi"
    TRAIN = "train"


# Reusable regex for "HH:MM" 24-hour clock format
TIME_HHMM_PATTERN = r"^([01]\d|2[0-3]):[0-5]\d$"


# =============================================================================
# Frontend (Denisa) -> orchestrator
# =============================================================================

class UserPreferences(BaseModel):
    """Submitted by the user via the web form."""
    destination: str = Field(..., description="City name, e.g. 'Lisbon'")
    start_date: date
    end_date: date
    budget_eur: float = Field(..., gt=0)
    party_size: int = Field(..., ge=1, le=10)
    travel_style: TravelStyle = TravelStyle.MIXED
    departure_airport: str = Field(..., description="IATA code, e.g. 'OTP'")
    constraints: list[str] = Field(
        default_factory=list,
        description="Free-form, e.g. 'vegetarian', 'wheelchair access'",
    )


# =============================================================================
# Agent 1 output (Cristina) — search and compare results
# =============================================================================

class GeoPoint(BaseModel):
    lat: float
    lng: float


class FlightLeg(BaseModel):
    departure_airport: str  # IATA code
    arrival_airport: str
    departure_time: datetime
    arrival_time: datetime
    flight_number: str


class FlightOption(BaseModel):
    id: str
    airline: str
    outbound: FlightLeg
    return_leg: FlightLeg
    total_price_eur: float


class AccommodationOption(BaseModel):
    id: str
    name: str
    type: str  # "hotel", "hostel", "apartment"
    location: GeoPoint
    address: str
    price_per_night_eur: float
    rating: float = Field(..., ge=0, le=5)
    amenities: list[str] = Field(default_factory=list)


class ActivityOption(BaseModel):
    id: str
    name: str
    category: ActivityCategory
    description: str
    location: GeoPoint
    address: str
    price_eur: float = 0.0
    duration_minutes: int
    rating: float = Field(..., ge=0, le=5)
    # 7-element list, one per weekday (Mon=0). "HH:MM-HH:MM" or None if closed.
    opening_hours: list[Optional[str]] = Field(
        default_factory=lambda: [None] * 7
    )
    best_time_of_day: Optional[str] = None  # "morning" | "afternoon" | "evening"


class Agent1Output(BaseModel):
    """What Agent 1 returns. Agent 2 consumes this directly."""
    flights: list[FlightOption]
    accommodations: list[AccommodationOption]
    activities: list[ActivityOption]


# =============================================================================
# Agent 2 output (YOU) — the final itinerary
# =============================================================================

class TimeSlot(BaseModel):
    """One activity scheduled in a day part (morning/afternoon/evening)."""
    activity_id: str       # references ActivityOption.id from Agent 1
    activity_name: str
    address: str
    # Stored as "HH:MM" strings rather than datetime.time so CrewAI's
    # internal JSON logger can serialize them. JSON has no native time
    # type anyway — every API sends times as strings.
    start_time: str = Field(
        ..., pattern=TIME_HHMM_PATTERN,
        description="24-hour 'HH:MM', e.g. '09:30'",
    )
    end_time: str = Field(
        ..., pattern=TIME_HHMM_PATTERN,
        description="24-hour 'HH:MM', e.g. '11:00'",
    )
    cost_eur: float
    notes: Optional[str] = None


class TransportSegment(BaseModel):
    from_location: str
    to_location: str
    mode: TransportMode
    duration_minutes: int
    cost_eur: float


class DayPlan(BaseModel):
    day_number: int
    date: date
    morning: Optional[TimeSlot] = None
    afternoon: Optional[TimeSlot] = None
    evening: Optional[TimeSlot] = None
    transport: list[TransportSegment] = Field(default_factory=list)
    estimated_cost_eur: float
    summary: str = Field(..., description="1-2 sentence narrative for the day")


class TripSummary(BaseModel):
    destination: str
    start_date: date
    end_date: date
    total_estimated_cost_eur: float
    budget_eur: float
    party_size: int


class Itinerary(BaseModel):
    """What Agent 2 produces. The frontend renders this directly."""
    trip_summary: TripSummary
    flight: Optional[FlightOption] = None
    accommodation: Optional[AccommodationOption] = None
    days: list[DayPlan]

    @model_validator(mode="after")
    def no_duplicate_activities(self) -> "Itinerary":
        """
        Reject itineraries that schedule the same activity more than once.
        If this fires, CrewAI will re-prompt the agent to produce a valid
        itinerary on the next attempt.
        """
        seen: dict[str, int] = {}
        for day in self.days:
            for slot in (day.morning, day.afternoon, day.evening):
                if slot is None:
                    continue
                if slot.activity_id in seen:
                    raise ValueError(
                        f"Duplicate activity '{slot.activity_id}' "
                        f"({slot.activity_name}): scheduled on day "
                        f"{day.day_number} but already on day "
                        f"{seen[slot.activity_id]}. Each activity must "
                        f"appear at most once in the itinerary."
                    )
                seen[slot.activity_id] = day.day_number
        return self


# =============================================================================
# Smoke test — run `python schemas.py` to verify everything imports cleanly
# =============================================================================

if __name__ == "__main__":
    prefs = UserPreferences(
        destination="Lisbon",
        start_date=date(2026, 6, 1),
        end_date=date(2026, 6, 5),
        budget_eur=1500,
        party_size=2,
        travel_style=TravelStyle.CULTURAL,
        departure_airport="OTP",
    )
    print(prefs.model_dump_json(indent=2))
