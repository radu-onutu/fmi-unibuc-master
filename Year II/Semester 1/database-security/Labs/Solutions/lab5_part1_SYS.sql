--Lab 5
--1
show con_name;

--if it is not orclpdb then:
--alter session set container = orclpdb;

CREATE CONTEXT app_ctx USING proced_app_ctx;

CREATE OR REPLACE PROCEDURE proced_app_ctx IS
    v_hour number(3);
BEGIN
    select to_number(to_char(sysdate, 'hh24')) into v_hour from dual;
    
    dbms_output.put_line('The hour is: ' || v_hour);
    
    if v_hour < 10 or v_hour >= 20 then
        dbms_output.put_line('Out of working hours!');
        DBMS_SESSION.set_context ('APP_CTX', 'working_hours', 'no');
    else 
        DBMS_SESSION.set_context ('APP_CTX', 'working_hours', 'yes');
    end if;
END;
/

select to_number(to_char(sysdate, 'hh24')) from dual;

execute proced_app_ctx;

select sys_context('app_ctx', 'working_hours') from dual;

create or replace trigger tr_after_logon
AFTER LOGON
ON DATABASE 
declare
   v_user varchar2(30);
BEGIN
    v_user := sys_context('userenv', 'session_user');
    
    if lower(v_user) like '%elearn_professor%' or lower(v_user) like '%elearn_assistant%' then
        proced_app_ctx(); 
    end if;    
END;
/

