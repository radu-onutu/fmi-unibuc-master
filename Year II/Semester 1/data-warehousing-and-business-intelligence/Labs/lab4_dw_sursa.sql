-- lab 4 DW
-- INDECSI
  
ALTER SESSION SET "_optimizer_gather_stats_on_load"=FALSE;

--1
--a
DESC user_tables

SELECT table_name, num_rows, last_analyzed
FROM   user_tables
WHERE  table_name = ...;

ANALYZE TABLE ... COMPUTE STATISTICS;

SELECT table_name, num_rows, last_analyzed
FROM   user_tables
WHERE  table_name = ...;

--b
SELECT constraint_name, constraint_type, 
       status, index_name
FROM   user_constraints
WHERE  table_name = ...;

/*
ALTER TABLE ...
ADD CONSTRAINT ...
PRIMARY KEY(...) ENABLE NOVALIDATE;

ALTER TABLE ...
ENABLE PRIMARY KEY;
*/

SELECT constraint_name, constraint_type, 
       status, index_name
FROM   user_constraints
WHERE  table_name = ...;


--c
EXPLAIN PLAN 
SET STATEMENT_ID = 's1_c_***' 
FOR 
...;

--cost = ...
SELECT plan_table_output 
FROM 
table(dbms_xplan.display('plan_table', 's1_c_***','serial'));

--d
CREATE INDEX ind_clienti_tip_***
ON ...;

ANALYZE INDEX ind_clienti_tip_*** COMPUTE STATISTICS;

EXPLAIN PLAN 
SET STATEMENT_ID = 's1_d1_***' 
FOR 
SELECT /*+ INDEX(alias_tabel? ind_clienti_tip_***) */
…;

--cost = ...
SELECT plan_table_output 
FROM 
table(dbms_xplan.display('plan_table', 's1_d1_***','serial'));

--fara hint
EXPLAIN PLAN 
SET STATEMENT_ID = 's1_d2_***' 
FOR 
…;

--cost = ...
SELECT plan_table_output 
FROM 
table(dbms_xplan.display('plan_table', 's1_d2_***','serial'));
--cost = ...
SELECT plan_table_output 
FROM 
table(dbms_xplan.display('plan_table', 's1_d1_***','serial'));

--e
--explicatii

--f
EXPLAIN PLAN 
SET STATEMENT_ID = 's1_f_***' 
FOR 
...;

--cost = ...
SELECT plan_table_output 
FROM 
table(dbms_xplan.display('plan_table', 's1_f_***','serial'));

--g
ALTER TABLE ...
DISABLE PRIMARY KEY;

--cost = ...
EXPLAIN PLAN 
SET STATEMENT_ID = 's1_g1_***' 
FOR 
...;

--cost=
SELECT plan_table_output 
FROM 
table(dbms_xplan.display('plan_table', 's1_g1_***','serial'));

--cu hint
EXPLAIN PLAN 
SET STATEMENT_ID = 's1_g2_***' 
FOR 
select /*+index(alias_tabel? ind_clienti_tip_***) */
...;

--cost=...
SELECT plan_table_output 
FROM 
table(dbms_xplan.display('plan_table', 's1_g2_***','serial'));

--h
DROP INDEX ind_clienti_tip_***;

--i

CREATE BITMAP INDEX bmp_clienti_tip_***
ON ...;

ANALYZE INDEX  bmp_clienti_tip_*** COMPUTE STATISTICS;

EXPLAIN PLAN 
SET STATEMENT_ID = 's1_i1_***' 
FOR 
SELECT /*+INDEX(alias_tabel? bmp_clienti_tip_***) */
...;

--cost= 
SELECT plan_table_output 
FROM 
table(dbms_xplan.display('plan_table', 's1_i1_***','serial'));

--fara hint
EXPLAIN PLAN 
SET STATEMENT_ID = 's1_i2_***' 
FOR 
...;

--cost= 
SELECT plan_table_output 
FROM 
table(dbms_xplan.display('plan_table', 's1_i2_***','serial'));

--j
--explicatii

--k
EXPLAIN PLAN 
SET STATEMENT_ID = 's1_k1_***' 
FOR 
SELECT /*+INDEX(alias_tabel? bmp_clienti_tip_***) */
...;

--cost= 
SELECT plan_table_output 
FROM 
table(dbms_xplan.display('plan_table', 's1_k1_***','serial'));

--fara hint
EXPLAIN PLAN 
SET STATEMENT_ID = 's1_k2_***' 
FOR 
...;

--cost= 
SELECT plan_table_output 
FROM 
table(dbms_xplan.display('plan_table', 's1_k2_***','serial'));

