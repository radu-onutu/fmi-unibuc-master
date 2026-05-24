import logging
from datetime import date, datetime, timedelta, timezone
from uuid import uuid4

from backend.shared.schemas import FlightLeg, FlightOption
from backend.services.travelpayouts_client import flight_get

log = logging.getLogger(__name__)

# When zero exact-date matches come back, widen the requested dates by this
# many days on either side so the demo isn't empty-handed. Travelpayouts'
# prices_for_dates endpoint returns whatever cached examples exist near the
# query date; cheap routes are not always cached daily.
DATE_TOLERANCE_DAYS = 2


def search_flights(
    origin: str,
    destination: str,
    departure_date: str,
    return_date: str,
    currency: str = "eur",
) -> list[FlightOption]:
    """Search flights via Travelpayouts /aviasales/v3/prices_for_dates.

    The upstream endpoint returns cached cheapest-fare examples for the
    given month, not strict-date matches. We post-filter to the requested
    dates and fall back to a +/-2 day window if the strict filter is empty.
    """
    params = {
        "origin": origin,
        "destination": destination,
        "departure_at": departure_date[:7],
        "return_at": return_date[:7],
        "sorting": "price",
        "direct": "false",
        "currency": currency,
        "limit": 30,
        "one_way": "false",
    }

    data = flight_get("/aviasales/v3/prices_for_dates", params)
    raw = data.get("data", []) or []
    log.info("Travelpayouts returned %d raw flight options for %s -> %s",
             len(raw), origin, destination)

    all_flights = [_to_flight_option(opt, origin, destination) for opt in raw]

    requested_dep = date.fromisoformat(departure_date)
    requested_ret = date.fromisoformat(return_date)

    exact = _filter_by_dates(all_flights, requested_dep, requested_ret, tolerance_days=0)
    if exact:
        log.info("Found %d flight options matching %s -> %s on %s / %s",
                 len(exact), origin, destination, requested_dep, requested_ret)
        return exact

    widened = _filter_by_dates(
        all_flights, requested_dep, requested_ret,
        tolerance_days=DATE_TOLERANCE_DAYS,
    )
    if widened:
        log.warning(
            "No flights on exact dates %s / %s; returning %d options within "
            "+/-%d days",
            requested_dep, requested_ret, len(widened), DATE_TOLERANCE_DAYS,
        )
        return widened

    log.warning(
        "No flights within +/-%d days of %s / %s; returning all %d cached "
        "options for the month so the pipeline has something to plan with",
        DATE_TOLERANCE_DAYS, requested_dep, requested_ret, len(all_flights),
    )
    return all_flights


def _to_flight_option(opt: dict, origin: str, destination: str) -> FlightOption:
    dep_time = _parse_dt(opt["departure_at"])
    ret_time = _parse_dt(opt["return_at"])
    airline = opt.get("airline", "??")
    flight_num = str(opt.get("flight_number", ""))
    dur_to = opt.get("duration_to") or 180
    dur_back = opt.get("duration_back") or 180

    return FlightOption(
        id=str(uuid4()),
        airline=airline,
        outbound=FlightLeg(
            departure_airport=opt.get("origin_airport", origin),
            arrival_airport=opt.get("destination_airport", destination),
            departure_time=dep_time,
            arrival_time=dep_time + timedelta(minutes=dur_to),
            flight_number=f"{airline}{flight_num}",
        ),
        return_leg=FlightLeg(
            departure_airport=opt.get("destination_airport", destination),
            arrival_airport=opt.get("origin_airport", origin),
            departure_time=ret_time,
            arrival_time=ret_time + timedelta(minutes=dur_back),
            flight_number=f"{airline}{flight_num}R",
        ),
        total_price_eur=float(opt["price"]),
    )


def _filter_by_dates(
    flights: list[FlightOption],
    requested_dep: date,
    requested_ret: date,
    tolerance_days: int,
) -> list[FlightOption]:
    return [
        f for f in flights
        if abs((f.outbound.departure_time.date() - requested_dep).days) <= tolerance_days
        and abs((f.return_leg.departure_time.date() - requested_ret).days) <= tolerance_days
    ]


def _parse_dt(value: str) -> datetime:
    """Parse an ISO-8601 datetime string; assume UTC when no offset."""
    dt = datetime.fromisoformat(value.replace("Z", "+00:00"))
    if dt.tzinfo is None:
        dt = dt.replace(tzinfo=timezone.utc)
    return dt
