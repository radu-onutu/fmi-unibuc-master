create table dim_shipping_companies (
    id                  number generated always as identity,
    company_name        varchar2(150) not null,
    scac_code           varchar2(10) not null, 
    imo_company_code    varchar2(10) not null,
    country_of_origin   varchar2(50) not null,
    constraint pk_dim_companies primary key ( id ),
    constraint uq_dim_comp_scac unique ( scac_code ),
    constraint uq_dim_comp_imo unique ( imo_company_code )
);

create table dim_ships (
    id                  number generated always as identity,
    company_id          number not null,
    imo_number          varchar2(30) not null,
    ship_name           varchar2(80) not null,
    build_year          number(4) not null,
    teu_capacity        number not null,
    gross_tonnage       number not null,
    fuel_type           varchar2(30) not null,
    created_at          timestamp not null,
    updated_at          timestamp not null,
    constraint pk_dim_ships primary key ( id ),
    constraint fk_dim_ships_company foreign key ( company_id )
       references dim_shipping_companies ( id ),
    constraint uq_dim_ships_imo unique ( imo_number ),
    constraint ck_dim_ships_teu check ( teu_capacity > 0 ),
    constraint ck_dim_ships_tonnage check ( gross_tonnage > 0 )
);

create table dim_ports (
    id            number generated always as identity,
    berth_number  varchar2(20) not null, 
    berth_type    varchar2(30) not null,
    constraint pk_dim_ports primary key ( id ),
    constraint uq_dim_ports_number unique ( berth_number )
);

create table dim_docks (
    id            number generated always as identity,
    dock_name     varchar2(150) not null,
    un_locode     varchar2(10) not null,
    city          varchar2(100) not null,
    country       varchar2(100) not null,
    continent     varchar2(50) not null,
    constraint pk_dim_docks primary key ( id ),
    constraint uq_dim_docks_locode unique ( un_locode )
)
partition by list ( continent ) (
    partition p_europe values ( 'Europe' ),
    partition p_asia values ( 'Asia' ),
    partition p_america values ( 'America' ),
    partition p_africa values ( 'Africa' ),
    partition p_oceania values ( 'Oceania' ),
    partition p_other values ( default )
);

create table dim_status (
    id           number generated always as identity,
    status_type  varchar2(30) not null,
    constraint pk_dim_status primary key ( id ),
    constraint uq_dim_status unique ( status_type )
);

create table dim_voyage_profiles (
    id               number generated always as identity,
    voyage_number    varchar2(20) not null,
    transport_type   varchar2(30) not null,
    is_international number(1) not null,
    created_at       timestamp not null,
    updated_at       timestamp not null,
    constraint pk_dim_voyage_prof primary key ( id ),
    constraint uq_dim_voyage_prof unique ( voyage_number, transport_type, is_international ),
    constraint ck_dim_voyage_intl check ( is_international in ( 0, 1 ) )
);

create table dim_time (
    id              number generated always as identity,
    calendar_date   date not null,
    year            number(4) not null,
    month           number(2) not null,
    day             number(2) not null,
    hour            number(2) not null,
    day_of_week     number(1) not null,
    is_holiday      number(1) not null,
    is_peak_season  number(1) not null, 
    is_weekend      number(1) not null,
    constraint pk_dim_time primary key ( id ),
    constraint uq_dim_time unique ( calendar_date, hour ),
    constraint ck_dim_time_month check ( month between 1 and 12 ),
    constraint ck_dim_time_day check ( day between 1 and 31 ),
    constraint ck_dim_time_hour check ( hour between 0 and 23 ),
    constraint ck_dim_time_dow check ( day_of_week between 1 and 7 ),
    constraint ck_dim_time_holiday check ( is_holiday in ( 0, 1 ) ),
    constraint ck_dim_time_peak check ( is_peak_season in ( 0, 1 ) ),
    constraint ck_dim_time_weekend check ( is_weekend in ( 0, 1 ) )
);

