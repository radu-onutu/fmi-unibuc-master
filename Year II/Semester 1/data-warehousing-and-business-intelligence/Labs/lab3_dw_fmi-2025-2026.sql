--LAB 3 DW 
alter session 
set "_optimizer_gather_stats_on_load"=false;

--1
create table tab1_*** (
a1 int,
a2 date default sysdate,
a3 char(2) not null,
a4 varchar2(10) constraint u_a4_tab1_*** unique,
CONSTRAINT pk_tab1_*** primary key(a1));

create table tab2_*** (
b1 number constraint pk_tab2_*** primary key,
b2 number(3,0) constraint ck_b2_tab2_***
   check(b2 between 10 and 100),
b3 varchar2(10) constraint nn_b3_tab2_***
   check (b3 is not null),
b4 number CONSTRAINT fk_b4_tab2_***
   REFERENCES tab1_***); 

--a
desc user_cons_columns

select table_name, column_name, constraint_name
from   user_cons_columns
where  table_name 
in (upper('tab1_***'),upper('tab2_***'));

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
and   a.table_name  
in (upper('tab1_***'),upper('tab2_***'));

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
        'val_'||s_tab1_***.currval);
        
select * from tab1_***;
commit;

desc tab2_***

insert into tab2_***
values (s_tab2_***.nextval, 
        dbms_random.value(low=>10,high=>100),
        'abc',null);
        
select * from tab2_***;
commit;

--f

select a.table_name, column_name,
       a.constraint_name,
       index_name
from user_cons_columns a, user_constraints b
where a.constraint_name=b.constraint_name
and   a.table_name in 
      (upper('tab1_***'),upper('tab2_***'));

--g
select * from tab1_***;

select table_name, num_rows, last_analyzed
from   user_tables a
where  a.table_name in 
      (upper('tab1_***'),upper('tab2_***'));

desc tab1_***

select * 
from   tab1_***
where  a4 = 'val_20';

analyze table tab1_*** compute statistics;

select table_name, num_rows, last_analyzed
from   user_tables a
where  a.table_name in 
      (upper('tab1_***'),upper('tab2_***'));

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
where  a4=1;

select * 
from   tab1_***
where  a4<>'val_20';

--h
alter table tab1_***
drop constraint u_a4_tab1_***;

--alter table tab1_***
--modify constraint u_a4_tab1_*** disable;


select table_name, index_name, uniqueness
from   user_indexes  
where  table_name in 
      (upper('tab1_***'),upper('tab2_***'));

select  a.table_name, 
        column_name, a.constraint_name, generated, 
        constraint_type, search_condition, 
        delete_rule, r_constraint_name, status, 
        validated, rely
from user_cons_columns a, user_constraints b
where a.constraint_name=b.constraint_name
and   a.table_name in 
      (upper('tab1_***'),upper('tab2_***'));

--i
alter table tab1_***
add constraint u_a4_tab1_*** unique(a4);

--alter table tab1_***
--modify constraint u_a4_tab1_*** enable;

select table_name, index_name, uniqueness
from   user_indexes a  
where  a.table_name in 
      (upper('tab1_***'),upper('tab2_***'));

select  a.table_name, 
        column_name, a.constraint_name, generated, 
        constraint_type, search_condition, 
        delete_rule, r_constraint_name, status, 
        validated, rely
from user_cons_columns a, user_constraints b
where a.constraint_name=b.constraint_name
and   a.table_name in 
      (upper('tab1_***'),upper('tab2_***'));;

alter table tab1_***
drop constraint u_a4_tab1_*** keep index;

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
and   a.table_name in 
      (upper('tab1_***'),upper('tab2_***'));

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
add constraint u_a4_tab1_***
unique (a4) using index ind_a4_tab1_***;

select table_name, index_name, uniqueness
from   user_indexes a  
where  a.table_name in 
      (upper('tab1_***'),upper('tab2_***'));

select a.table_name, column_name,a.constraint_name,
       index_name
from user_cons_columns a, user_constraints b
where a.constraint_name=b.constraint_name
and   a.table_name in 
      (upper('tab1_***'),upper('tab2_***'));

--k
alter table tab1_***
drop constraint u_a4_tab1_*** keep index;

select a.table_name, column_name,a.constraint_name,
       index_name
from user_cons_columns a, user_constraints b
where a.constraint_name=b.constraint_name
and   a.table_name in 
      (upper('tab1_***'),upper('tab2_***'));

