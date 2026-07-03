create table shipments_companies (
    id                number generated always as identity,
    name              varchar2(150) not null,
    scac_code         varchar2(10) not null, 
    imo_company_num   varchar2(10) not null, 
    country_of_origin varchar2(50) not null,
    constraint pk_shipments_companies primary key ( id ),
    constraint uq_ship_comp_scac unique ( scac_code ),
    constraint uq_ship_comp_imo unique ( imo_company_num )
);

create table ports (
    id            number generated always as identity primary key,
    berth_number  varchar2(20) not null, 
    type          varchar2(30) not null, 
    constraint uq_ports_numar unique ( berth_number )
);

create table docks (
    id            number generated always as identity,
    name          varchar2(150) not null,
    un_locode     varchar2(10) not null,
    city          varchar2(100) not null,
    country       varchar2(100) not null,
    continent     varchar2(50) not null,
    constraint pk_docks primary key ( id ),
    constraint uq_docks_locode unique ( un_locode )
);

create table cargo_containers (
    id            number generated always as identity,
    serial_number varchar2(20) not null, 
    container_type varchar2(20) not null, 
    owner_country  varchar2(50) not null,
    max_payload    number not null,       
    constraint pk_cargo_containers primary key ( id ),
    constraint uq_cargo_cont_serie unique ( serial_number )
);

create table ships (
    id                number generated always as identity,
    company_id        number not null,
    imo_number        varchar2(30) not null,
    ship_name         varchar2(80) not null,
    build_year        number(4) not null,
    teu_capacity      number not null,      
    gross_tonnage     number not null,
    tank_capacity     number not null,
    fuel_type         varchar2(30) not null,
    constraint pk_ships primary key ( id ),
    constraint fk_ships_company foreign key ( company_id )
        references shipments_companies ( id ),
    constraint uq_ships_imo unique ( imo_number ),
    constraint ck_ships_cap_teu check ( teu_capacity > 0 ),
    constraint ck_ships_tonaj check ( gross_tonnage > 0 )
);

create table ship_crew (
    id            number generated always as identity,
    company_id    number not null,
    first_name    varchar2(80) not null,
    last_name     varchar2(80) not null,
    role          varchar2(50) not null,
    nationality   varchar2(50),
    constraint pk_ship_crew primary key ( id ),
    constraint fk_crew_company foreign key ( company_id )
        references shipments_companies ( id )
);

create table shipments (
    id                number generated always as identity,
    ship_id           number not null,
    berth_id          number not null,
    departure_port_id number not null,
    arrival_port_id   number not null,
    voyage_number     varchar2(20) not null,
    departure_date    timestamp not null,
    arrival_date      timestamp not null,
    distance_nm       number not null, 
    transport_type    varchar2(30) not null, 
    status            varchar2(30) not null, 
    is_international  number(1) not null,
    constraint pk_shipments primary key ( id ),
    constraint fk_shipments_ship foreign key ( ship_id )
        references ships ( id ),
    constraint fk_shipments_port_berth foreign key ( berth_id )
        references ports ( id ),
    constraint fk_shipments_dock_dept foreign key ( departure_port_id )
        references docks ( id ),
    constraint fk_shipments_dock_arr foreign key ( arrival_port_id )
        references docks ( id ),
    constraint uq_shipment_voyage unique ( voyage_number, ship_id ),
    constraint ck_shipments_dist check ( distance_nm >= 0 ),
    constraint ck_shipments_intl check ( is_international in ( 0, 1 ) ),
    constraint ck_shipments_dates check ( arrival_date > departure_date ),
    constraint ck_shipments_route check ( departure_port_id <> arrival_port_id )
);

create table cargo_taxes (
    id             number generated always as identity,
    container_id   number not null,
    shipment_id    number not null,
    storage_pos    varchar2(20) not null,
    loading_date   timestamp not null,
    tax_amount     number(10, 2) not null,
    constraint pk_cargo_taxes primary key ( id ),
    constraint fk_taxes_container foreign key ( container_id )
        references cargo_containers ( id ),
    constraint fk_taxes_shipment foreign key ( shipment_id )
        references shipments ( id ),
    constraint uq_tax_cont_ship unique ( container_id, shipment_id )
);

create table crew_ship_mapping (
    member_id    number not null,
    shipment_id  number not null,
    constraint pk_crew_ship_map primary key ( member_id, shipment_id ),
    constraint fk_csm_member foreign key ( member_id )
        references ship_crew ( id ),
    constraint fk_csm_shipment foreign key ( shipment_id )
        references shipments ( id )
);

-- 2 - Generating + Insterting

begin
   dbms_random.seed(13);
end;
/

