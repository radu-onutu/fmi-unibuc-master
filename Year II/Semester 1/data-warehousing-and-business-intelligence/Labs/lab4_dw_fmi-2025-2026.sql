-- lab 4 DW
-- INDECSI
  
ALTER SESSION 
SET "_optimizer_gather_stats_on_load"=FALSE;

--1
--a
DESC user_tables

SELECT table_name, num_rows, last_analyzed
FROM   user_tables
WHERE  table_name = upper('clienti_***');

ANALYZE TABLE clienti_*** COMPUTE STATISTICS;

SELECT table_name, num_rows, last_analyzed
FROM   user_tables
WHERE  table_name = upper('clienti_***');

--b
SELECT constraint_name, constraint_type, 
       status, index_name
FROM   user_constraints
WHERE  table_name = upper('clienti_***');

/*
ALTER TABLE ...
ADD CONSTRAINT ...
PRIMARY KEY(...) ENABLE NOVALIDATE;

ALTER TABLE ...
ENABLE PRIMARY KEY;
*/
ALTER TABLE clienti_***
ENABLE PRIMARY KEY;

SELECT constraint_name, constraint_type, 
       status, index_name
FROM   user_constraints
WHERE  table_name = upper('clienti_***');

--c
select count(*) from clienti_***;
select count(*) from clienti_***
where  tip='pf';

--varianta 1
--cost=4
select pf.nr_pf,
       round(pf.nr_pf/t.nr_total*100,2) as procent
from 
(select count(*) nr_total from clienti_***) t,
(select count(*) nr_pf from clienti_***
where  tip='pf') pf;

--varianta 2
--cost=4
select pf.nr_pf,
    round(pf.nr_pf/
    (select count(*) nr_total 
     from clienti_***)*100,2) as procent
from 
(select count(*) nr_pf from clienti_***
where  tip='pf') pf;

--aleg varianta 2

EXPLAIN PLAN 
SET STATEMENT_ID = 's1_c_***' 
FOR 
select pf.nr_pf,
    round(pf.nr_pf/
    (select count(*) nr_total 
     from clienti_***)*100,2) as procent
from 
(select count(*) nr_pf from clienti_***
where  tip='pf') pf;

--cost = 4
SELECT plan_table_output 
FROM 
table(dbms_xplan.display('plan_table', 's1_c_***','serial'));

--d
CREATE INDEX ind_clienti_tip_***
ON clienti_***(tip);

ANALYZE INDEX ind_clienti_tip_*** COMPUTE STATISTICS;

EXPLAIN PLAN 
SET STATEMENT_ID = 's1_d1_***' 
FOR 
SELECT /*+ INDEX(pf ind_clienti_tip_***) */
     pf.nr_pf,
    round(pf.nr_pf/
    (select count(*) nr_total 
     from clienti_***)*100,2) as procent
from 
(select count(*) nr_pf from clienti_***
where  tip='pf') pf;

--cost = 2
SELECT plan_table_output 
FROM 
table(dbms_xplan.display('plan_table', 's1_d1_***','serial'));

--fara hint
EXPLAIN PLAN 
SET STATEMENT_ID = 's1_d2_***' 
FOR 
SELECT 
     pf.nr_pf,
    round(pf.nr_pf/
    (select count(*) nr_total 
     from clienti_***)*100,2) as procent
from 
(select count(*) nr_pf from clienti_***
where  tip='pf') pf;

--cost = 2
SELECT plan_table_output 
FROM 
table(dbms_xplan.display('plan_table', 's1_d2_***','serial'));
--cost = 2
SELECT plan_table_output 
FROM 
table(dbms_xplan.display('plan_table', 's1_d1_***','serial'));

--e
--explicatii

--f
EXPLAIN PLAN 
SET STATEMENT_ID = 's1_f_***' 
FOR 
SELECT 
     pf.nr_pf,
    round(pf.nr_pf/
    (select count(id_client) nr_total 
     from clienti_***)*100,2) as procent
from 
(select count(id_client) nr_pf from clienti_***
where  tip='pf') pf;


--cost = 2
SELECT plan_table_output 
FROM 
table(dbms_xplan.display('plan_table', 's1_f_***','serial'));

--g
ALTER TABLE clienti_***
DISABLE PRIMARY KEY;

EXPLAIN PLAN 
SET STATEMENT_ID = 's1_g1_***' 
FOR 
SELECT 
     pf.nr_pf,
    round(pf.nr_pf/
    (select count(id_client) nr_total 
     from clienti_***)*100,2) as procent
from 
(select count(id_client) nr_pf from clienti_***
where  tip='pf') pf;

