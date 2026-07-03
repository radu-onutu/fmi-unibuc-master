--Lab 6 DW - Partition
  
--1
--a
CREATE TABLE vanzari_ord_date_***
PARTITION BY RANGE(timp_id)
( PARTITION vanzari_jan2007
VALUES LESS THAN(TO_DATE('01/02/2007','DD/MM/YYYY')),
PARTITION vanzari_feb2007
VALUES LESS THAN(TO_DATE('01/03/2007','DD/MM/YYYY')),
PARTITION vanzari_mar2007
VALUES LESS THAN(TO_DATE('01/04/2007','DD/MM/YYYY')),
PARTITION vanzari_apr2007
VALUES LESS THAN(TO_DATE('01/05/2007','DD/MM/YYYY')),
PARTITION vanzari_mai2007
VALUES LESS THAN(TO_DATE('01/06/2007','DD/MM/YYYY')),
PARTITION vanzari_iun2007
VALUES LESS THAN(TO_DATE('01/07/2007','DD/MM/YYYY')),
PARTITION vanzari_iul2007
VALUES LESS THAN(TO_DATE('01/08/2007','DD/MM/YYYY')),
PARTITION vanzari_aug2007
VALUES LESS THAN(TO_DATE('01/09/2007','DD/MM/YYYY')),
PARTITION vanzari_sep2007
VALUES LESS THAN(TO_DATE('01/10/2007','DD/MM/YYYY')),
PARTITION vanzari_oct2007
VALUES LESS THAN(TO_DATE('01/11/2007','DD/MM/YYYY')),
PARTITION vanzari_nov2007
VALUES LESS THAN(TO_DATE('01/12/2007','DD/MM/YYYY')),
PARTITION vanzari_dec2007
VALUES LESS THAN(TO_DATE('01/01/2008','DD/MM/YYYY')),
PARTITION vanzari_rest
VALUES LESS THAN (MAXVALUE))
AS
SELECT *
FROM vanzari;

--b

ANALYZE TABLE vanzari_ord_date_*** COMPUTE STATISTICS;

EXPLAIN PLAN
SET STATEMENT_ID = 'st_1b_***'
FOR 
select to_char(timp_id,'yyyy-mm'), sum(cantitate)
from   vanzari_ord_date_***
group by to_char(timp_id,'yyyy-mm');

--cost=4176
SELECT plan_table_output
FROM
table(dbms_xplan.display('plan_table','st_1b_***','serial'));

--c
EXPLAIN PLAN
SET STATEMENT_ID = 'st_1c_***'
FOR 
select to_char(timp_id,'yyyy-mm'), sum(cantitate)
from   vanzari_***
group by to_char(timp_id,'yyyy-mm');

--cost=4108
SELECT plan_table_output
FROM
table(dbms_xplan.display('plan_table','st_1c_***','serial'));

--d
EXPLAIN PLAN
SET STATEMENT_ID = 'st_1d_***'
FOR 
SELECT sum(cantitate)
FROM   vanzari_ord_date_***
WHERE  TO_CHAR(timp_id,'YYYY-MM') = '2007-03';

SELECT plan_table_output
FROM   table(dbms_xplan.display('plan_table','st_1d_***','serial'));

--e
EXPLAIN PLAN
SET STATEMENT_ID = 'st_1e_***'
FOR 
SELECT sum(cantitate)
FROM   vanzari_ord_date_***
WHERE EXTRACT(YEAR FROM timp_id) = 2007 
AND   EXTRACT(MONTH FROM timp_id) = 3;

SELECT plan_table_output
FROM   table(dbms_xplan.display('plan_table','st_1e_***','serial'));

--f
EXPLAIN PLAN
SET STATEMENT_ID = 'st_1f_***'
FOR 
SELECT sum(cantitate)
FROM   vanzari_ord_date_***
WHERE  timp_id BETWEEN TO_DATE('01/03/2007','DD/MM/YYYY')
       AND TO_DATE('31/03/2007','DD/MM/YYYY');

