// ================================
// DIM 1: Shipping Companies
// ================================
export const dim_shipping_companies = [
  {
    id: 1,
    company_name: "Maersk Line",
    scac_code: "MAEU",
    imo_company_code: "IMO001",
    country_of_origin: "Denmark"
  },
  {
    id: 2,
    company_name: "MSC Mediterranean Shipping",
    scac_code: "MSCU",
    imo_company_code: "IMO002",
    country_of_origin: "Switzerland"
  },
  {
    id: 3,
    company_name: "CMA CGM",
    scac_code: "CMDU",
    imo_company_code: "IMO003",
    country_of_origin: "France"
  }
];

// ================================
// DIM 2: Ships
// ================================
export const dim_ships = [
  {
    id: 1,
    company_id: 1,
    imo_number: "IMO1234567",
    ship_name: "Maersk Horizon",
    build_year: 2018,
    teu_capacity: 18000,
    gross_tonnage: 190000,
    fuel_type: "LNG",
    created_at: "2024-01-01T00:00:00",
    updated_at: "2024-01-01T00:00:00"
  },
  {
    id: 2,
    company_id: 2,
    imo_number: "IMO7654321",
    ship_name: "MSC Atlantic",
    build_year: 2020,
    teu_capacity: 21000,
    gross_tonnage: 220000,
    fuel_type: "Marine Diesel",
    created_at: "2024-01-01T00:00:00",
    updated_at: "2024-01-01T00:00:00"
  }
];

// ================================
// DIM 3: Ports (Berths)
// ================================
export const dim_ports = [
  { id: 1, berth_number: "B-101", berth_type: "Container" },
  { id: 2, berth_number: "B-202", berth_type: "Bulk" }
];

// ================================
// DIM 4: Docks (Geographic Locations)
// ================================
export const dim_docks = [
  {
    id: 1,
    dock_name: "Port of Rotterdam",
    un_locode: "NLRTM",
    city: "Rotterdam",
    country: "Netherlands",
    continent: "Europe"
  },
  {
    id: 2,
    dock_name: "Port of Shanghai",
    un_locode: "CNSHA",
    city: "Shanghai",
    country: "China",
    continent: "Asia"
  },
  {
    id: 3,
    dock_name: "Port of Los Angeles",
    un_locode: "USLAX",
    city: "Los Angeles",
    country: "USA",
    continent: "North America"
  }
];

// ================================
// DIM 5: Status
// ================================
export const dim_status = [
  { id: 1, status_type: "Completed" },
  { id: 2, status_type: "In Transit" },
  { id: 3, status_type: "Docked" }
];

// ================================
// DIM 6: Voyage Profiles
// ================================
export const dim_voyage_profiles = [
  {
    id: 1,
    voyage_number: "VOY-1001",
    transport_type: "Cargo",
    is_international: 1,
    created_at: "2024-01-01T00:00:00",
    updated_at: "2024-01-01T00:00:00"
  },
  {
    id: 2,
    voyage_number: "VOY-1002",
    transport_type: "Freight",
    is_international: 0,
    created_at: "2024-01-01T00:00:00",
    updated_at: "2024-01-01T00:00:00"
  }
];

// ================================
// DIM 7: Time
// ================================
export const dim_time = [
  {
    id: 1,
    calendar_date: "2024-03-01",
    year: 2024,
    month: 3,
    day: 1,
    hour: 10,
    day_of_week: 5,
    is_holiday: 0,
    is_peak_season: 0,
    is_weekend: 0
  },
  {
    id: 2,
    calendar_date: "2024-03-05",
    year: 2024,
    month: 3,
    day: 5,
    hour: 14,
    day_of_week: 2,
    is_holiday: 0,
    is_peak_season: 1,
    is_weekend: 0
  }
];

// ================================
// FACT: Shipments
// ================================
export const fact_shipments = [
  {
    id: 1,
    ship_id: 1,
    port_id: 1,
    departure_time_id: 1,
    arrival_time_id: 2,
    departure_dock_id: 1,
    arrival_dock_id: 2,
    voyage_profile_id: 1,
    status_id: 1,
    departure_timestamp: "2024-03-01T10:00:00",
    arrival_timestamp: "2024-03-05T14:00:00",
    direction: "Eastbound",
    voyage_duration_hours: 100,
    teu_utilized: 15000,
    crew_count: 28,
    cargo_tonnage: 120000,
    port_fees: 250000.50,
    distance_nautical_miles: 10500,
    fuel_consumed: 3000,
    created_at: "2024-03-01T09:00:00",
    updated_at: "2024-03-05T15:00:00"
  },
  {
    id: 2,
    ship_id: 2,
    port_id: 2,
    departure_time_id: 2,
    arrival_time_id: 1,
    departure_dock_id: 2,
    arrival_dock_id: 3,
    voyage_profile_id: 2,
    status_id: 2,
    departure_timestamp: "2024-03-05T14:00:00",
    arrival_timestamp: "2024-03-10T10:00:00",
    direction: "Westbound",
    voyage_duration_hours: 120,
    teu_utilized: 17000,
    crew_count: 32,
    cargo_tonnage: 150000,
    port_fees: 310000.00,
    distance_nautical_miles: 12000,
    fuel_consumed: 3500,
    created_at: "2024-03-05T13:00:00",
    updated_at: "2024-03-10T11:00:00"
  }
];
