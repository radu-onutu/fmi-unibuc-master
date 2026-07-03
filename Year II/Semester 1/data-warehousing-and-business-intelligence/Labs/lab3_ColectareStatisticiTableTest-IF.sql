EXEC dbms_stats.delete_schema_Stats(OWNNAME => upper('master_dw_if')); 

--EXEMPLUL 1 ----------------------------------------------------------------------------------
create table test_***
as select * from clienti;

select table_name, num_rows, last_analyzed
from   user_tables
where  table_name = upper('test_***');

EXEC dbms_stats.delete_table_Stats(OWNNAME => upper('master_dw_if'),TABNAME => upper('test_***')); 

select table_name, num_rows, last_analyzed
from   user_tables
where  table_name = upper('test_***');

EXEC dbms_stats.gather_table_Stats(OWNNAME => upper('master_dw_if'),TABNAME => upper('test_***'));

select table_name, num_rows, last_analyzed
from   user_tables
where  table_name = upper('test_***');

drop table test_*** purge;

--EXEMPLUL 2 ----------------------------------------------------------------------------------
create table test_***
as select * from clienti where 1=2;

select table_name, num_rows, last_analyzed
from   user_tables
where  table_name = upper('test_***');

insert into test_***
select * from clienti;
commit;

select table_name, num_rows, last_analyzed
from   user_tables
where  table_name = upper('test_***');

analyze table test_*** compute statistics;

select table_name, num_rows, last_analyzed
from   user_tables
where  table_name = upper('test_***');

drop table test_*** purge;

--EXEMPLUL 3-----------------------------------------------------
create table test_***
as select /*+ NO_GATHER_OPTIMIZER_STATISTICS */ 
* from clienti;

select table_name, num_rows, last_analyzed
from   user_tables
where  table_name = upper('test_***');

drop table test_*** purge;

analyze table test_*** compute statistics;

select table_name, num_rows, last_analyzed
from   user_tables
where  table_name = upper('test_***');

drop table test_*** purge;

--EXEMPLUL 4 ----------------------------------------------------------------------------------
alter session set "_optimizer_gather_stats_on_load"=false;

create table test_***
as select * from clienti;

select table_name, num_rows, last_analyzed
from   user_tables
where  table_name = upper('test_***');

analyze table test_*** compute statistics;

select table_name, num_rows, last_analyzed
from   user_tables
where  table_name = upper('test_***');

drop table test_*** purge;



