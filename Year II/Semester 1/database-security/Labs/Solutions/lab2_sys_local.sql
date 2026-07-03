--Lab 2

alter pluggable database orclpdb open;

alter user hr account unlock; -- error

show con_name;

alter session set container=orclpdb;

--if password is wrong, we change its password:
alter user hr identified by hr;

show con_name;

alter user hr account unlock; --OK

select name, open_mode from v$pdbs;

alter session set container=cdb$root;

alter session set container=orclpdb;

--1
show con_name;

select value from v$parameter where name='audit_trail';

show parameter audit_trail;

alter system set audit_trail=db,extended scope=spfile; -- not ok, not possible inside pluggable db

alter session set container=cdb$root;

alter system set audit_trail=db,extended scope=spfile; --scope =memory|spfile|both

select value from v$parameter where name='audit_trail';

--as scope = spfile => Oracle instance must be restarted => shutdown immediate & startup in SQL Plus 

audit select table;

show con_name;

desc dba_stmt_audit_opts;

select AUDIT_OPTION, SUCCESS, FAILURE
from dba_stmt_audit_opts;

-- database orclpdb not open after restarting instance:

alter pluggable database orclpdb open;

--HR lauched a query
desc aud$
select OBJ$CREATOR,OBJ$NAME, USERID, sqltext, ntimestamp#
from aud$
order by ntimestamp# desc; 

-- no query audited because the audit was activated in CDB$ROOT and hr belongs to orclpdb

show con_name;

select audit_option, success, failure from dba_stmt_audit_opts;

noaudit select table;

select AUDIT_OPTION, SUCCESS, FAILURE
from dba_stmt_audit_opts;

alter session set container=orclpdb;

audit select table;

select OBJ$CREATOR,OBJ$NAME, USERID, sqltext, ntimestamp#
from aud$
order by ntimestamp# desc; 

---------------------------

-- Resume after 1 week:

show con_name; -- orclpdb

--if not orclpdb:
alter session set container=orclpdb;

--check active audit:
select AUDIT_OPTION, SUCCESS, FAILURE
from dba_stmt_audit_opts;

-- if no rows:
audit select table;

-- if database not open:
alter pluggable database orclpdb open;

select OBJ$CREATOR,OBJ$NAME, USERID, sqltext, ntimestamp#
from aud$
order by ntimestamp# desc; 

-- execute 1 query in hr's session and we will find it in aud$

desc dba_audit_trail;
select owner, OBJ_NAME, timestamp, username, sql_text
from dba_audit_trail
order by timestamp desc;

show parameter audit_trail;

--create a test user:
create user testuser identified by testuser;
grant connect, resource to testuser;

alter user testuser quota unlimited on users;

--Audit report:
-- Find the number of queries executed:
-- - by each user, on each table
-- - by each user, no matter the table
-- - the total number of queries, no matter the user or table
-- Consider only the tables employees, regions, departments.

--Recap rollup
/*select ...
group by rollup a,b,c; 
<=>
select ... 
group by a,b,c
UNION ALL
select ... 
group by a,b
UNION ALL
select ... 
group by a
UNION ALL
select ... */

select username,
    owner, obj_name,
    COUNT(*) AS audit_count
from dba_audit_trail
WHERE lower(OBJ_NAME) IN ('employees', 'departments')
group by rollup (username, (owner, OBJ_NAME));

noaudit select table;

select AUDIT_OPTION, SUCCESS, FAILURE
from dba_stmt_audit_opts;

--hr launches a command select
select owner, OBJ_NAME, timestamp, username, sql_text
from dba_audit_trail
order by timestamp desc;

-- the query is still audited => the sudit is still "enabled" => we must reconnect the user or we restart the pluggable db
alter pluggable database orclpdb close immediate;
alter pluggable database orclpdb open;

-- HR launches a new query and there is no audit data

-- 2
select value from v$parameter where name='audit_trail'; --db, extended

alter system set audit_trail=xml,extended scope=spfile; --error if in wrong container (orclpdb)

alter session set container=cdb$root;
alter system set audit_trail=xml,extended scope=spfile; --ok

select value from v$parameter where name='audit_trail'; --db, extended

--we need to restart in SQL Plus : shutdown immediate & startup

show con_name; -- if cdb root => move to orclpdb

alter session set container=orclpdb;

-- if database not open:
--alter pluggable database orclpdb open;

audit select, insert, update, delete on hr.employees whenever not successful;

-- we ckeck if the audit is enabled
select AUDIT_OPTION, SUCCESS, FAILURE
from dba_stmt_audit_opts;
-- no rows

desc dba_obj_audit_opts;

select owner, object_name, sel, ins, upd, del 
from dba_obj_audit_opts
where lower(object_name) = 'employees';

-- hr launches some unsuccessful statements

show parameter audit;

-- stop the audit
noaudit all on hr.employees;

-- test again - no need to reconnect

--3

show con_name;

-- 
drop table tab_audit_emp;

create table tab_audit_emp (
    id number(4) primary key,
    user_ varchar2(20),
    session_ number(10),
    host_ varchar2(100),
    time_ date,
    delta_records number(5));


drop sequence seq_audit_emp;
create sequence seq_audit_emp;

create or replace trigger audit_employees_before
before delete on hr.employees
declare
    nb_rec_before number;
begin
    SELECT COUNT(*) INTO nb_rec_before FROM hr.employees;
    insert into tab_audit_emp (
        id,
        user_,
        session_,
        host_,
        time_,
        delta_records
    )
    values (
        seq_audit_emp.nextval,
        sys_context('userenv', 'session_user'),
        sys_context('userenv', 'sessionid'),
        sys_context('userenv', 'host'),
        sysdate,
        nb_rec_before
    );
--sys_context('userenv', 'session_user')
--sys_context('userenv', 'sessionid')
--sys_context('userenv', 'host')
end;
/

create or replace trigger audit_employees_after
after delete on hr.employees
declare
    nb_rec_after number;
    id_rec_audit number;
begin
    SELECT COUNT(*) INTO nb_rec_after FROM hr.employees;
    
    select max(id) into id_rec_audit from tab_audit_emp
    WHERE session_ = sys_context('userenv', 'sessionid');
    
    UPDATE tab_audit_emp
    SET delta_records = (select delta_records 
                         from tab_audit_emp
                         where id = id_rec_audit) - nb_rec_after
    where id = id_rec_audit;
    --commit; ? No!!!
end;
/

select * from tab_audit_emp;

--4
create or replace trigger audit_limit_salary
after insert or update of salary on hr.employees
for each row
when (new.salary > 20000)
begin
   insert into tab_audit_emp (
        id,
        user_,
        session_,
        host_,
        time_,
        delta_records
    )
    values (
        seq_audit_emp.nextval,
        sys_context('userenv', 'session_user'),
        sys_context('userenv', 'sessionid'),
        sys_context('userenv', 'host'),
        sysdate,
        -1
    );
end;
/

select t.*, to_char(time_, 'dd/mm/yyyy hh24:mi:ss') Time
from tab_audit_emp t;