INSERT INTO shipments_companies (name, scac_code, imo_company_num, country_of_origin) 
VALUES ('Maersk Line', 'MAEU', '0001234', 'Denmark');

INSERT INTO shipments_companies (name, scac_code, imo_company_num, country_of_origin) 
VALUES ('MSC', 'MSCU', '0005678', 'Switzerland');

INSERT INTO shipments_companies (name, scac_code, imo_company_num, country_of_origin) 
VALUES ('CMA CGM', 'CMDU', '0009012', 'France');

INSERT INTO shipments_companies (name, scac_code, imo_company_num, country_of_origin) 
VALUES ('Hapag-Lloyd', 'HLAG', '1234567', 'Germany');

INSERT INTO shipments_companies (name, scac_code, imo_company_num, country_of_origin) 
VALUES ('Ocean Network Express', 'ONEY', '7654321', 'Japan');

insert into ports (
    berth_number,
    type
)
select 
    'B-' || to_char(level, 'FM000') as berth_number,
    case
        when mod(level, 4) = 0 then 'Container Terminal'
        when mod(level, 4) = 1 then 'Bulk Carrier'
        when mod(level, 4) = 2 then 'Ro-Ro (Roll-on/Roll-off)'
        else 'Tanker / Liquid Bulk'
    end as type
from dual
connect by level <= 25;

INSERT INTO docks (name, un_locode, city, country, continent) 
VALUES ('Port of Singapore', 'SGSIN', 'Singapore', 'Singapore', 'Asia');

INSERT INTO docks (name, un_locode, city, country, continent) 
VALUES ('Port of Shanghai', 'CNSHA', 'Shanghai', 'China', 'Asia');

INSERT INTO docks (name, un_locode, city, country, continent) 
VALUES ('Port of Busan', 'KRPUS', 'Busan', 'South Korea', 'Asia');

INSERT INTO docks (name, un_locode, city, country, continent) 
VALUES ('Port of Jebel Ali', 'AEJEA', 'Dubai', 'UAE', 'Asia');

INSERT INTO docks (name, un_locode, city, country, continent) 
VALUES ('Port of Tanjung Pelepas', 'MYTPP', 'Johor', 'Malaysia', 'Asia');

INSERT INTO docks (name, un_locode, city, country, continent) 
VALUES ('Port of Rotterdam', 'NLRTM', 'Rotterdam', 'Netherlands', 'Europe');

INSERT INTO docks (name, un_locode, city, country, continent) 
VALUES ('Port of Hamburg', 'DEHAM', 'Hamburg', 'Germany', 'Europe');

INSERT INTO docks (name, un_locode, city, country, continent) 
VALUES ('Port of Felixstowe', 'GBFXT', 'Felixstowe', 'UK', 'Europe');

INSERT INTO docks (name, un_locode, city, country, continent) 
VALUES ('Port of Antwerp-Bruges', 'BEANT', 'Antwerp', 'Belgium', 'Europe');

INSERT INTO docks (name, un_locode, city, country, continent) 
VALUES ('Port of Valencia', 'ESVLC', 'Valencia', 'Spain', 'Europe');
INSERT INTO docks (name, un_locode, city, country, continent) 
VALUES ('Port of Los Angeles', 'USLAX', 'Los Angeles', 'USA', 'North America');

INSERT INTO docks (name, un_locode, city, country, continent) 
VALUES ('Port of Santos', 'BRSSZ', 'Santos', 'Brazil', 'South America');

INSERT INTO docks (name, un_locode, city, country, continent) 
VALUES ('Port of New York and New Jersey', 'USNYC', 'New York', 'USA', 'North America');

INSERT INTO docks (name, un_locode, city, country, continent) 
VALUES ('Port of Manzanillo', 'MXZLO', 'Manzanillo', 'Mexico', 'North America');

INSERT INTO docks (name, un_locode, city, country, continent) 
VALUES ('Port of Buenos Aires', 'ARBUE', 'Buenos Aires', 'Argentina', 'South America');


INSERT INTO cargo_containers (serial_number, container_type, owner_country, max_payload)
SELECT 
    DBMS_RANDOM.STRING('U', 3) || 'U' || TRUNC(DBMS_RANDOM.VALUE(1000000, 9999999)) AS serial_number,
    CASE TRUNC(DBMS_RANDOM.VALUE(0, 4))
        WHEN 0 THEN '20ft Dry'
        WHEN 1 THEN '40ft Dry'
        WHEN 2 THEN '40ft Reefer'
        ELSE '40ft High Cube'
    END AS container_type,
    CASE TRUNC(DBMS_RANDOM.VALUE(0, 5))
        WHEN 0 THEN 'USA'
        WHEN 1 THEN 'China'
        WHEN 2 THEN 'Germany'
        WHEN 3 THEN 'Denmark'
        ELSE 'Singapore'
    END AS owner_country,
    CASE TRUNC(DBMS_RANDOM.VALUE(0, 4))
        WHEN 0 THEN 21800 
        WHEN 1 THEN 26600 
        WHEN 2 THEN 29000
        ELSE 28000
    END AS max_payload