--cost=6
SELECT plan_table_output 
FROM 
table(dbms_xplan.display('plan_table', 's1_g1_***','serial'));

--cu hint
EXPLAIN PLAN 
SET STATEMENT_ID = 's1_g2_***' 
FOR 
select /*+index(pf ind_clienti_tip_***) */
     pf.nr_pf,
    round(pf.nr_pf/
    (select count(id_client) nr_total 
     from clienti_***)*100,2) as procent
from 
(select count(id_client) nr_pf from clienti_***
where  tip='pf') pf;

--cost=7
SELECT plan_table_output 
FROM 
table(dbms_xplan.display('plan_table', 's1_g2_***','serial'));

--tema
-- acelasi exemplu, dar cu count(*)

--h
DROP INDEX ind_clienti_tip_***;

--i
CREATE BITMAP INDEX bmp_clienti_tip_***
ON clienti_***(tip);

ANALYZE INDEX  bmp_clienti_tip_*** COMPUTE STATISTICS;

EXPLAIN PLAN 
SET STATEMENT_ID = 's1_i1_***' 
FOR 
SELECT /*+INDEX(pf bmp_clienti_tip_***) */
     pf.nr_pf,
    round(pf.nr_pf/
    (select count(*) nr_total 
     from clienti_***)*100,2) as procent
from 
(select count(*) nr_pf from clienti_***
where  tip='pf') pf;

--cost=2 
SELECT plan_table_output 
FROM 
table(dbms_xplan.display('plan_table', 's1_i1_***','serial'));

--fara hint
EXPLAIN PLAN 
SET STATEMENT_ID = 's1_i2_***' 
FOR 
SELECT 
     pf.nr_pf,
    round(pf.nr_pf/
    (select count(*) nr_total 
     from clienti_***)*100,2) as procent
from 
(select count(*) nr_pf from clienti_***
where  tip='pf') pf;

--cost=2 
SELECT plan_table_output 
FROM 
table(dbms_xplan.display('plan_table', 's1_i2_***','serial'));

--j
--explicatii

--k
--varianta 1
--cost=4024
desc vanzari_***
select valoare from vanzari_***;

select count(DISTINCT v.client_id) nr_pf,
       sum(v.valoare) valoare_totala
from  vanzari_*** v, clienti_*** c, timp_*** t
where v.client_id=c.id_client
and   v.timp_id=t.id_timp
and   t.luna=3
and   t.an=2007
and   c.tip='pf';

--varianta 2
--cost=4024 
--!!! sunt inclusi in rezultat toti clientii pf chiar dc nu au vanzari
select (select count(c.id_client)
        from clienti_*** c
        where c.tip='pf') nr_pf,
       (select sum(v.valoare) 
        from  vanzari_*** v, clienti_*** c, timp_*** t
        where v.client_id=c.id_client
        and   v.timp_id=t.id_timp
        and   t.luna=3
        and   t.an=2007
        and   c.tip='pf') valoare_totala
from dual;

--incerc sa modific varianta 1 a.i. sa aduca toti clientii
--varianta 1 completa, dar nu obtin rezultatul dorit
select count(DISTINCT v.client_id) nr_pf,
       sum(v.valoare) valoare_totala
from  vanzari_*** v, clienti_*** c, timp_*** t
where v.client_id(+)=c.id_client
and   v.timp_id=t.id_timp(+)
and   t.luna=3
and   t.an=2007
and   c.tip='pf';

--aleg varianta 2 care aduce toti clientii pf
EXPLAIN PLAN 
SET STATEMENT_ID = 's1_k1_***' 
FOR 
SELECT /*+INDEX(c bmp_clienti_tip_***) */
       (select count(c.id_client)
        from clienti_*** c
        where c.tip='pf') nr_pf,
       (select sum(v.valoare) 
        from  vanzari_*** v, clienti_*** c, timp_*** t
        where v.client_id=c.id_client
        and   v.timp_id=t.id_timp
        and   t.luna=3
        and   t.an=2007
        and   c.tip='pf') valoare_totala
from dual;

--cost=4024 => fara sa utilizeze bitmap 
SELECT plan_table_output 
FROM 
table(dbms_xplan.display('plan_table', 's1_k1_***','serial'));


EXPLAIN PLAN 
SET STATEMENT_ID = 's1_k2_***' 
FOR 
SELECT (select /*+INDEX(c bmp_clienti_tip_***) */
              count(c.id_client)
        from clienti_*** c
        where c.tip='pf') nr_pf,
       (select /*+INDEX(c bmp_clienti_tip_***) */
              sum(v.valoare) 
        from  vanzari_*** v, clienti_*** c, timp_*** t
        where v.client_id=c.id_client
        and   v.timp_id=t.id_timp
        and   t.luna=3
        and   t.an=2007
        and   c.tip='pf') valoare_totala
