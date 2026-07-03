select user from dual;

--Lab 3

--1
show con_name;

alter session set container=orclpdb;

show  con_name;

select value from v$parameter
where name='os_authent_prefix';

--in cmd:
--echo %username%
--echo %USERDOMAIN%

create user "OPS$LAPTOP-14DQCMA1\letit" identified externally;
grant create session to "OPS$LAPTOP-14DQCMA1\letit";
grant connect  to "OPS$LAPTOP-14DQCMA1\letit";

--to be tested and continued

--according to the requirement of the problem: we create a 
--local account in Windows (named ELEARN_CAT)
-- => DB username = OPS$<domain>\ELEARN_CAT

--who are the database users? => query the database's DD

desc dba_users;

select username, AUTHENTICATION_TYPE from dba_users;

--create local users for the elearning application:
--drop user elearn_app_admin cascade;
create user elearn_app_admin identified by pwdadmin1 password expire;
grant create session to elearn_app_admin;

--connect elearn_app_admin in SQL Plus in order to change the expired password
connect elearn_app_admin/pwdadmin1@127.0.0.1:1521/orclpdb.local

--drop user elearn_student1;
create user elearn_student1 identified by student1;
--password expire
grant create session to elearn_student1;

--drop user elearn_student2;
create user elearn_student2 identified by student2;
--password expire
grant create session to elearn_student2;

--drop user elearn_student3;
create user elearn_student3 identified by student3;
--password expire
grant create session to elearn_student3;

drop user elearn_professor1 cascade;
create user elearn_professor1 identified by professor1;
--password expire
grant create session to elearn_professor1;

drop user elearn_professor2 cascade;
create user elearn_professor2 identified by professor2;
--password expire
grant create session to elearn_professor2;

drop user elearn_assistant3 cascade;
create user elearn_assistant3 identified by professor1;
--password expire
grant create session to elearn_assistant3;

drop user elearn_guest cascade;
create user elearn_guest identified by guest;
--password expire
grant create session to elearn_guest;

select username, AUTHENTICATION_TYPE, ACCOUNT_STATUS, 
       to_char(EXPIRY_DATE, 'dd/mm/yyyy hh24:mi:ss') expiry_date_time, 
       to_char(CREATED, 'dd/mm/yyyy hh24:mi:ss') created_date_time,
       PROFILE
from dba_users
order by created desc;

desc dba_users;

--2
--drop table elearn_audit_connex;

create table elearn_audit_connex (
    id number(8) primary key,
    user_ varchar2(30),
    session_ number (8),
    auth_meth varchar2(40),
    identity varchar2(100),
    host_ varchar2(100),
    login_time date,
    logout_time date);

--drop sequence elearn_seq_connex;    
create sequence elearn_seq_connex start with 1 increment by 1;  

select user from dual;

show con_name;

create or replace trigger elearn_audit_connex_trigger
after LOGON on DATABASE
begin
    if lower(user) like 'elearn%' THEN
        insert into elearn_audit_connex VALUES
        (ELEARN_SEQ_CONNEX.nextval
        , sys_context('userenv', 'session_user')
        , sys_context('userenv', 'sessionid')
        , sys_context('userenv', 'authentication_method')
        , sys_context('userenv', 'authenticated_identity')
        , sys_context('userenv', 'host')
        , sysdate
        , NULL
        );
        commit;
    end if;
end;
/

create or replace trigger elearn_audit_deconnex_trigger
before LOGOFF on DATABASE
begin
    if lower(user) like 'elearn%' THEN
        UPDATE elearn_audit_connex
        SET logout_time = sysdate
        WHERE SESSION_ = sys_context('userenv', 'sessionid')
        AND USER_ = sys_context('userenv', 'session_user');
        commit;
    end if;
end;
/

select t.*, to_char(login_time, 'dd/mm/yyyy hh24:mi:ss') login_datetime, 
    to_char(logout_time, 'dd/mm/yyyy hh24:mi:ss') logout_datetime
from elearn_audit_connex t;

-- TODO: revisit pragma autonomous transaction and adapt the solution

--3
--test 
grant create table to elearn_app_admin;

alter user elearn_app_admin quota unlimited on users;
alter user elearn_professor1 quota 2M on users;
alter user elearn_professor2 quota 2M on users;
alter user elearn_assistant3 quota 2M on users;

alter user elearn_student1 quota 0M on users;
alter user elearn_student2 quota 0M on users;
alter user elearn_student3 quota 0M on users;

alter user elearn_guest quota 0M on users;

--alter user <user_external_authentication> quota 10M on users;

--check user quotas on tablespace users
desc dba_ts_quotas;

select * from dba_ts_quotas
where lower(username) like 'elearn%' or lower(username) like 'ops$%';