--cost=370
SELECT plan_table_output
FROM   table(dbms_xplan.display('plan_table','st_1f_***','serial'));

--g
EXPLAIN PLAN
SET STATEMENT_ID = 'st_1g_***'
FOR 
SELECT sum(cantitate)
FROM   vanzari
WHERE  timp_id BETWEEN TO_DATE('01/03/2007','DD/MM/YYYY')
       AND TO_DATE('31/03/2007','DD/MM/YYYY');

--cost=4163
SELECT plan_table_output
FROM   table(dbms_xplan.display('plan_table','st_1g_***','serial'));

--h
EXPLAIN PLAN
SET STATEMENT_ID = 'st_1h_***'
FOR 
select sum(cantitate)
from   vanzari_ord_date_*** 
PARTITION(vanzari_mar2007);

--cost=369
SELECT plan_table_output
FROM   table(dbms_xplan.display('plan_table','st_1h_***','serial'));

--2
--a
CREATE TABLE vanzari_ord_number_***
(id NUMBER,
produs_id NUMBER(4),
client_id NUMBER(4),
timp_id NUMBER(10),
factura NUMBER(8),
cantitate NUMBER(4),
pret_unitar_vanzare NUMBER(10,2))
PARTITION BY RANGE(timp_id)
(
PARTITION vanzari_jan2007
VALUES LESS THAN (2454133),
-- 2454133 = TO_CHAR(TO_DATE('01/02/2007','DD/MM/YYYY'),'J')
PARTITION vanzari_feb2007
VALUES LESS THAN (2454161),
-- 2454161 = TO_CHAR(TO_DATE('01/03/2007','DD/MM/YYYY'),'J')
PARTITION vanzari_mar2007
VALUES LESS THAN (2454192),
-- 2454192 = TO_CHAR(TO_DATE('01/04/2007','DD/MM/YYYY'),'J')
PARTITION vanzari_apr2007
VALUES LESS THAN (2454222),
-- 2454222 = TO_CHAR(TO_DATE('01/05/2007','DD/MM/YYYY'),'J')
PARTITION vanzari_mai2007
VALUES LESS THAN (2454253),
-- 2454253 = TO_CHAR(TO_DATE('01/06/2007','DD/MM/YYYY'),'J')
PARTITION vanzari_iun2007
VALUES LESS THAN (2454283),
-- 2454283 = TO_CHAR(TO_DATE('01/07/2007','DD/MM/YYYY'),'J')
PARTITION vanzari_iul2007
VALUES LESS THAN (2454314),
-- 2454314 = TO_CHAR(TO_DATE('01/08/2007','DD/MM/YYYY'),'J')
PARTITION vanzari_aug2007
VALUES LESS THAN (2454345),
-- 2454345 = TO_CHAR(TO_DATE('01/09/2007','DD/MM/YYYY'),'J')
PARTITION vanzari_sept2007
VALUES LESS THAN (2454375),
-- 2454375 = TO_CHAR(TO_DATE('01/10/2007','DD/MM/YYYY'),'J')
PARTITION vanzari_oct2007
VALUES LESS THAN (2454406),
-- 2454406 = TO_CHAR(TO_DATE('01/11/2007','DD/MM/YYYY'),'J')
PARTITION vanzari_nov2007
VALUES LESS THAN (2454436),
-- 2454436 = TO_CHAR(TO_DATE('01/12/2007','DD/MM/YYYY'),'J')
PARTITION vanzari_dec2007
VALUES LESS THAN (2454467),
-- 2454467 = TO_CHAR(TO_DATE('01/01/2008','DD/MM/YYYY'),'J')
PARTITION vanzari_rest
VALUES LESS THAN (MAXVALUE)
);

--b
DESC vanzari_ord_number_***