create table fact_shipments (
    id                      number generated always as identity,
    ship_id                 number not null,
    port_id                 number not null, 
    departure_time_id       number not null,
    arrival_time_id         number not null,
    departure_dock_id       number not null, 
    arrival_dock_id         number not null,
    voyage_profile_id       number not null,
    status_id               number not null,
    departure_timestamp     timestamp not null,
    arrival_timestamp       timestamp not null,
    direction               varchar2(50) not null, 
    voyage_duration_hours   number not null,
    teu_utilized            number not null,       
    crew_count              number not null,
    cargo_tonnage           number not null,       
    port_fees               number(12,2) not null, 
    distance_nautical_miles number not null,
    fuel_consumed           number,                
    created_at              timestamp not null,
    updated_at              timestamp not null,
  
    constraint pk_fact_shipments primary key ( id ),
    constraint fk_fact_ship foreign key ( ship_id )
       references dim_ships ( id ),
    constraint fk_fact_port foreign key ( port_id )
       references dim_ports ( id ),
    constraint fk_fact_time_dept foreign key ( departure_time_id )
       references dim_time ( id ),
    constraint fk_fact_time_arr foreign key ( arrival_time_id )
       references dim_time ( id ),
    constraint fk_fact_dock_dept foreign key ( departure_dock_id )
       references dim_docks ( id ),
    constraint fk_fact_dock_arr foreign key ( arrival_dock_id )
       references dim_docks ( id ),
    constraint fk_fact_profile foreign key ( voyage_profile_id )
       references dim_voyage_profiles ( id ),
    constraint fk_fact_status foreign key ( status_id )
       references dim_status ( id ),
    constraint ck_fact_interval check ( arrival_timestamp > departure_timestamp ),
    constraint ck_fact_duration check ( voyage_duration_hours >= 0 ),
    constraint ck_fact_teu check ( teu_utilized >= 0 ),
    constraint ck_fact_crew check ( crew_count >= 0 ),
    constraint ck_fact_tonnage check ( cargo_tonnage >= 0 ),
    constraint ck_fact_fees check ( port_fees >= 0 ),
    constraint ck_fact_dist check ( distance_nautical_miles >= 0 ),
    constraint ck_fact_route check ( departure_dock_id <> arrival_dock_id )
)
partition by range ( departure_timestamp ) 
interval ( numtoyminterval( 1, 'MONTH' ) ) 
( 
    partition p_2023_01 values less than ( timestamp '2023-02-01 00:00:00' )
);

-- 4 - ETL
INSERT INTO dim_shipping_companies (
    company_name, 
    scac_code, 
    imo_company_code, 
    country_of_origin
)
SELECT 
    name,               
    scac_code, 
    imo_company_num,   
    country_of_origin
FROM app_user_oltp.shipments_companies src
WHERE NOT EXISTS (
    SELECT 1 
    FROM dim_shipping_companies dst 
    WHERE dst.scac_code = src.scac_code
);

INSERT INTO dim_ships (
    company_id,
    imo_number,
    ship_name,
    build_year,
    teu_capacity,
    gross_tonnage,
    fuel_type,
    created_at,
    updated_at
)
SELECT 
    dim_c.id,              
    src_s.imo_number,
    src_s.ship_name,
    src_s.build_year,
    src_s.teu_capacity,
    src_s.gross_tonnage,
    src_s.fuel_type,
    SYSTIMESTAMP,          
    SYSTIMESTAMP            
FROM app_user_oltp.ships src_s
JOIN app_user_oltp.shipments_companies src_c 
    ON src_s.company_id = src_c.id
JOIN dim_shipping_companies dim_c 
    ON src_c.scac_code = dim_c.scac_code 
WHERE NOT EXISTS (
    SELECT 1 
    FROM dim_ships ds 
    WHERE ds.imo_number = src_s.imo_number
);

INSERT INTO dim_ports (
    berth_number,
    berth_type
)
SELECT 
    berth_number, 
    type          
FROM app_user_oltp.ports src
WHERE NOT EXISTS (
    SELECT 1 
    FROM dim_ports dp 
    WHERE dp.berth_number = src.berth_number
);

INSERT INTO dim_docks (
    dock_name,
    un_locode,
    city,
    country,
    continent
)
SELECT 
    name,       
    un_locode,
    city,
    country,
    continent
FROM app_user_oltp.docks src
WHERE NOT EXISTS (
    SELECT 1 
    FROM dim_docks dd 
    WHERE dd.un_locode = src.un_locode
);