from dual;

--cost=4032 => fara sa utilizeze bitmap 
SELECT plan_table_output 
FROM 
table(dbms_xplan.display('plan_table', 's1_k2_***','serial'));

--fara hint
EXPLAIN PLAN 
SET STATEMENT_ID = 's1_k3_***' 
FOR 
SELECT (select 
              count(c.id_client)
        from clienti_*** c
        where c.tip='pf') nr_pf,
       (select 
              sum(v.valoare) 
        from  vanzari_*** v, clienti_*** c, timp_*** t
        where v.client_id=c.id_client
        and   v.timp_id=t.id_timp
        and   t.luna=3
        and   t.an=2007
        and   c.tip='pf') valoare_totala
from dual;

--cost=4024 
SELECT plan_table_output 
FROM 
table(dbms_xplan.display('plan_table', 's1_k3_***','serial'));

--l
ALTER TABLE clienti_***
ENABLE PRIMARY KEY;

/*
ALTER TABLE vanzari_***
ADD CONSTRAINT fk_vanzari_clienti_***
FOREIGN KEY(client_id)
REFERENCES clienti_***(id_client)
ENABLE NOVALIDATE;
*/

ALTER TABLE vanzari_***
modify CONSTRAINT fk_vanzari_clienti_***
ENABLE NOVALIDATE;

EXPLAIN PLAN 
SET STATEMENT_ID = 's1_l_***' 
FOR 
SELECT (select 
              count(c.id_client)
        from clienti_*** c
        where c.tip='pf') nr_pf,
       (select 
              sum(v.valoare) 
        from  vanzari_*** v, clienti_*** c, timp_*** t
        where v.client_id=c.id_client
        and   v.timp_id=t.id_timp
        and   t.luna=3
        and   t.an=2007
        and   c.tip='pf') valoare_totala
from dual;


--cost=4021 
SELECT plan_table_output 
FROM 
table(dbms_xplan.display('plan_table', 's1_l_***','serial'));


--!!!Aici am ramas!!!!
--2
DESC produse_***

--a
SELECT table_name, num_rows, last_analyzed
FROM   user_tables
WHERE  table_name = upper('produse_***');

ANALYZE TABLE produse_*** COMPUTE STATISTICS;

SELECT table_name, num_rows, last_analyzed
FROM   user_tables
WHERE  table_name = upper('produse_***');

--b
select count(*)
from   produse_***
where greutate is null;

select count(distinct greutate),count(greutate),count(*)
from  produse_***;

EXPLAIN PLAN 
SET STATEMENT_ID = 's2_b_***' 
FOR 
select count(*)
from   produse_***
where greutate is null;

--cost= 69
SELECT plan_table_output 
FROM 
table(dbms_xplan.display('plan_table', 's2_b_***','serial'));

--c
-- aleg gresit index b-tree in contextul "valori null"
CREATE INDEX ind_produse_greutate_***
ON produse_*** (greutate);

EXPLAIN PLAN 
SET STATEMENT_ID = 's2_c1_***' 
FOR 
select count(*)
from   produse_***
where greutate is null;

--cost=69 
SELECT plan_table_output 
FROM 
table(dbms_xplan.display('plan_table', 's2_c1_***','serial'));

ANALYZE INDEX ind_produse_greutate_*** COMPUTE STATISTICS;

EXPLAIN PLAN 
SET STATEMENT_ID = 's2_c2_***' 
FOR 
select count(*)
from   produse_***
where greutate is null;

--cost=69 
SELECT plan_table_output 
FROM 
table(dbms_xplan.display('plan_table', 's2_c2_***','serial'));

--cu hint
EXPLAIN PLAN 
SET STATEMENT_ID = 's2_c3_***' 
FOR
SELECT /*+ index(p ind_produse_greutate_***)*/
       count(*)
from   produse_*** p
where greutate is null;

SELECT plan_table_output 
FROM 
table(dbms_xplan.display('plan_table', 's2_c3_***','serial'));

--d
DROP INDEX ind_produse_greutate_***;

--e
--aleg gresit bitmap pt ca greutate nu are cardinalitate
--distincta mica, dar verificam dc se indexeaza valori null
CREATE BITMAP INDEX bmp_produse_greutate_***
ON produse_*** (greutate);

ANALYZE INDEX bmp_produse_greutate_*** COMPUTE STATISTICS;