FROM dual
CONNECT BY level <= 50;

INSERT INTO ships (company_id, imo_number, ship_name, build_year, teu_capacity, gross_tonnage, tank_capacity, fuel_type)
SELECT 
    c.id,
    'IMO' || TRUNC(DBMS_RANDOM.VALUE(7000000, 9999999)) AS imo_number,
    SUBSTR(c.name, 1, 3) || '-' || DBMS_RANDOM.STRING('U', 2) || '-' || TRUNC(DBMS_RANDOM.VALUE(1, 99)) AS ship_name,
    TRUNC(DBMS_RANDOM.VALUE(2005, 2025)) AS build_year,
    CASE 
        WHEN TRUNC(DBMS_RANDOM.VALUE(0, 10)) > 7 THEN TRUNC(DBMS_RANDOM.VALUE(15000, 24000))
        ELSE TRUNC(DBMS_RANDOM.VALUE(4000, 14000)) 
    END AS teu_capacity,
    TRUNC(DBMS_RANDOM.VALUE(30000, 200000)) AS gross_tonnage,
    TRUNC(DBMS_RANDOM.VALUE(1000, 10000)) AS tank_capacity,
    CASE MOD(gen.lvl, 3)                
        WHEN 0 THEN 'LNG'                
        WHEN 1 THEN 'LSFO'                 
        ELSE 'Hybrid'                
    END AS fuel_type                
FROM shipments_companies c
CROSS JOIN (SELECT LEVEL AS lvl FROM dual CONNECT BY LEVEL <= 5) gen;

INSERT INTO ship_crew (company_id, first_name, last_name, role, nationality)
SELECT 
    c.id,
    'FN' || gen.lvl || '_' || c.scac_code AS first_name,
    'LN' || gen.lvl AS last_name,                
    -- Distribute roles realistically
    CASE TRUNC(DBMS_RANDOM.VALUE(0, 5))                
        WHEN 0 THEN 'Captain'                
        WHEN 1 THEN 'Chief Engineer'                
        WHEN 2 THEN 'First Officer'                
        WHEN 3 THEN 'Deckhand'                
        ELSE 'Technician'                
    END AS role,                
    -- Randomly assign nationalities
    CASE TRUNC(DBMS_RANDOM.VALUE(0, 5))                
        WHEN 0 THEN 'Filipino'                
        WHEN 1 THEN 'Indian'                
        WHEN 2 THEN 'Greek'                
        WHEN 3 THEN 'Chinese'                
        ELSE 'Ukrainian'                
    END AS nationality                
FROM shipments_companies c
CROSS JOIN (SELECT LEVEL AS lvl FROM dual CONNECT BY LEVEL <= 10) gen;

DECLARE
    v_ship_id          ships.id%TYPE;
    v_berth_id         ports.id%TYPE;
    v_dep_dock_id      docks.id%TYPE;
    v_arr_dock_id      docks.id%TYPE;
    v_tara_plecare     docks.country%TYPE;
    v_tara_sosire      docks.country%TYPE;
    v_dep_date         timestamp;
    v_arr_date         timestamp;
    v_dist             number;
    v_transport_type   varchar2(30);
    v_status           varchar2(30);
    v_intl             number(1);
BEGIN
    FOR i IN 1..100 LOOP
        SELECT id INTO v_ship_id
        FROM (SELECT id FROM ships ORDER BY dbms_random.value)
        WHERE rownum = 1;

        SELECT id INTO v_berth_id
        FROM (SELECT id FROM ports ORDER BY dbms_random.value)
        WHERE rownum = 1;

        SELECT id, country INTO v_dep_dock_id, v_tara_plecare
        FROM (SELECT id, country FROM docks ORDER BY dbms_random.value)
        WHERE rownum = 1;
        LOOP
            SELECT id, country INTO v_arr_dock_id, v_tara_sosire
            FROM (SELECT id, country FROM docks ORDER BY dbms_random.value)
            WHERE rownum = 1;
            
            EXIT WHEN v_arr_dock_id <> v_dep_dock_id;
        END LOOP;
        v_intl := CASE WHEN v_tara_plecare = v_tara_sosire THEN 0 ELSE 1 END;
        v_transport_type := 'Container';
        v_status := CASE 
                        WHEN dbms_random.value < 0.7 THEN 'in_transit'
                        WHEN dbms_random.value < 0.9 THEN 'delayed'
                        ELSE 'docked'
                    END;
        v_dist := TRUNC(dbms_random.value(500, 8000));
        v_dep_date := SYSDATE - TRUNC(dbms_random.value(0, 60)); -- Departed in last 60 days
        v_arr_date := v_dep_date + numtodsinterval(TRUNC(dbms_random.value(5, 20)), 'DAY');
        INSERT INTO shipments (
            ship_id, berth_id, departure_port_id, arrival_port_id, 
            voyage_number, departure_date, arrival_date, 
            distance_nm, transport_type, status, is_international
        ) VALUES (
            v_ship_id, v_berth_id, v_dep_dock_id, v_arr_dock_id,
            'VOY' || TO_CHAR(i, 'FM0000'), 
            v_dep_date, v_arr_date,
            v_dist, v_transport_type, v_status, v_intl
        );
    END LOOP;
    
    COMMIT;