INSERT INTO dim_status ( status_type )
   SELECT DISTINCT z.status
     FROM app_user_oltp.shipments z
     WHERE z.status IS NOT NULL;

INSERT INTO dim_voyage_profiles (
    voyage_number,
    transport_type,
    is_international,
    created_at,
    updated_at
)
SELECT DISTINCT
    voyage_number,
    transport_type,
    is_international,
    SYSTIMESTAMP, 
    SYSTIMESTAMP  
FROM app_user_oltp.shipments src
WHERE NOT EXISTS (
    SELECT 1 
    FROM dim_voyage_profiles dvp 
    WHERE dvp.voyage_number = src.voyage_number
      AND dvp.transport_type = src.transport_type
      AND dvp.is_international = src.is_international
);

insert into dim_time (
    calendar_date,
    year,
    month,
    day,
    hour,
    day_of_week,
    is_holiday,
    is_peak_season,
    is_weekend
)
with dates as (
    select date '2023-01-01' + ( level - 1 ) as d
      from dual
    connect by
       level <= ( date '2026-12-31' - date '2023-01-01' ) + 1
),
hours as (
    select level - 1 as h
      from dual
    connect by
       level <= 24
)
select 
    dt.d as calendar_date,
    extract(year from dt.d) as year,
    extract(month from dt.d) as month,
    extract(day from dt.d) as day,
    hr.h as hour,
    ( trunc(dt.d) - trunc(dt.d, 'IW') ) + 1 as day_of_week,
    case
       when to_char(dt.d, 'MMDD') in ( '0101', '1225', '1226' ) then 1
       else 0
    end as is_holiday,
    case
       when hr.h between 7 and 10 or hr.h between 17 and 20 then 1
       else 0
    end as is_peak_season,
    case
       when ( trunc(dt.d) - trunc(dt.d, 'IW') ) + 1 in ( 6, 7 ) then 1
       else 0
    end as is_weekend
from dates dt
cross join hours hr;

INSERT INTO fact_shipments (
    ship_id,
    port_id,
    departure_time_id,
    arrival_time_id,
    departure_dock_id,
    arrival_dock_id,
    voyage_profile_id,
    status_id,
    departure_timestamp,
    arrival_timestamp,
    direction,
    voyage_duration_hours,
    teu_utilized,
    crew_count,
    cargo_tonnage,
    port_fees,
    distance_nautical_miles,
    fuel_consumed,
    created_at,
    updated_at
)
WITH params AS (
    SELECT 500 AS base_port_fee,
           250 AS international_surcharge,
           15  AS fee_per_teu,
           0.05 AS fuel_rate_per_mile_per_ton
      FROM dual
), 
agg AS (
    SELECT s.id AS shipment_id,
           COUNT(ct.id) AS nr_containers,
           NVL(SUM(ct.tax_amount), 0) AS total_cargo_tax,
           (SELECT COUNT(*) FROM app_user_oltp.crew_ship_mapping csm WHERE csm.shipment_id = s.id) AS crew_count_calc
      FROM app_user_oltp.shipments s
      LEFT JOIN app_user_oltp.cargo_taxes ct ON ct.shipment_id = s.id
     GROUP BY s.id
)
SELECT ds.id,
       dp.id,
       dt_dep.id,
       dt_arr.id,
       dd_dep.id,
       dd_arr.id,
       dvp.id,
       dst.id,
       s.departure_date,
       s.arrival_date,
       (dd_dep.un_locode || ' -> ' || dd_arr.un_locode),
       ROUND((CAST(s.arrival_date AS DATE) - CAST(s.departure_date AS DATE)) * 24, 2),
       (a.nr_containers * 2),
       a.crew_count_calc,
       sh.gross_tonnage,
       (p.base_port_fee + (a.nr_containers * p.fee_per_teu) + CASE WHEN s.is_international = 1 THEN p.international_surcharge ELSE 0 END),
       s.distance_nm,
       ROUND(s.distance_nm * (sh.gross_tonnage / 1000) * p.fuel_rate_per_mile_per_ton, 2),
       SYSTIMESTAMP,
       SYSTIMESTAMP
  FROM app_user_oltp.shipments s
  JOIN app_user_oltp.ships sh ON sh.id = s.ship_id
  JOIN agg a ON a.shipment_id = s.id
  JOIN dim_ships ds ON ds.imo_number = sh.imo_number
  JOIN app_user_oltp.ports po ON po.id = s.berth_id
  JOIN dim_ports dp ON dp.berth_number = po.berth_number
  JOIN dim_status dst ON dst.status_type = s.status
  JOIN dim_voyage_profiles dvp ON dvp.voyage_number = s.voyage_number
   AND dvp.transport_type = s.transport_type
   AND dvp.is_international = s.is_international
  JOIN app_user_oltp.docks dock_dep ON dock_dep.id = s.departure_port_id
  JOIN app_user_oltp.docks dock_arr ON dock_arr.id = s.arrival_port_id
  JOIN dim_docks dd_dep ON dd_dep.un_locode = dock_dep.un_locode
  JOIN dim_docks dd_arr ON dd_arr.un_locode = dock_arr.un_locode
  JOIN dim_time dt_dep ON dt_dep.calendar_date = TRUNC(CAST(s.departure_date AS DATE))
   AND dt_dep.hour = EXTRACT(HOUR FROM CAST(s.departure_date AS TIMESTAMP))
  JOIN dim_time dt_arr ON dt_arr.calendar_date = TRUNC(CAST(s.arrival_date AS DATE))
   AND dt_arr.hour = EXTRACT(HOUR FROM CAST(s.arrival_date AS TIMESTAMP))
 CROSS JOIN params p;