--l
ALTER TABLE ...
ENABLE PRIMARY KEY;

ALTER TABLE ...
ADD CONSTRAINT fk_vanzari_clienti_***
FOREIGN KEY(...)
REFERENCES ...(...)
ENABLE NOVALIDATE;

EXPLAIN PLAN 
SET STATEMENT_ID = 's1_l_***' 
FOR 
...;

--cost= 
SELECT plan_table_output 
FROM 
table(dbms_xplan.display('plan_table', 's1_l_***','serial'));


--2
DESC produse_***

--a
SELECT table_name, num_rows, last_analyzed
FROM   user_tables
WHERE  table_name = ...;

ANALYZE TABLE ... COMPUTE STATISTICS;

SELECT table_name, num_rows, last_analyzed
FROM   user_tables
WHERE  table_name = ...;

--b
EXPLAIN PLAN 
SET STATEMENT_ID = 's2_b_***' 
FOR 
...;

--cost= 
SELECT plan_table_output 
FROM 
table(dbms_xplan.display('plan_table', 's2_b_***','serial'));

--c
CREATE INDEX ind_produse_greutate_***
ON ... (...);

EXPLAIN PLAN 
SET STATEMENT_ID = 's2_c1_***' 
FOR 
...;

--cost= 
SELECT plan_table_output 
FROM 
table(dbms_xplan.display('plan_table', 's2_c1_***','serial'));

ANALYZE INDEX ind_produse_greutate_*** COMPUTE STATISTICS;

EXPLAIN PLAN 
SET STATEMENT_ID = 's2_c2_***' 
FOR 
...;

--cost= 
SELECT plan_table_output 
FROM 
table(dbms_xplan.display('plan_table', 's2_c2_***','serial'));

--cu hint
EXPLAIN PLAN 
SET STATEMENT_ID = 's2_c3_***' 
FOR
SELECT /*+ index(alias_tabel? ind_produse_greutate_***)  */
...;

SELECT plan_table_output 
FROM 
table(dbms_xplan.display('plan_table', 's2_c3_***','serial'));

--d
DROP INDEX ind_produse_greutate_***;

--e
CREATE BITMAP INDEX bmp_produse_greutate_***
ON ... (...);

ANALYZE INDEX bmp_produse_greutate_*** COMPUTE STATISTICS;

EXPLAIN PLAN 
SET STATEMENT_ID = 's2_e_***' 
FOR 
...;

--cost= 
SELECT plan_table_output 
FROM 
table(dbms_xplan.display('plan_table', 's2_e_***','serial'));

--f
EXPLAIN PLAN 
SET STATEMENT_ID = 's2_f_***' 
FOR 
...;

--cost= 
SELECT plan_table_output 
FROM 
table(dbms_xplan.display('plan_table', 's2_f_***','serial'));

--g
--constrangerile erau sunt deja definite?
SELECT constraint_name, constraint_type, 
       status, index_name
FROM   user_constraints
WHERE  table_name IN ( ...);

--NU => atunci le adaugam si verificam planul de executie
ALTER TABLE ...
ADD CONSTRAINT pk_produs_*** PRIMARY KEY(...)
ENABLE NOVALIDATE;

ALTER TABLE ...
ADD CONSTRAINT fk_vanzari_produse_*** 
FOREIGN KEY(...)
REFERENCES ...(...)
ENABLE NOVALIDATE;

EXPLAIN PLAN 
SET STATEMENT_ID = 's2_g1_***' 
FOR 
...;

--cost= 
SELECT plan_table_output 
FROM 
table(dbms_xplan.display('plan_table', 's2_g1_***','serial'));


--constrangerile erau sunt deja definite?
--DA => atunci le dezactivam si verificam planul de executie
ALTER TABLE ...
MODIFY CONSTRAINT fk_vanzari_produse_***
DISABLE NOVALIDATE;

ALTER TABLE ...
MODIFY CONSTRAINT pk_produs_***
DISABLE NOVALIDATE;

EXPLAIN PLAN 
SET STATEMENT_ID = 's2_g2_***' 
FOR 
...;

--cost= 
SELECT plan_table_output 
FROM 
table(dbms_xplan.display('plan_table', 's2_g2_***','serial'));

--3
DESC plati_***

--a
EXPLAIN PLAN
SET STATEMENT_ID = 's3_a_***'
FOR ...;

--cost=
SELECT plan_table_output
FROM
table(dbms_xplan.display('plan_table', 's3_a_***','serial'));


--b
CREATE BITMAP INDEX ind_bmp_join_vanz_plati_***
ON vanzari_*** (cod)
FROM vanzari_*** v, plati_*** p
WHERE p.id_plata = v.plata_id;

