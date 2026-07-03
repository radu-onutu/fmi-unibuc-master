--LAB 3 DW 
alter session set "_optimizer_gather_stats_on_load"=false;

--1
create table tab1_*** (
a1 ...,
a2 ...,
a3 ...,
a4 ... constraint u_a4_tab1_*** ...,
CONSTRAINT pk_tab1_*** ...);

create table tab2_*** (
b1 ... constraint pk_tab2_*** ...,
b2 ... constraint ck_b2_tab2_***
   ...,
b3 ... constraint nn_b3_tab2_***
   ...,
b4 ... CONSTRAINT fk_b4_tab2_***
   ...); 

--a
desc user_cons_columns

select table_name, column_name, constraint_name
from   user_cons_columns
where  ...;

--b
desc user_cons_columns
desc user_constraints

select  a.table_name, 
        column_name, a.constraint_name, generated, 
        constraint_type, search_condition, 
        delete_rule, r_constraint_name, status, 
        validated, rely
from user_cons_columns a, user_constraints b
where a.constraint_name=b.constraint_name
and   a.table_name  in (upper('tab1_***'),upper('tab2_***'));

--c
--d
--e
create SEQUENCE s_tab1_***
start with 10
increment by 10;

create SEQUENCE s_tab2_***;

desc tab1_***

insert into tab1_***
values (s_tab1_***.nextval, default,'DA',
        'val_'||s_tab1_***.currval);
        
insert into tab1_***
values (s_tab1_***.nextval, sysdate+1,'NU',
        ...);
        
select * from tab1_***;
commit;

desc tab2_***

insert into tab2_***
values (s_tab2_***.nextval, 
        dbms_random.value(low=>10,high=>100),
        ...,...);
        
select * from tab2_***;
commit;

--f

select a.table_name, column_name,
       a.constraint_name,
       index_name
from user_cons_columns a, user_constraints b
where a.constraint_name=b.constraint_name
and   ...;

--g
select * from tab1_***;

select table_name, num_rows, last_analyzed
from   user_tables
where  ...;

select * 
from   tab1_***
where  ...;

analyze table tab1_*** compute statistics;

select table_name, num_rows, last_analyzed
from   user_tables
where  ...;

select * 
from   tab1_***
where  a4='val_20';

select * 
from   tab1_***
where  lower(a4)='val_20';

select * 
from   tab1_***
where  a4=lower('val_20');

select * 
from   tab1_***
where  a4='1';

select * 
from   tab1_***
where  a4<>'val_20';

--h
alter table tab1_***
... constraint u_a4_tab1_*** ...;

select table_name, index_name, uniqueness
from   user_indexes  
where  ...;

select  a.table_name, 
        column_name, a.constraint_name, generated, 
        constraint_type, search_condition, 
        delete_rule, r_constraint_name, status, 
        validated, rely
from user_cons_columns a, user_constraints b
where a.constraint_name=b.constraint_name
and   ...;

alter table tab1_***
modify constraint u_a4_tab1_*** enable;

select table_name, index_name, uniqueness
from   user_indexes  
where  ...;

select  a.table_name, 
        column_name, a.constraint_name, generated, 
        constraint_type, search_condition, 
        delete_rule, r_constraint_name, status, 
        validated, rely
from user_cons_columns a, user_constraints b
where a.constraint_name=b.constraint_name
and   ...;

---
alter table tab1_***
... constraint u_a4_tab1_*** ...;

select table_name, index_name, uniqueness
from   user_indexes  
where  table_name = upper('tab1_***');

select  a.table_name, 
        column_name, a.constraint_name, generated, 
        constraint_type, search_condition, 
        delete_rule, r_constraint_name, status, 
        validated, rely
from user_cons_columns a, user_constraints b
where a.constraint_name=b.constraint_name
and   ...;

select * 
from   tab1_***
where  a4='val_20';

update tab1_***
set a4='val_22'
where a1=20;