select table_name, index_name, uniqueness
from   user_indexes a 
where  a.table_name in 
      (upper('tab1_***'),upper('tab2_***'));

alter table tab1_***
add constraint u_a4_tab1_***
unique(a4) using index ind_a4_tab1_***;

--l
--tema

--2
desc plati_***

select * from plati_***;

--a
ALTER TABLE plati_***  
add CONSTRAINT u_plati_*** unique(cod) 
disable validate;

--b
select a.table_name, column_name,a.constraint_name,
       index_name
from user_cons_columns a, user_constraints b
where a.constraint_name=b.constraint_name
and   a.table_name = upper('plati_***');

select  a.table_name, 
        column_name, a.constraint_name, generated, 
        constraint_type, search_condition, 
        delete_rule, r_constraint_name, status, 
        validated, rely
from user_cons_columns a, user_constraints b
where a.constraint_name=b.constraint_name
and   a.table_name = upper('plati_***');

--c
delete from plati_***
where rownum=1;

--d
ALTER TABLE plati_***  
modify CONSTRAINT u_plati_*** enable;

--e
select  a.table_name, 
        column_name, a.constraint_name, generated, 
        constraint_type, search_condition, 
        delete_rule, r_constraint_name, status, 
        validated, rely
from user_cons_columns a, user_constraints b
where a.constraint_name=b.constraint_name
and   a.table_name = upper('plati_***');

select a.table_name, column_name,a.constraint_name,
       index_name
from user_cons_columns a, user_constraints b
where a.constraint_name=b.constraint_name
and   a.table_name = upper('plati_***');

--f
ALTER TABLE plati_***  
drop CONSTRAINT u_plati_*** keep index;

--g
--3
desc produse_***
desc vanzari_***
--a
alter table vanzari_***
add constraint fk_vanzari_produse_***
foreign key(produs_id) 
references produse_***(id_produs)
enable novalidate;

--b
alter table produse_***
add constraint pk_produs_***
primary key(id_produs)
disable validate;

--c
alter table vanzari_***
add constraint fk_vanzari_produse_***
foreign key(produs_id) 
references produse_***(id_produs)
enable novalidate;

--d
alter table produse_***
modify constraint pk_produs_*** enable novalidate;

alter table vanzari_***
add constraint fk_vanzari_produse_***
foreign key(produs_id) 
references produse_***(id_produs)
enable novalidate;

select a.table_name, column_name,a.constraint_name,
       index_name
from user_cons_columns a, user_constraints b
where a.constraint_name=b.constraint_name
and   a.table_name in 
      (upper('vanzari_***'),upper('produse_***'));

--f
alter table produse_***
modify constraint pk_produs_*** disable;

--g
alter table produse_***
modify constraint pk_produs_*** rely;

--h
select a.table_name, column_name,a.constraint_name,
       index_name,
       constraint_type, search_condition, 
        delete_rule, r_constraint_name, status, 
        validated, rely
from user_cons_columns a, user_constraints b
where a.constraint_name=b.constraint_name
and   a.table_name in 
      (upper('vanzari_***'),upper('produse_***'));

--i
alter table produse_***
modify constraint pk_produs_*** disable;

--4
select a.table_name, 
       a.column_name, a.constraint_name,  
       constraint_type, status, 
       validated, index_name, rely
from user_cons_columns a, user_constraints b
where a.constraint_name=b.constraint_name
and   a.table_name in 
      (upper('vanzari_***'),upper('produse_***'),
       upper('clienti_***'));
order by 1;

desc clienti_***
--a
ALTER TABLE clienti_***
add CONSTRAINT pk_clienti_***  
primary key (id_client)
rely disable novalidate;

--b
ALTER TABLE vanzari_***
add CONSTRAINT fk_vanzari_clienti_***  
foreign key (client_id)
references clienti_***(id_client)
enable novalidate;

--c
ALTER TABLE vanzari_***
add CONSTRAINT fk_vanzari_clienti_***  
foreign key (client_id)
references clienti_***(id_client)
rely disable novalidate;

--d
delete from clienti_***
where id_client=94;
ROLLBACK;

--5
select a.table_name, 
       a.column_name, a.constraint_name,  
       constraint_type, status, 
       validated, index_name, rely
from user_cons_columns a, user_constraints b
where a.constraint_name=b.constraint_name
and   a.table_name in 
      (upper('vanzari_***'),upper('produse_***'),
       upper('clienti_***'))
order by 1;
