--Lab 7 DW
--1 
--a
desc clienti_***
desc vanzari_factura_***

select * from clienti_***;
select * from vanzari_factura_***;

-- cost=293
select c.id_client, c.nume, count(*) nr_facturi
from   clienti_*** c, vanzari_factura_*** v
where  v.client_id=c.id_client
group by c.id_client,c.nume;

-- cost=293
select c.id_client, max(c.nume), count(*) nr_facturi
from   clienti_*** c, vanzari_factura_*** v
where  v.client_id=c.id_client
group by c.id_client;

CREATE MATERIALIZED VIEW vm_clienti_facturi1_***
BUILD immediate
REFRESH complete
ON commit
AS 
select c.id_client, max(c.nume), count(*) nr_facturi
from   clienti_*** c, vanzari_factura_*** v
where  v.client_id=c.id_client
group by c.id_client;

--b
--cost=3
select * from vm_clienti_facturi1_***;

--c
select * from clienti_*** where id_client =100;
select * from vanzari_factura_*** where client_id =100;
select * from vm_clienti_facturi1_*** where id_client =100;

desc vanzari_factura_***
select max(factura) from vanzari_factura_***;

insert into vanzari_factura_*** 
values (1688496,100, to_date('12.12.2007','dd.mm.yyyy'),30,3000);

--d
select * from vanzari_factura_*** where factura = 1688496;
select * from vm_clienti_facturi1_*** where id_client =100;

--e
commit;
select * from vm_clienti_facturi1_*** where id_client =100;

--2
--a
CREATE MATERIALIZED VIEW vm_clienti_facturi2_***
BUILD deferred
REFRESH complete
START WITH sysdate + 5/86400
NEXT sysdate + 15/86400
AS 
select c.id_client, max(c.nume), count(*) nr_facturi
from   clienti_*** c, vanzari_factura_*** v
where  v.client_id=c.id_client
group by c.id_client;

--b
select * from vm_clienti_facturi2_***;
select * from vm_clienti_facturi2_*** where id_client =100;

--c
insert into vanzari_factura_*** 
values (1688497,100, to_date('11.12.2007','dd.mm.yyyy'),30,1000);

--d
select * from vanzari_factura_*** where factura = 1688497;
select * from vm_clienti_facturi2_*** where id_client =100;

--e
select * from vm_clienti_facturi2_*** where id_client =100;

--f
commit;
select * from vm_clienti_facturi2_*** where id_client =100;

drop MATERIALIZED VIEW vm_clienti_facturi2_***;


--3
--a
CREATE MATERIALIZED VIEW vm_produse_facturi1_***
BUILD immediate
REFRESH complete
ON demand
AS 
select p.id_produs, max(p.denumire), sum(cantitate) cant_totala
from   produse_*** p, vanzari_*** v
where  v.produs_id=p.id_produs
group by p.id_produs;

--b
--cost 4
select * from vm_produse_facturi1_***;

--c
select * from vm_produse_facturi1_***
where id_produs = 321;

select * from vanzari_***
where produs_id =321 and client_id = 100 and factura=127873;

desc vanzari_***

select max(id) from vanzari_***;
insert into vanzari_***
values (169000,321, 100,to_date('19-FEB-07','dd-MON-yyyy'),
        11,30,null,319,null,22,127873,10,4.45,7.46,4.01,44.5) ;

--d
select * from vm_produse_facturi1_***
where id_produs = 321;

commit;

select * from vm_produse_facturi1_***
where id_produs = 321;

--e
EXECUTE DBMS_MVIEW.REFRESH('vm_produse_facturi1_***');

--f
select * from vm_produse_facturi1_***
where id_produs = 321;

--4
--a
CREATE MATERIALIZED VIEW vm_produse_facturi2_***
BUILD IMMEDIATE
REFRESH fast
ON commit
AS
   select id_produs,max(denumire), sum(cantitate),
          max(a.rowid) prod_rowid, max(b.rowid) vanz_rowid,
          count(*), count(id_produs)
   from  produse_*** a, vanzari_*** b
   where id_produs=produs_id 
   group by id_produs;