COMMIT;
select * from fact_shipments;

-- 6 - Indexing

begin
   dbms_stats.gather_table_stats(user, 'FACT_SHIPMENTS', cascade => true);
   dbms_stats.gather_table_stats(user, 'DIM_STATUS', cascade => true);
   dbms_stats.gather_table_stats(user, 'DIM_VOYAGE_PROFILES', cascade => true);
   dbms_stats.gather_table_stats(user, 'DIM_DOCKS', cascade => true);
end;
/

-- Indexing
create index ix_fs_departure_time on fact_shipments (departure_timestamp) local;

create bitmap index bix_fs_ship_id on fact_shipments (ship_id) local;
create bitmap index bix_fs_departure_dock on fact_shipments (departure_dock_id) local;
create bitmap index bix_fs_arrival_dock on fact_shipments (arrival_dock_id) local;
create bitmap index bix_fs_voyage_profile on fact_shipments (voyage_profile_id) local;
create bitmap index bix_fs_status on fact_shipments (status_id) local;

-- Refresh Fact after indexing
begin
   dbms_stats.gather_table_stats(user, 'FACT_SHIPMENTS', cascade => true);
end;
/

-- 6 Delayed Holiday Shipments
-- From analysis - natural query
explain plan for
select dd_arr.un_locode || ' - ' || dd_dep.un_locode as route,
       sum(f.teu_utilized) as total_teus
  from fact_shipments f
  join dim_docks dd_dep on dd_dep.id = f.departure_dock_id
  join dim_docks dd_arr on dd_arr.id = f.arrival_dock_id
 where f.voyage_profile_id in (
   select p.id from dim_voyage_profiles p where p.is_international = 1
 )
   and f.status_id in (
   select s.id from dim_status s where s.status_type = 'delayed'
 )
   and f.departure_timestamp between to_timestamp('2025-07-12 12:00', 'YYYY-MM-DD HH24:MI') 
                                 and to_timestamp('2025-07-15 13:00', 'YYYY-MM-DD HH24:MI')
 group by dd_arr.un_locode, dd_dep.un_locode
 order by total_teus desc;

select * from table(dbms_xplan.display(null, null, 'BASIC +PREDICATE'));

-- We observe IX_FS_DEPARTURE_TIMESTAMP si BIX_FS_STATUS_ID / BIX_FS_VOYAGE_PROFILE_ID

--CERINTA 8 - PARTITIONARE