--4
drop profile elearn_profile_guest;
create profile elearn_profile_guest limit
    sessions_per_user 3
    idle_time 3
    connect_time 5;

--drop  profile elearn_profile_prof_stud;   
create profile elearn_profile_prof_stud limit
    cpu_per_call 6000
    sessions_per_user 1
    password_life_time 7
    failed_login_attempts 3;
    
alter user elearn_guest profile elearn_profile_guest;
alter user elearn_professor1 profile elearn_profile_prof_stud;
alter user elearn_professor2 profile elearn_profile_prof_stud;
alter user elearn_assistant3 profile elearn_profile_prof_stud;
alter user elearn_student1 profile elearn_profile_prof_stud;
alter user elearn_student2 profile elearn_profile_prof_stud;
alter user elearn_student3 profile elearn_profile_prof_stud;

--find the profile and its settings:
desc dba_profiles;

select * from dba_profiles;

--test
--connect elearn_student1 twice
--if the profile settings are not applied, then:
show parameter resource_limit;
--if it is false, then we must set it to true
alter system set resource_limit=true;

--5
-- test if other_groups exist:
select count(*)
from dba_rsrc_consumer_groups
where consumer_group='OTHER_GROUPS';

desc dba_rsrc_consumer_groups;

create or replace procedure elearn_consumption_plan as
begin
    dbms_resource_manager.clear_pending_area();
    dbms_resource_manager.create_pending_area();
    dbms_resource_manager.create_plan(
                    plan => 'ELEARN_PLAN1', 
                    comment => 'This is a plan for the elearning app');
    
    --consumer groups:
    dbms_resource_manager.create_consumer_group(
                    consumer_group => 'mgmt',
                    comment => 'Groups of sessions of the users who administer the application or the catalog'
                    );
    dbms_resource_manager.create_consumer_group(
                    consumer_group => 'tutors',
                    comment => 'Groups of sessions of the teaching users'
                    );            
    dbms_resource_manager.create_consumer_group(
                    consumer_group => 'receivers',
                    comment => 'Groups of sessions of the student users'
                    );
    
    -- static mappings of the users to the consumer groups
    --Note: the users cannot be mapped to OTHER_GROUPS
    dbms_resource_manager.set_consumer_group_mapping(
        dbms_resource_manager.oracle_user, 'ELEARN_APP_ADMIN', 'mgmt');
    --dbms_resource_manager.set_consumer_group_mapping(
    --    dbms_resource_manager.oracle_user, 'OPS$domain\username', 'mgmt');    
    
    dbms_resource_manager.set_consumer_group_mapping(
        dbms_resource_manager.oracle_user, 'ELEARN_PROFESSOR1', 'tutors');
    dbms_resource_manager.set_consumer_group_mapping(
        dbms_resource_manager.oracle_user, 'ELEARN_PROFESSOR2', 'tutors');
    dbms_resource_manager.set_consumer_group_mapping(
        dbms_resource_manager.oracle_user, 'ELEARN_ASSISTANT3', 'tutors');    
        
    dbms_resource_manager.set_consumer_group_mapping(
        dbms_resource_manager.oracle_user, 'ELEARN_STUDENT1', 'receivers');  
    dbms_resource_manager.set_consumer_group_mapping(
        dbms_resource_manager.oracle_user, 'ELEARN_STUDENT2', 'receivers');
    dbms_resource_manager.set_consumer_group_mapping(
        dbms_resource_manager.oracle_user, 'ELEARN_STUDENT3', 'receivers');      
        
    dbms_resource_manager.create_plan_directive(plan => 'ELEARN_PLAN1',   
                group_or_subplan => 'mgmt', MGMT_P1 => 20);
    dbms_resource_manager.create_plan_directive(plan => 'ELEARN_PLAN1',   
                group_or_subplan => 'tutors', MGMT_P1 => 30); 
    dbms_resource_manager.create_plan_directive(plan => 'ELEARN_PLAN1',   
                group_or_subplan => 'receivers', MGMT_P1 => 40); 
                
    dbms_resource_manager.create_plan_directive(plan => 'ELEARN_PLAN1',   
                group_or_subplan => 'OTHER_GROUPS', MGMT_P1 => 10); 
                
    dbms_resource_manager.validate_pending_area();
    dbms_resource_manager.submit_pending_area();
    
end;
/

select * from dba_rsrc_consumer_groups;

execute elearn_consumption_plan;

desc dba_rsrc_plan_directives;

--for each user, find the plan and the directive values
select b.username, a.group_or_subplan, a.mgmt_p1, a.plan 
from dba_rsrc_plan_directives a left join dba_users b on (a.GROUP_OR_SUBPLAN = b.INITIAL_RSRC_CONSUMER_GROUP)
order by a.plan, b.username;