SELECT id, PRODUS_ID, CLIENT_ID,
       to_char(TIMP_ID,'j'),
       FACTURA,
       CANTITATE,
       PRET_UNITAR_VANZARE
FROM   vanzari_***;

INSERT INTO vanzari_ord_number_***
SELECT id, PRODUS_ID, CLIENT_ID,
       to_char(TIMP_ID,'j'),
       FACTURA,
       CANTITATE,
       PRET_UNITAR_VANZARE
FROM   vanzari_***;

COMMIT;

ANALYZE TABLE vanzari_ord_number_*** COMPUTE STATISTICS;

--c
CREATE TABLE timp_ord_number_***
(id_timp NUMBER PRIMARY KEY RELY DISABLE NOVALIDATE,
data DATE,
luna NUMBER(2),
luna_an VARCHAR2(7),
trimestru NUMBER(1),
trimestru_an VARCHAR2(6),
an NUMBER(4))
PARTITION BY RANGE(id_timp)
( PARTITION timp_jan2007
VALUES LESS THAN (2454133),
-- 2454133 = TO_CHAR(TO_DATE('01/02/2007','DD/MM/YYYY'),'J')
PARTITION timp_feb2007
VALUES LESS THAN (2454161),
-- 2454161 = TO_CHAR(TO_DATE('01/03/2007','DD/MM/YYYY'),'J')
PARTITION timp_mar2007
VALUES LESS THAN (2454192),
-- 2454192 = TO_CHAR(TO_DATE('01/04/2007','DD/MM/YYYY'),'J')
PARTITION timp_apr2007
VALUES LESS THAN (2454222),
-- 2454222 = TO_CHAR(TO_DATE('01/05/2007','DD/MM/YYYY'),'J')
PARTITION timp_mai2007
VALUES LESS THAN (2454253),
-- 2454253 = TO_CHAR(TO_DATE('01/06/2007','DD/MM/YYYY'),'J')
PARTITION timp_iun2007
VALUES LESS THAN (2454283),
-- 2454283 = TO_CHAR(TO_DATE('01/07/2007','DD/MM/YYYY'),'J')
PARTITION timp_iul2007
VALUES LESS THAN (2454314),
-- 2454314 = TO_CHAR(TO_DATE('01/08/2007','DD/MM/YYYY'),'J')
PARTITION timp_aug2007
VALUES LESS THAN (2454345),
-- 2454345 = TO_CHAR(TO_DATE('01/09/2007','DD/MM/YYYY'),'J')
PARTITION vanzari_sept2007
VALUES LESS THAN (2454375),
-- 2454375 = TO_CHAR(TO_DATE('01/10/2007','DD/MM/YYYY'),'J')
PARTITION timp_oct2007
VALUES LESS THAN (2454406),
-- 2454406 = TO_CHAR(TO_DATE('01/11/2007','DD/MM/YYYY'),'J')
PARTITION timp_nov2007
VALUES LESS THAN (2454436),
-- 2454436 = TO_CHAR(TO_DATE('01/12/2007','DD/MM/YYYY'),'J')
PARTITION timp_dec2007
VALUES LESS THAN (2454467),
-- 2454467 = TO_CHAR(TO_DATE('01/01/2008','DD/MM/YYYY'),'J')
PARTITION timp_rest
VALUES LESS THAN (MAXVALUE));

--d
DESC timp_ord_number_***
DESC timp_***

SELECT to_char(id_timp,'j'),
       id_timp,
       luna,
       an||'-'||luna,
       TRIMESTRU,
       an||'-'||TRIMESTRU,
       an
FROM   timp_***;

INSERT INTO timp_ord_number_***
SELECT to_char(id_timp,'j'),
       id_timp,
       luna,
       an||'-'||luna,
       TRIMESTRU,
       an||'-'||TRIMESTRU,
       an
FROM   timp_***;

COMMIT;

ANALYZE TABLE timp_ord_number_*** COMPUTE STATISTICS;