-- Rerun with partition
-- EXPLAIN PLAN FOR
-- SELECT 
--     dd.continent,
--     COUNT(*) AS total_shipments,
--     SUM(f.cargo_tonnage) AS total_tonnage
-- FROM fact_shipments f
-- JOIN dim_docks dd ON f.departure_dock_id = dd.id
-- WHERE f.departure_timestamp >= TIMESTAMP '2024-12-01 00:00:00'
--   AND f.departure_timestamp <  TIMESTAMP '2025-01-01 00:00:00'
-- GROUP BY dd.continent;

-- Display plan
-- SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY(NULL, NULL, 'BASIC +PREDICATE +PARTITION'));


-- 9. OPTIMIZARE QUERY

-- Initial query

explain plan
   for
select c.company_name as company,
       count(*) as total_voyages,
       sum(f.cargo_tonnage) as total_tonnage,
       round(
          avg(f.distance_nautical_miles),
          2
       ) as avg_distance_nm
  from fact_shipments f
  join dim_ships sh
on sh.id = f.ship_id
  join dim_shipping_companies c
on c.id = sh.company_id
  join dim_status s
on s.id = f.status_id
  join dim_voyage_profiles p
on p.id = f.voyage_profile_id
  join dim_docks dd_dep
on dd_dep.id = f.departure_dock_id
  join dim_docks dd_arr
on dd_arr.id = f.arrival_dock_id
 where s.status_type = 'docked'
   and p.is_international = 1
   and dd_dep.continent = 'Europe'
   and dd_arr.continent <> 'Europe'
   and ( ( f.departure_timestamp >= timestamp '2023-06-01 00:00:00'
   and f.departure_timestamp < timestamp '2023-09-01 00:00:00' )
    or ( f.departure_timestamp >= timestamp '2024-06-01 00:00:00'
   and f.departure_timestamp < timestamp '2024-09-01 00:00:00' )
    or ( f.departure_timestamp >= timestamp '2025-06-01 00:00:00'
   and f.departure_timestamp < timestamp '2025-09-01 00:00:00' ) )
 group by c.company_name
 order by total_tonnage desc;

select *
  from table ( dbms_xplan.display(
   null,
   null,
   'BASIC +PREDICATE +PARTITION'
) );

-- FOREIGN KEYS ARE ALREADY INDEXED

-- MV for mountly shipping stats by company and route

create materialized view mv_shipping_stats_monthly build immediate
   refresh on demand
   enable query rewrite
as
   select c.id as company_id,
          extract(year from f.departure_timestamp) as year,
          extract(month from f.departure_timestamp) as month,
          count(*) as total_voyages,
          sum(f.cargo_tonnage) as total_tonnage,
          avg(f.distance_nautical_miles) as avg_distance_nm,
          sum(f.port_fees) as total_fees,
          dd_dep.continent as origin_continent,
          dd_arr.continent as destination_continent
     from fact_shipments f
     join dim_ships sh
   on sh.id = f.ship_id
     join dim_shipping_companies c
   on c.id = sh.company_id
     join dim_status s
   on s.id = f.status_id
     join dim_voyage_profiles p
   on p.id = f.voyage_profile_id
     join dim_docks dd_dep
   on dd_dep.id = f.departure_dock_id
     join dim_docks dd_arr
   on dd_arr.id = f.arrival_dock_id
    where s.status_type = 'COMPLETED'
      and p.is_international = 1
    group by c.id,
             extract(year from f.departure_timestamp),
             extract(month from f.departure_timestamp),
             dd_dep.continent,
             dd_arr.continent;
select *
  from mv_shipping_stats_monthly;

-- Rewrite FINAL QUERY using MW

explain plan
   for
select ca.company_name as company,
       sum(m.total_tonnage) as total_tonnage,
       sum(m.total_voyages) as total_voyages,
       round(
          avg(m.avg_distance_nm),
          2
       ) as avg_distance_nm
  from mv_shipping_stats_monthly m
  join dim_shipping_companies ca
on ca.id = m.company_id
 where m.origin_continent = 'Europe'
   and m.destination_continent in ( 'Asia',
                               'Africa',
                               'America',
                               'Oceania' )
   and m.year in ( 2023,
                 2024,
                 2025 )
   and m.month in ( 6,
                   7,
                   8 )
 group by ca.company_name
 order by total_tonnage desc;

select *
  from table ( dbms_xplan.display(
   null,
   null,
   'BASIC +PREDICATE'
) );