--c
SELECT CONSTRAINT_NAME, CONSTRAINT_TYPE, STATUS, INDEX_NAME
FROM   USER_CONSTRAINTS
WHERE  TABLE_NAME = UPPER ('plati_***');

ALTER TABLE ...
ADD CONSTRAINT pk_plati_***
PRIMARY KEY(...) ENABLE VALIDATE;

--d
CREATE BITMAP INDEX ind_bmp_join_vanz_plati_***
ON vanzari_*** (cod)
FROM vanzari_*** v, plati_*** p
WHERE p.id_plata = v.plata_id;

ANALYZE INDEX ind_bmp_join_vanz_plati_*** COMPUTE STATISTICS;

--e
EXPLAIN PLAN
SET STATEMENT_ID = 's3_e1_***'
FOR
...;

--cost=
SELECT plan_table_output
FROM
table(dbms_xplan.display('plan_table', 's3_e1_***','serial'));

--cu hint
EXPLAIN PLAN
SET STATEMENT_ID = 's3_e2_***'
FOR
SELECT /*+index(alias_tabel? ind_bmp_join_vanz_plati_*** ) */ 
...;

SELECT plan_table_output
FROM
table(dbms_xplan.display('plan_table', 's3_e2_***','serial'));

--f
CREATE TABLE vanzari_factura_***
(factura number(10) 
         constraint pk_vanzari_factura_*** 
         primary key rely disable novalidate, 
client_id number(4)
          constraint fk_vanzari_fact_clienti_***
          references clienti_*** (id_client)
          rely disable novalidate, 
timp_id date
        --  constraint fk_vanzari_fact_timp_***
        --  references timp_*** (id_timp)
        --  rely disable novalidate
         , 
plata_id number(4)
          constraint fk_vanzari_fact_plati_***
          references plati_*** (id_plata)
          disable novalidate, 
valoare_totala number not null);

DESC vanzari_factura_***

INSERT INTO vanzari_factura_***
SELECT ....
COMMIT;

EXPLAIN PLAN
SET STATEMENT_ID = 's3_f1_***'
FOR
...;

--cost=
SELECT plan_table_output
FROM
table(dbms_xplan.display('plan_table', 's3_f1_***','serial'));

CREATE BITMAP INDEX bmp_join_vanz_plati_***
ON vanzari_factura_*** (cod)
FROM vanzari_factura_*** v, plati_*** p
WHERE p.id_plata = v.plata_id;

ANALYZE INDEX bmp_join_vanz_plati_***
COMPUTE STATISTICS;

EXPLAIN PLAN
SET STATEMENT_ID = 's3_f2_***'
FOR
...;

--cost=
SELECT plan_table_output
FROM
table(dbms_xplan.display('plan_table', 's3_f2_***','serial'));

--4
--a
EXPLAIN PLAN
SET STATEMENT_ID = 's4_a_***'
FOR
...;

--cost=
SELECT plan_table_output
FROM
table(dbms_xplan.display('plan_table', 's4_a_***','serial'));

--b
CREATE BITMAP INDEX bmp_fk_vanz_clienti_***
ON ...(...);
ANALYZE INDEX bmp_fk_vanz_clienti_*** 
COMPUTE STATISTICS;

CREATE BITMAP INDEX bmp_fk_vanz_timp_***
ON ...(...);
ANALYZE INDEX bmp_fk_vanz_timp_*** 
COMPUTE STATISTICS;

CREATE BITMAP INDEX bmp_fk_vanz_produse_***
ON ...(...);
ANALYZE INDEX bmp_fk_vanz_produse_*** 
COMPUTE STATISTICS;

--c
ALTER SESSION
SET STAR_TRANSFORMATION_ENABLED = true;

--d
EXPLAIN PLAN
SET STATEMENT_ID ='s4_d1_***' FOR
SELECT /*+ STAR_TRANSFORMATION */
       /*+ FACT(alias_tabel?_fapte)*/
...;

--cost=
SELECT plan_table_output 
FROM 
table(dbms_xplan.display('plan_table', 's4_d1_***','serial'));

--fara hint
EXPLAIN PLAN
SET STATEMENT_ID ='s4_d2_***' FOR
...;

--cost=
SELECT plan_table_output 
FROM 
table(dbms_xplan.display('plan_table', 's4_d2_***','serial'));

--5
DESC user_indexes

SELECT table_name, index_name, index_type, 
       uniqueness, join_index, 
       distinct_keys, num_rows, last_analyzed
FROM   user_indexes
WHERE  table_name like upper('%***')
ORDER BY 1,3;