--b
desc produse_***
CREATE MATERIALIZED VIEW LOG ON produse_***
WITH ROWID, PRIMARY KEY, SEQUENCE
(DENUMIRE, CATEGORIE_5, CATEGORIE_4, CATEGORIE_3,
CATEGORIE_2,CATEGORIE_1,PRET_UNITAR_CURENT, GREUTATE )
INCLUDING NEW VALUES;

desc vanzari_***
CREATE MATERIALIZED VIEW LOG ON vanzari_***
WITH ROWID, PRIMARY KEY, SEQUENCE
(produs_id, client_id, timp_id, factura,PRET_UNITAR_VANZARE,
CANTITATE, VALOARE)
INCLUDING NEW VALUES;

alter table vanzari_***
add constraint pk_vanzari_*** primary key(id)
rely DISABLE novalidate;

CREATE MATERIALIZED VIEW LOG ON vanzari_***
WITH ROWID, PRIMARY KEY, SEQUENCE
(produs_id, client_id, timp_id, factura,PRET_UNITAR_VANZARE,
CANTITATE, VALOARE)
INCLUDING NEW VALUES;

--c
CREATE MATERIALIZED VIEW vm_produse_facturi2_***
BUILD IMMEDIATE
REFRESH fast
ON commit
AS
select id_produs, max(denumire) denumire, 
       sum(cantitate) cantitate_totala,
       max(a.rowid) prod_rowid, max(b.rowid) vanz_rowid,
       count(*), count(id_produs)
from   produse_*** a, vanzari_*** b
where  id_produs=produs_id
group by id_produs;

--d
select * from vm_produse_facturi2_***
where id_produs = 321;

select max(factura) from vanzari_***;
select * from vanzari_***
where produs_id =321 and client_id = 100 and factura=169000;

desc vanzari_***

select max(id) from vanzari_***;
insert into vanzari_***
values (1690002,321, 100,to_date('19-FEB-07','dd-MON-yyyy'),
        11,30,null,319,null,22,169000,100,4.45,7.46,4.01,445) ;

select * from vanzari_***
where produs_id =321 and client_id = 100 
and factura in (169000,127185);

select * from vm_produse_facturi2_***
where id_produs = 321;

--e
desc mlog$_vanzari_***
select * from mlog$_vanzari_***;

--f
select * from vm_produse_facturi2_***
where id_produs = 321;

--g
commit;
select * from vm_produse_facturi2_***
where id_produs = 321;

select * from mlog$_vanzari_***;

--teste
--test pentru update
select * from vanzari_***
where produs_id =321 and client_id = 100 
and factura in (169000,127185);

update vanzari_***
set cantitate = cantitate*10, valoare = valoare*10
where factura=169000;

select * from mlog$_vanzari_***;

select * from vm_produse_facturi2_***
where id_produs = 321;

commit;

select * from mlog$_vanzari_***;

select * from vm_produse_facturi2_***
where id_produs = 321;

--test delete
select * from vanzari_***
where produs_id =321 and client_id = 100 
and factura in (169000,127185);

--id coresp facturii 169000
delete from vanzari_*** where id=1690002;

select * from mlog$_vanzari_***;

select * from vm_produse_facturi2_***
where id_produs = 321;

commit;

select * from mlog$_vanzari_***;

select * from vm_produse_facturi2_***
where id_produs = 321;

--5
--a
desc vanzari_factura_***

CREATE MATERIALIZED VIEW vm_clienti_vanzari1_***
BUILD immediate
REFRESH complete
ON demand
ENABLE QUERY REWRITE
AS 
select c.id_client, max(c.nume), sum(valoare_totala) total
from   clienti_*** c, vanzari_factura_*** v
where  v.client_id=c.id_client
group by c.id_client;

select * from vm_clienti_vanzari1_***;

--d
analyze table vanzari_factura_*** compute STATISTICS;
analyze table clienti_*** compute STATISTICS;