EXPLAIN PLAN 
SET STATEMENT_ID = 's2_e_***' 
FOR 
select  count(*)
from   produse_*** p
where greutate is null;

--cost=1 
SELECT plan_table_output 
FROM 
table(dbms_xplan.display('plan_table', 's2_e_***','serial'));

--f
select count(distinct c.id_client),sum(v.valoare)
from   clienti_*** c, vanzari_*** v, timp_*** t,
       produse_*** p
where  v.client_id=c.id_client
and    v.timp_id=t.id_timp
and    v.produs_id=p.id_produs
and    c.tip='pf'
and    t.luna=3
and    t.an=2007
and    p.greutate is null;

EXPLAIN PLAN 
SET STATEMENT_ID = 's2_f_***' 
FOR 
select count(distinct c.id_client),sum(v.valoare)
from   clienti_*** c, vanzari_*** v, timp_*** t,
       produse_*** p
where  v.client_id=c.id_client
and    v.timp_id=t.id_timp
and    v.produs_id=p.id_produs
and    c.tip='pf'
and    t.luna=3
and    t.an=2007
and    p.greutate is null;

--cost=4035 
SELECT plan_table_output 
FROM 
table(dbms_xplan.display('plan_table', 's2_f_***','serial'));

--g
--constrangerile erau sunt deja definite?
SELECT constraint_name, constraint_type, 
       status, index_name
FROM   user_constraints
WHERE  table_name IN (upper('clienti_***'),
       upper('produse_***'),
       upper('timp_***'),
       upper('vanzari_***'));

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
select count(distinct c.id_client),sum(v.valoare)
from   clienti_*** c, vanzari_*** v, timp_*** t,
       produse_*** p
where  v.client_id=c.id_client
and    v.timp_id=t.id_timp
and    v.produs_id=p.id_produs
and    c.tip='pf'
and    t.luna=3
and    t.an=2007
and    p.greutate is null;


--cost= 4035
SELECT plan_table_output 
FROM 
table(dbms_xplan.display('plan_table', 's2_g1_***','serial'));


--constrangerile erau sunt deja definite?
--DA => atunci le dezactivam si verificam planul de executie
ALTER TABLE vanzari_***
MODIFY CONSTRAINT fk_vanzari_produse_***
DISABLE NOVALIDATE;

ALTER TABLE produse_***
MODIFY CONSTRAINT pk_produs_***
DISABLE NOVALIDATE;

ALTER TABLE vanzari_***
MODIFY CONSTRAINT fk_vanzari_clienti_***
DISABLE NOVALIDATE;

ALTER TABLE clienti_***
MODIFY CONSTRAINT pk_clienti_***
DISABLE NOVALIDATE;

EXPLAIN PLAN 
SET STATEMENT_ID = 's2_g2_***' 
FOR 
select count(distinct c.id_client),sum(v.valoare)
from   clienti_*** c, vanzari_*** v, timp_*** t,
       produse_*** p
where  v.client_id=c.id_client
and    v.timp_id=t.id_timp
and    v.produs_id=p.id_produs
and    c.tip='pf'
and    t.luna=3
and    t.an=2007
and    p.greutate is null;


--cost=4091 
SELECT plan_table_output 
FROM 
table(dbms_xplan.display('plan_table', 's2_g2_***','serial'));

--reactivam constrangerile
ALTER TABLE produse_***
MODIFY CONSTRAINT pk_produs_***
enABLE NOVALIDATE;

ALTER TABLE vanzari_***
MODIFY CONSTRAINT fk_vanzari_produse_***
enABLE NOVALIDATE;

ALTER TABLE clienti_***
MODIFY CONSTRAINT pk_clienti_***
enABLE NOVALIDATE;

ALTER TABLE vanzari_***
MODIFY CONSTRAINT fk_vanzari_clienti_***
enABLE NOVALIDATE;

--3
DESC plati_***
select * from plati_***;

--a
--varianta 1
--cost = 5132
select count(distinct factura)
from   vanzari_*** v, plati_*** p
where  v.plata_id = p.id_plata
and    p.cod='DP';

--varianta 2
--cost = 5132
select count(distinct factura)
from   vanzari_*** v
where  v.plata_id in
(select p.id_plata
 from   plati_*** p
 where  p.cod='DP');
 
--varianta 3
--5224
select count(*)
from (select distinct factura, plata_id
      from vanzari_***) v,
      (select id_plata
       from   plati_***
       where  cod='DP') p
where v.plata_id = p.id_plata;