END;
/

DECLARE
    v_captain_id   ship_crew.id%TYPE;
    v_engineer_id  ship_crew.id%TYPE;
    v_deckhand_id  ship_crew.id%TYPE;
BEGIN
    FOR f IN (
        SELECT 
            sh.id AS shipment_id,                
            s.company_id
        FROM shipments sh                
        JOIN ships s ON sh.ship_id = s.id
    ) LOOP
        BEGIN
            SELECT id INTO v_captain_id
            FROM (
                SELECT m.id
                FROM ship_crew m
                WHERE m.company_id = f.company_id
                  AND m.role = 'Captain'
                ORDER BY dbms_random.value
            )
            WHERE rownum = 1;

            INSERT INTO crew_ship_mapping (member_id, shipment_id) 
            VALUES (v_captain_id, f.shipment_id);
        EXCEPTION WHEN NO_DATA_FOUND THEN NULL;
        END;
        BEGIN
            SELECT id INTO v_engineer_id
            FROM (
                SELECT m.id
                FROM ship_crew m
                WHERE m.company_id = f.company_id
                  AND m.role = 'Chief Engineer'
                  AND m.id <> v_captain_id
                ORDER BY dbms_random.value
            )
            WHERE rownum = 1;

            INSERT INTO crew_ship_mapping (member_id, shipment_id) 
            VALUES (v_engineer_id, f.shipment_id);
        EXCEPTION WHEN NO_DATA_FOUND THEN NULL;
        END;

        BEGIN
            SELECT id INTO v_deckhand_id
            FROM (
                SELECT m.id
                FROM ship_crew m
                WHERE m.company_id = f.company_id
                  AND m.role = 'Deckhand'
                  AND m.id NOT IN (v_captain_id, v_engineer_id)
                ORDER BY dbms_random.value
            )
            WHERE rownum = 1;

            INSERT INTO crew_ship_mapping (member_id, shipment_id) 
            VALUES (v_deckhand_id, f.shipment_id);
        EXCEPTION WHEN NO_DATA_FOUND THEN NULL;
        END;

    END LOOP;
    
    COMMIT;
END;
/

INSERT INTO cargo_taxes (
    container_id,
    shipment_id,
    storage_pos,
    loading_date,
    tax_amount
)                
WITH containers AS (
    SELECT id AS container_id FROM cargo_containers
),
shipments_data AS (
    SELECT id AS shipment_id, departure_date FROM shipments
),
mapping AS (
    SELECT 
        c.container_id,
        s.shipment_id,
        s.departure_date
    FROM containers c
    CROSS JOIN shipments_data s                
    WHERE DBMS_RANDOM.VALUE < 0.5
)
SELECT 
    m.container_id,
    m.shipment_id,
    TRUNC(DBMS_RANDOM.VALUE(1, 90)) || '-' || 
    TRUNC(DBMS_RANDOM.VALUE(1, 12)) || '-' || 
    TRUNC(DBMS_RANDOM.VALUE(1, 8)) AS storage_pos,                
    m.departure_date - NUMTODSINTERVAL(TRUNC(DBMS_RANDOM.VALUE(1, 48)), 'HOUR') AS loading_date,
    ROUND(DBMS_RANDOM.VALUE(100, 5000), 2) AS tax_amount
FROM mapping m;

select *
  from shipments;
select *
  from docks;


begin
   for t in (
      select table_name
        from user_tables
   ) loop
      execute immediate 'GRANT SELECT ON app_user_oltp.'
                        || t.table_name
                        || ' TO app_user_dw';
   end loop;
end;
/

--BEGIN
--  FOR t IN (
--    SELECT table_name
--    FROM user_tables
--  ) LOOP
--    EXECUTE IMMEDIATE
--      'DROP TABLE ' || t.table_name || ' CASCADE CONSTRAINTS';
--  END LOOP;
--END;
--/