--e
EXPLAIN PLAN
SET STATEMENT_ID ='st_5e_***' 
FOR 
select c.id_client, max(c.nume), sum(valoare_totala) total
from   clienti_*** c, vanzari_factura_*** v
where  v.client_id=c.id_client
group by c.id_client;

--cost=3
SELECT plan_table_output
FROM table(dbms_xplan.display('plan_table','st_5e_***','serial'));

--g
analyze table vm_clienti_vanzari1_*** compute STATISTICS;

EXPLAIN PLAN
SET STATEMENT_ID ='st_5g_***' 
FOR 
select c.id_client, max(c.nume), sum(valoare_totala) total
from   clienti_*** c, vanzari_factura_*** v
where  v.client_id=c.id_client
group by c.id_client;

SELECT plan_table_output
FROM table(dbms_xplan.display('plan_table','st_5e_***','serial'));

--h
EXPLAIN PLAN
SET STATEMENT_ID ='st_5h_***' 
FOR 
select /*+ norewrite */
       c.id_client, max(c.nume), sum(valoare_totala) total
from   clienti_*** c, vanzari_factura_*** v
where  v.client_id=c.id_client
group by c.id_client;

--cost=296
SELECT plan_table_output
FROM table(dbms_xplan.display('plan_table', 'st_5h_***','serial'));

--i
EXPLAIN PLAN
SET STATEMENT_ID ='st_5i_***' 
FOR 
select c.id_client, max(c.nume), sum(valoare_totala) total
from   clienti_*** c, vanzari_factura_*** v
where  v.client_id=c.id_client
group by c.id_client
having sum(valoare_totala) > 6000000;

--cost=3
SELECT plan_table_output
FROM table(dbms_xplan.display('plan_table','st_5i_***','serial'));

--j
EXPLAIN PLAN
SET STATEMENT_ID ='st_5j_***' 
FOR 
select c.id_client, max(c.nume), avg(valoare_totala) total
from   clienti_*** c, vanzari_factura_*** v
where  v.client_id=c.id_client
group by c.id_client;

SELECT plan_table_output
FROM table(dbms_xplan.display('plan_table','st_5j_***','serial'));

--k
EXPLAIN PLAN
SET STATEMENT_ID ='st_5k_***' 
FOR 
select c.id_client, max(c.nume), sum(valoare_totala)/count(valoare_totala) total
from   clienti_*** c, vanzari_factura_*** v
where  v.client_id=c.id_client
group by c.id_client;

SELECT plan_table_output
FROM table(dbms_xplan.display('plan_table','st_5k_***','serial'));

--l
CREATE MATERIALIZED VIEW vm_clienti_vanzari2_***
BUILD immediate
REFRESH complete
ON demand
ENABLE QUERY REWRITE
AS 
select c.id_client, max(c.nume), sum(valoare_totala) total,
       count(*) nr_facturi, count(valoare_totala) nr_valoare
from   clienti_*** c, vanzari_factura_*** v
where  c.id_client = v.client_id
group by c.id_client;

EXPLAIN PLAN
SET STATEMENT_ID ='st_5l_***' 
FOR 
select 
       c.id_client, max(c.nume), 
       sum(valoare_totala)/count(valoare_totala) media
from   clienti_*** c, vanzari_factura_*** v
where  c.id_client = v.client_id
group by c.id_client;

SELECT plan_table_output
FROM table(dbms_xplan.display('plan_table',
'st_5l_***','serial'));

analyze table vm_clienti_vanzari2_*** compute STATISTICS;

EXPLAIN PLAN
SET STATEMENT_ID ='st_5l_***' 
FOR 
select 
       c.id_client, max(c.nume), 
       sum(valoare_totala)/count(valoare_totala) media
from   clienti_*** c, vanzari_factura_*** v
where  c.id_client = v.client_id
group by c.id_client;

SELECT plan_table_output
FROM table(dbms_xplan.display('plan_table',
'st_5l_***','serial'));

