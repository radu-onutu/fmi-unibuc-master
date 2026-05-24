"""
Mock Agent 1 output and user preferences used to run Agent 2 standalone.

This is only loaded when planner_agent.py is invoked directly
(`python -m backend.agents.planner_agent`), not when the orchestrator
calls plan_itinerary().
"""

from datetime import date, datetime

from backend.shared.schemas import (
    AccommodationOption, ActivityCategory, ActivityOption, Agent1Output,
    FlightLeg, FlightOption, GeoPoint, TravelStyle, UserPreferences,
)


MOCK_USER_PREFS = UserPreferences(
    destination="Lisbon",
    start_date=date(2026, 6, 1),     # Monday
    end_date=date(2026, 6, 4),        # Thursday — 3-night trip
    budget_eur=1500,
    party_size=2,
    travel_style=TravelStyle.CULTURAL,
    departure_airport="OTP",
    constraints=["vegetarian-friendly meals"],
)

MOCK_AGENT1_OUTPUT = Agent1Output(
    flights=[
        FlightOption(
            id="flight_1",
            airline="TAROM",
            outbound=FlightLeg(
                departure_airport="OTP", arrival_airport="LIS",
                departure_time=datetime(2026, 6, 1, 7, 30),
                arrival_time=datetime(2026, 6, 1, 11, 0),
                flight_number="RO337",
            ),
            return_leg=FlightLeg(
                departure_airport="LIS", arrival_airport="OTP",
                departure_time=datetime(2026, 6, 4, 19, 0),
                arrival_time=datetime(2026, 6, 4, 23, 30),
                flight_number="RO338",
            ),
            total_price_eur=320.0,
        ),
        FlightOption(
            id="flight_2",
            airline="Ryanair",
            outbound=FlightLeg(
                departure_airport="OTP", arrival_airport="LIS",
                departure_time=datetime(2026, 6, 1, 13, 15),
                arrival_time=datetime(2026, 6, 1, 16, 45),
                flight_number="FR8234",
            ),
            return_leg=FlightLeg(
                departure_airport="LIS", arrival_airport="OTP",
                departure_time=datetime(2026, 6, 4, 21, 30),
                arrival_time=datetime(2026, 6, 5, 1, 50),
                flight_number="FR8235",
            ),
            total_price_eur=210.0,
        ),
    ],
    accommodations=[
        AccommodationOption(
            id="hotel_1",
            name="Baixa Boutique Hotel",
            type="hotel",
            location=GeoPoint(lat=38.7139, lng=-9.1394),
            address="Rua Augusta 100, Lisbon",
            price_per_night_eur=110.0,
            rating=4.5,
            amenities=["wifi", "breakfast", "air conditioning"],
        ),
        AccommodationOption(
            id="hotel_2",
            name="Alfama Guesthouse",
            type="hostel",
            location=GeoPoint(lat=38.7115, lng=-9.1303),
            address="Rua dos Remedios 45, Alfama, Lisbon",
            price_per_night_eur=65.0,
            rating=4.2,
            amenities=["wifi", "shared kitchen"],
        ),
    ],
    activities=[
        ActivityOption(
            id="act_1",
            name="Jeronimos Monastery",
            category=ActivityCategory.LANDMARK,
            description="UNESCO World Heritage site, Manueline architecture masterpiece",
            location=GeoPoint(lat=38.6979, lng=-9.2068),
            address="Praca do Imperio, Belem",
            price_eur=12.0, duration_minutes=90, rating=4.7,
            # Closed Mondays (index 0)
            opening_hours=[None, "10:00-17:30", "10:00-17:30", "10:00-17:30",
                           "10:00-17:30", "10:00-17:30", "10:00-17:30"],
            best_time_of_day="morning",
        ),
        ActivityOption(
            id="act_2",
            name="Belem Tower",
            category=ActivityCategory.LANDMARK,
            description="Iconic 16th-century tower at the mouth of the Tagus",
            location=GeoPoint(lat=38.6916, lng=-9.2160),
            address="Avenida Brasilia, Belem",
            price_eur=8.0, duration_minutes=60, rating=4.5,
            opening_hours=[None, "10:00-18:00", "10:00-18:00", "10:00-18:00",
                           "10:00-18:00", "10:00-18:00", "10:00-18:00"],
        ),
        ActivityOption(
            id="act_3",
            name="Pasteis de Belem",
            category=ActivityCategory.RESTAURANT,
            description="Original 1837 bakery for the famous Portuguese custard tart",
            location=GeoPoint(lat=38.6976, lng=-9.2036),
            address="Rua de Belem 84, Belem",
            price_eur=5.0, duration_minutes=30, rating=4.6,
            opening_hours=["08:00-23:00"] * 7,
        ),
        ActivityOption(
            id="act_4",
            name="Time Out Market Lisboa",
            category=ActivityCategory.RESTAURANT,
            description="Curated food hall with top chefs and Portuguese specialties",
            location=GeoPoint(lat=38.7068, lng=-9.1456),
            address="Av. 24 de Julho 49, Cais do Sodre",
            price_eur=25.0, duration_minutes=90, rating=4.5,
            opening_hours=["10:00-23:59"] * 7,
        ),
        ActivityOption(
            id="act_5",
            name="Castelo de Sao Jorge",
            category=ActivityCategory.LANDMARK,
            description="Moorish castle with panoramic views of Lisbon",
            location=GeoPoint(lat=38.7139, lng=-9.1334),
            address="Rua de Santa Cruz, Alfama",
            price_eur=15.0, duration_minutes=120, rating=4.6,
            opening_hours=["09:00-18:00"] * 7,
        ),
        ActivityOption(
            id="act_6",
            name="Tram 28 Heritage Ride",
            category=ActivityCategory.TOUR,
            description="Vintage tram route through Alfama, Baixa, and Estrela",
            location=GeoPoint(lat=38.7152, lng=-9.1351),
            address="Martim Moniz Square",
            price_eur=3.0, duration_minutes=60, rating=4.3,
            opening_hours=["06:00-22:30"] * 7,
        ),
        ActivityOption(
            id="act_7",
            name="National Tile Museum",
            category=ActivityCategory.MUSEUM,
            description="Five centuries of Portuguese azulejo tile art",
            location=GeoPoint(lat=38.7252, lng=-9.1149),
            address="Rua da Madre de Deus 4, Xabregas",
            price_eur=8.0, duration_minutes=90, rating=4.5,
            # Closed Mondays
            opening_hours=[None, "10:00-18:00", "10:00-18:00", "10:00-18:00",
                           "10:00-18:00", "10:00-18:00", "10:00-18:00"],
        ),
        ActivityOption(
            id="act_8",
            name="LX Factory",
            category=ActivityCategory.SHOPPING,
            description="Repurposed industrial complex with shops, restaurants, street art",
            location=GeoPoint(lat=38.7037, lng=-9.1788),
            address="Rua Rodrigues de Faria 103, Alcantara",
            price_eur=0.0, duration_minutes=120, rating=4.4,
            opening_hours=["10:00-22:00"] * 7,
        ),
    ],
)