EXPLAIN PLAN
SET STATEMENT_ID = 's3_a_***'
FOR 
select count(distinct factura)
from   vanzari_*** v, plati_*** p
where  v.plata_id = p.id_plata
and    p.cod='DP';

--cost=5132
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

ALTER TABLE plati_***
ADD CONSTRAINT pk_plati_***
PRIMARY KEY(id_plata) ENABLE VALIDATE;

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
select count(distinct factura)
from   vanzari_*** v, plati_*** p
where  v.plata_id = p.id_plata
and    p.cod='DP';

--cost=5132
SELECT plan_table_output
FROM
table(dbms_xplan.display('plan_table', 's3_e1_***','serial'));

--cu hint
EXPLAIN PLAN
SET STATEMENT_ID = 's3_e2_***'
FOR
SELECT /*+index(v ind_bmp_join_vanz_plati_*** ) */ 
count(distinct factura)
from   vanzari_*** v, plati_*** p
where  v.plata_id = p.id_plata
and    p.cod='DP';

--cost=8787
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
SELECT factura, client_id,timp_id, plata_id,
       sum(valoare)
from vanzari_***
where to_char(timp_id,'yyyy')='2007'
group by factura, client_id,timp_id, plata_id;
COMMIT;

EXPLAIN PLAN
SET STATEMENT_ID = 's3_f1_***'
FOR
select count(*)
from   vanzari_factura_*** v, plati_*** p
where  v.plata_id = p.id_plata
and    p.cod='DP';

--cost=279
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
select count(*)
from   vanzari_factura_*** v, plati_*** p
where  v.plata_id = p.id_plata
and    p.cod='DP';

--cost=4
SELECT plan_table_output
FROM
table(dbms_xplan.display('plan_table', 's3_f2_***','serial'));

--4
--a
EXPLAIN PLAN
SET STATEMENT_ID = 's4_a_***'
FOR
select count(distinct c.id_client),sum(v.valoare)
from   clienti_*** c, vanzari_*** v, timp_*** t,
       produse_*** p
where  v.client_id=c.id_client
and    v.timp_id=t.id_timp
and    v.produs_id=p.id_produs
and    c.tip='pf'
and    t.luna=3
and    t.an=2007
and    p.greutate is null;


--cost=4035
SELECT plan_table_output
FROM
table(dbms_xplan.display('plan_table', 's4_a_***','serial'));

--b
CREATE BITMAP INDEX bmp_fk_vanz_clienti_***
ON vanzari_***(client_id);
ANALYZE INDEX bmp_fk_vanz_clienti_*** 
COMPUTE STATISTICS;

CREATE BITMAP INDEX bmp_fk_vanz_timp_***
ON vanzari_***(timp_id);
ANALYZE INDEX bmp_fk_vanz_timp_*** 
COMPUTE STATISTICS;

CREATE BITMAP INDEX bmp_fk_vanz_produse_***
ON vanzari_***(produs_id);
ANALYZE INDEX bmp_fk_vanz_produse_*** 
COMPUTE STATISTICS;

--c
ALTER SESSION
SET STAR_TRANSFORMATION_ENABLED = true;

--d
EXPLAIN PLAN
SET STATEMENT_ID ='s4_d1_***' FOR
SELECT /*+ STAR_TRANSFORMATION */
       /*+ FACT(v)*/
count(distinct c.id_client),sum(v.valoare)
from   clienti_*** c, vanzari_*** v, timp_*** t,
       produse_*** p
where  v.client_id=c.id_client
and    v.timp_id=t.id_timp
and    v.produs_id=p.id_produs
and    c.tip='pf'
and    t.luna=3
and    t.an=2007
and    p.greutate is null;


--cost=1291
SELECT plan_table_output 
FROM 
table(dbms_xplan.display('plan_table', 's4_d1_***','serial'));

--fara hint
EXPLAIN PLAN
SET STATEMENT_ID ='s4_d2_***' FOR
SELECT count(distinct c.id_client),sum(v.valoare)
from   clienti_*** c, vanzari_*** v, timp_*** t,
       produse_*** p
where  v.client_id=c.id_client
and    v.timp_id=t.id_timp
and    v.produs_id=p.id_produs
and    c.tip='pf'
and    t.luna=3
and    t.an=2007
and    p.greutate is null;


--cost=1291
SELECT plan_table_output 
FROM 
table(dbms_xplan.display('plan_table', 's4_d2_***','serial'));

--5
DESC user_indexes

SELECT table_name, index_name, index_type, 
       uniqueness, join_index, 
       distinct_keys, num_rows, last_analyzed
FROM   user_indexes
WHERE  table_name like upper('%prof')
ORDER BY 1,3;