select * 
from   tab1_***
where  a4='val_22';

insert into tab1_***
values (s_tab1_***.nextval, sysdate+1,'NU',
        'val_22');
        
--j
drop index u_a4_tab1_***;

create index ind_a4_tab1_*** on tab1_***(a4);

alter table tab1_***
... constraint u_a4_tab1_***
...;

select table_name, index_name, uniqueness
from   user_indexes  
where  ...;

select a.table_name, column_name,a.constraint_name,
       index_name
from user_cons_columns a, user_constraints b
where a.constraint_name=b.constraint_name
and   ...;

alter table tab1_***
... constraint u_a4_tab1_***;

select a.table_name, column_name,a.constraint_name,
       index_name
from user_cons_columns a, user_constraints b
where a.constraint_name=b.constraint_name
and   ...;

select table_name, index_name, uniqueness
from   user_indexes  
where  ...;

alter table tab1_***
... constraint u_a4_tab1_***
... using index ind_a4_tab1_***;

--2
desc plati_***

select * from plati_***;

--a
ALTER TABLE plati_***  
... CONSTRAINT u_plati_*** ... 
...;

--b
select a.table_name, column_name,a.constraint_name,
       index_name
from user_cons_columns a, user_constraints b
where a.constraint_name=b.constraint_name
and   ...;

select  a.table_name, 
        column_name, a.constraint_name, generated, 
        constraint_type, search_condition, 
        delete_rule, r_constraint_name, status, 
        validated, rely
from user_cons_columns a, user_constraints b
where a.constraint_name=b.constraint_name
and   ...;

--c
delete from plati_***
where ...;

--d
ALTER TABLE plati_***  
... CONSTRAINT u_plati_*** ...;
--e
select  a.table_name, 
        column_name, a.constraint_name, generated, 
        constraint_type, search_condition, 
        delete_rule, r_constraint_name, status, 
        validated, rely
from user_cons_columns a, user_constraints b
where a.constraint_name=b.constraint_name
and   ...;

--3
desc produse_***
desc vanzari_***
--a
alter table vanzari_***
... constraint fk_vanzari_produse_***
...;

--b
alter table produse_***
.. constraint pk_produs_***
...;

--c
alter table vanzari_***
... constraint fk_vanzari_produse_***
...;

--d
alter table produse_***
... constraint pk_produs_*** ...;

alter table vanzari_***
... constraint fk_vanzari_produse_***
...;

select a.table_name, column_name,a.constraint_name,
       index_name
from user_cons_columns a, user_constraints b
where a.constraint_name=b.constraint_name
and   ...;

--f
alter table produse_***
... constraint pk_produs_*** ...;

--g
alter table produse_***
... constraint pk_produs_*** ...;

--h
select a.table_name, column_name,a.constraint_name,
       index_name,
       constraint_type, search_condition, 
        delete_rule, r_constraint_name, status, 
        validated, rely
from user_cons_columns a, user_constraints b
where a.constraint_name=b.constraint_name
and   ...;
--i
alter table produse_***
... constraint pk_produs_*** ...;

--4
select a.table_name, 
       a.column_name, a.constraint_name,  
       constraint_type, status, 
       validated, index_name, rely
from user_cons_columns a, user_constraints b
where a.constraint_name=b.constraint_name
and   ...
order by 1;

desc clienti_***
--a
ALTER TABLE clienti_***
... CONSTRAINT pk_clienti_***  
...;

--b
ALTER TABLE vanzari_***
... CONSTRAINT fk_vanzari_clienti_***  
...;

--c
ALTER TABLE vanzari_***
... CONSTRAINT fk_vanzari_clienti_***  
...;

--d
delete from clienti_***
where ...;
ROLLBACK;

--5
select a.table_name, 
       a.column_name, a.constraint_name,  
       constraint_type, status, 
       validated, index_name, rely
from user_cons_columns a, user_constraints b
where a.constraint_name=b.constraint_name
and   ...
order by 1;