ALTER TABLE vanzari_ord_number_***
ADD CONSTRAINT fk_vanzari_timp_ord_nr_***
FOREIGN KEY (timp_id) REFERENCES timp_ord_number_***(id_timp)
RELY DISABLE NOVALIDATE;

--e
EXPLAIN PLAN
SET STATEMENT_ID = 'st_2e_***'
FOR 
select to_char(timp_id,'yyyy-mm'), sum(cantitate)
from   vanzari_ord_number_***
group by to_char(timp_id,'yyyy-mm');

--cost=3430
SELECT plan_table_output
FROM table(dbms_xplan.display('plan_table','st_2e_***','serial'));

EXPLAIN PLAN
SET STATEMENT_ID = 'st_2e2_***'
FOR 
select luna, sum(cantitate)
from   vanzari_ord_number_*** v,
       timp_ord_number_*** t
where v.timp_id=t.id_timp
group by luna;

--cost=6196
SELECT plan_table_output
FROM table(dbms_xplan.display('plan_table','st_2e2_***','serial'));

--f
select * from timp_ord_number_***;

EXPLAIN PLAN
SET STATEMENT_ID = 'st_2f_***'
FOR 
select sum(cantitate)
from   vanzari_ord_number_*** v,
       timp_ord_number_*** t
where  v.timp_id=t.id_timp
AND    t.luna_an='2007-3';

--cost=6088
SELECT plan_table_output
FROM table(dbms_xplan.display('plan_table','st_2f_***','serial'));

EXPLAIN PLAN
SET STATEMENT_ID = 'st_2f2_***'
FOR 
select sum(cantitate)
from   vanzari_ord_number_*** 
where  timp_id >= 2454161 and timp_id<2454192;

--cost=279
SELECT plan_table_output
FROM table(dbms_xplan.display('plan_table','st_2f2_***','serial'));

--g
EXPLAIN PLAN
SET STATEMENT_ID = 'st_2g_***'
FOR 
SELECT  sum(cantitate)
FROM    vanzari_ord_number_*** PARTITION(vanzari_mar2007) v,
        timp_ord_number_*** PARTITION(timp_mar2007) t
where  v.timp_id=t.id_timp
AND    t.luna_an='2007-3';

--cost=382
SELECT plan_table_output
FROM table(dbms_xplan.display('plan_table','st_2g_***','serial'));

--3
--a
CREATE TABLE vanzari_hash_***
PARTITION BY HASH(produs_id)
PARTITIONS 4
--nr de submultimi trebuie sa fie o putere a lui 2
AS
SELECT *
FROM   vanzari;

--b
ANALYZE TABLE vanzari_hash_*** COMPUTE STATISTICS;

DESC vanzari_hash_***

EXPLAIN PLAN
SET STATEMENT_ID = 'st_3b_***'
FOR 
select produs_id,sum(cantitate)
from   vanzari_hash_***
group by produs_id;

--cost=4137
SELECT plan_table_output
FROM table(dbms_xplan.display('plan_table','st_3b_***','serial'));

--c
EXPLAIN PLAN
SET STATEMENT_ID = 'st_3c_***'
for
select produs_id,sum(cantitate)
from   vanzari_***
group by produs_id;

--cost=4108
SELECT plan_table_output
FROM table(dbms_xplan.display('plan_table','st_3c_***','serial'));

--d
EXPLAIN PLAN
SET STATEMENT_ID = 'st_3d_1_***'
for
select sum(cantitate)
from   vanzari_hash_***
where produs_id=3010;

--cost=980
SELECT plan_table_output
FROM table(dbms_xplan.display('plan_table','st_3d_1_***','serial'));

EXPLAIN PLAN
SET STATEMENT_ID = 'st_3d_2_***'
FOR 
select sum(cantitate)
from   vanzari
where  produs_id=3010;