EXPLAIN PLAN
SET STATEMENT_ID ='st_5l_2_***' 
FOR 
select 
       c.id_client, max(c.nume), 
       avg(valoare_totala) media
from   clienti_*** c, vanzari_factura_*** v
where  c.id_client = v.client_id
group by c.id_client;

SELECT plan_table_output
FROM table(dbms_xplan.display('plan_table',
'st_5l_2_***','serial'));

EXPLAIN PLAN
SET STATEMENT_ID ='st_5l_3_***' 
FOR 
select 
       c.id_client, max(c.nume), 
       avg(valoare_totala) media
from   clienti_*** c, vanzari_factura_*** v
where  c.id_client = v.client_id
group by c.id_client
having sum(valoare_totala) > 6000000;

SELECT plan_table_output
FROM table(dbms_xplan.display('plan_table',
'st_5l_3_***','serial'));


EXPLAIN PLAN
SET STATEMENT_ID ='st_5l_4_***' 
FOR 
select 
       c.id_client, max(c.nume), 
       sum(valoare_totala)/count(*) media
from   clienti_*** c, vanzari_factura_*** v
where  c.id_client = v.client_id
group by c.id_client
having sum(valoare_totala) > 6000000;

SELECT plan_table_output
FROM table(dbms_xplan.display('plan_table',
'st_5l_4_***','serial'));

--m
--alter table clienti_*** 
--add primary key(id_client);

EXPLAIN PLAN
SET STATEMENT_ID ='st_5m_***' 
FOR 
select 
       email, max(c.nume), 
       avg(valoare_totala) media
from   clienti_*** c, vanzari_factura_*** v
where  c.id_client = v.client_id
group by email;

SELECT plan_table_output
FROM table(dbms_xplan.display('plan_table',
'st_5m_***','serial'));

--n
--alter table vanzari_factura_***
--add constraint fk_vanz_fact_clienti_***
--foreign key(client_id) references clienti_*** rely disable novalidate;

EXPLAIN PLAN
SET STATEMENT_ID ='st_5m_2_***' 
FOR 
select 
       email, max(c.nume), 
       avg(valoare_totala) media
from   clienti_*** c, vanzari_factura_*** v
where  c.id_client = v.client_id
group by c.id_client,email;

SELECT plan_table_output
FROM table(dbms_xplan.display('plan_table',
'st_5m_2_***','serial');

select * from vm_clienti_vanzari2_***;

--atentie la alias in viz atunci cand avem functii: max(c.nume)!!!
EXPLAIN PLAN
SET STATEMENT_ID ='st_5m_3_***' 
FOR 
select 
       c.email, v.max(c.nume),v.total/v.nr_facturi media
from   clienti_*** c, vm_clienti_vanzari2_*** v
where  c.id_client = v.id_client;

drop MATERIALIZED VIEW vm_clienti_vanzari2_***;

CREATE MATERIALIZED VIEW vm_clienti_vanzari2_***
BUILD immediate
REFRESH complete
ON demand
ENABLE QUERY REWRITE
AS 
select c.id_client, max(c.nume) as nume, sum(valoare_totala) total,
       count(*) nr_facturi, count(valoare_totala) nr_valoare
from   clienti_*** c, vanzari_factura_*** v
where  c.id_client = v.client_id
group by c.id_client;

EXPLAIN PLAN
SET STATEMENT_ID ='st_5m_3_***' 
FOR 
select 
       c.email, v.nume,v.total/v.nr_facturi media
from   clienti_*** c, vm_clienti_vanzari2_*** v
where  c.id_client = v.id_client;

--cost=6
SELECT plan_table_output
FROM table(dbms_xplan.display('plan_table',
'st_5m_3_***','serial'));

--6
--a 
desc user_mviews

--b
select MVIEW_NAME, REWRITE_ENABLED,REFRESH_MODE,REFRESH_METHOD,
       BUILD_MODE, FAST_REFRESHABLE ,LAST_REFRESH_DATE
from   user_mviews;       