--cost=4155
SELECT plan_table_output
FROM table(dbms_xplan.display('plan_table','st_3d_2_***','serial'));

--e
SELECT PARTITION_NAME
FROM   USER_TAB_PARTITIONS
WHERE  TABLE_NAME = UPPER('vanzari_hash_***')
AND    PARTITION_POSITION = ORA_HASH('3010', 4 - 1) + 1;

EXPLAIN PLAN
SET STATEMENT_ID = 'st_3e_***'
FOR 
SELECT sum(cantitate)
FROM   vanzari_hash_*** PARTITION (SYS_P5820)
WHERE  produs_id=3010;

--cost=980
SELECT plan_table_output
FROM table(dbms_xplan.display('plan_table','st_3e_***','serial'));

--4
--a
CREATE TABLE produse_list_***
PARTITION BY LIST(categorie_1)(
PARTITION prod_IT
VALUES('IT'),
PARTITION prod_papetarie
VALUES('Papetarie'),
PARTITION prod_industriale
VALUES('Industriale'),
PARTITION prod_mobilier
VALUES('Mobilier'),
PARTITION prod_altele VALUES(DEFAULT))
AS
SELECT *
FROM produse;

--b
ANALYZE TABLE produse_list_*** COMPUTE STATISTICS;

-- teste fara indecsi
select categorie_1 as raion, count(*)
from   produse_list_***
group by categorie_1;

select categorie_1 as raion, count(id_produs)
from   produse_list_***
group by categorie_1;

-- verificam daca utilizeaza indexul b-tree creat odata cu pk enable
alter table produse_list_***
add constraint pk_produse_list_*** primary key(id_produs) 
enable novalidate;

select categorie_1 as raion, count(id_produs)
from   produse_list_***
group by categorie_1;

-- verificam daca utilizeaza indexul bitmap definit pe coloana categorie_1
-- ORA-25122: Only LOCAL bitmap indexes are permitted on partitioned tables
create bitmap index bmp_prod_categ_*** on produse_list_***(categorie_1);

EXPLAIN PLAN
SET STATEMENT_ID = 'st_4b_***'
FOR 
select categorie_1 as raion, count(*)
from   produse_list_***
group by categorie_1;

--cost= 88
SELECT plan_table_output
FROM table(dbms_xplan.display('plan_table','st_4b_***','serial'));

--c
EXPLAIN PLAN
SET STATEMENT_ID = 'st_4c_***'
FOR 
select categorie_1 as raion, count(*)
from   produse_***
group by categorie_1;;

--cost=71
SELECT plan_table_output
FROM table(dbms_xplan.display('plan_table','st_4c_***','serial'));

--d
EXPLAIN PLAN
SET STATEMENT_ID = 'st_4d_***'
FOR 
SELECT count(*)
FROM   produse_list_***
WHERE  categorie_1='IT';

--cost=20
SELECT plan_table_output
FROM table(dbms_xplan.display('plan_table','st_4d_***','serial'));

EXPLAIN PLAN
SET STATEMENT_ID = 'st_4d_2_***'
FOR 
SELECT count(*)
FROM   produse_***
WHERE  categorie_1='IT'; 

--cost=69
SELECT plan_table_output
FROM table(dbms_xplan.display('plan_table','st_4d_2_***','serial'));

--e
EXPLAIN PLAN
SET STATEMENT_ID = 'st_4e_***'
FOR 
SELECT count(*)
FROM   produse_list_*** PARTITION(prod_IT);

--cost=20
SELECT plan_table_output
FROM table(dbms_xplan.display('plan_table','st_4e_***','serial'));

--5
--a
CREATE TABLE vanzari_ord_hash_***
(id NUMBER,
produs_id NUMBER(4),
client_id NUMBER(4),
timp_id DATE,
factura NUMBER(8),
cantitate NUMBER(4),
pret_unitar_vanzare NUMBER(10,2))
PARTITION BY RANGE (timp_id)
SUBPARTITION BY HASH (produs_id) SUBPARTITIONS 4
(PARTITION vanz2007t1
VALUES LESS THAN (TO_DATE('01/04/2007','DD/MM/YYYY')),
PARTITION vanz2007t2
VALUES LESS THAN (TO_DATE('01/07/2007','DD/MM/YYYY')),
PARTITION vanz2007t3
VALUES LESS THAN (TO_DATE('01/10/2007','DD/MM/YYYY')),
PARTITION vanz2007t4
VALUES LESS THAN (TO_DATE('01/01/2008','DD/MM/YYYY')));

--b
DESC vanzari_ord_hash_***

SELECT id, PRODUS_ID,CLIENT_ID, TIMP_ID, FACTURA,CANTITATE,
       PRET_UNITAR_VANZARE  
FROM   vanzari;       

INSERT INTO vanzari_ord_hash_***
SELECT id, PRODUS_ID,CLIENT_ID, TIMP_ID, FACTURA,CANTITATE,
       PRET_UNITAR_VANZARE  
FROM   vanzari;   

COMMIT;

ANALYZE TABLE vanzari_ord_hash_*** COMPUTE STATISTICS;

--c
EXPLAIN PLAN
SET STATEMENT_ID = 'st_5c_***'
FOR 
SELECT sum(cantitate)
FROM   vanzari_ord_hash_***
WHERE  produs_id=3010
AND    timp_id between to_date('01/01/2007','dd/mm/yyyy')
       and to_date('11/03/2007','dd/mm/yyyy');

--cost=275
SELECT plan_table_output
FROM table(dbms_xplan.display('plan_table','st_5c_***','serial'));

--d
EXPLAIN PLAN
SET STATEMENT_ID = 'st_5c_2_***'
FOR 
SELECT sum(cantitate)
FROM   vanzari_***
WHERE  produs_id=3010
AND    timp_id between to_date('01/01/2007','dd/mm/yyyy')
       and to_date('11/03/2007','dd/mm/yyyy');

--cost=370
SELECT plan_table_output
FROM table(dbms_xplan.display('plan_table','st_5c_2_***','serial'));

--tabela partitionata doar range
EXPLAIN PLAN
SET STATEMENT_ID = 'st_5c_3_***'
FOR 
SELECT sum(cantitate)
FROM   vanzari_ord_date_***
WHERE  produs_id=3010
AND    timp_id between to_date('01/01/2007','dd/mm/yyyy')
       and to_date('11/03/2007','dd/mm/yyyy');

--cost=1013
SELECT plan_table_output
FROM table(dbms_xplan.display('plan_table','st_5c_3_***','serial'));

--e
SELECT SUBPARTITION_NAME, SUBPARTITION_POSITION
FROM   USER_TAB_SUBPARTITIONS
WHERE  TABLE_NAME = UPPER('vanzari_ord_hash_***')
AND    PARTITION_NAME = UPPER('vanz2007t1')
AND    SUBPARTITION_POSITION = ORA_HASH('3010', 4 - 1) + 1;

--f
EXPLAIN PLAN
SET STATEMENT_ID = 'st_5f_***'
FOR 
SELECT sum(cantitate)
FROM   vanzari_ord_hash_*** SUBPARTITION (SYS_SUBP5957)
WHERE  produs_id=3010;

--cost=276
SELECT plan_table_output
FROM table(dbms_xplan.display('plan_table','st_5f_***','serial'));

--6
SELECT table_name, partitioned, last_analyzed
FROM   user_tables 
WHERE  table_name like upper('%***');

SELECT table_name, partition_name, subpartition_count,
       partition_position
FROM   user_tab_partitions 
WHERE  table_name like upper('%***');

SELECT table_name, partition_name, subpartition_name,
       subpartition_position
FROM   user_tab_subpartitions 
WHERE  table_name like upper('%***');
 



