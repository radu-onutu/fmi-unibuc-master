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

alter user elearn_professor1 identified by professor1;

--2.2
SELECT substr(grantee,1,15) grantee, owner, 
 substr(table_name,1,15) table_name, grantor,privilege 
FROM DBA_TAB_PRIVS 
WHERE grantee='ELEARN_PROFESSOR1';

--3
GRANT ALL ON DBMS_CRYPTO TO ELEARN_APP_ADMIN;

--Lab 5
--Exercise 1
create or replace trigger tr_before_update before update on solves
begin
   if  sys_context('app_ctx', 'working_hours') = 'no' then
      dbms_output.put_line('Out of working hours');
      raise_application_error(-20009, 'You cannot update table solves right now!');
   end if;   
end;
/

select * from solves;

update solves 
set upload_date= sysdate 
where upload_date is null;

update solves set student_id = 1 where student_id=40;

commit;

--2
--2.1

desc student
alter table student rename to student_lab4;

create table student(
    id number primary key,
    last_name varchar2(30), 
    first_name varchar2(30), 
    current_year number, 
    speciality varchar2(3), 
    group_ number);
    
create table subject (
    id number primary key, 
    title varchar2(20));
    
create table exam (
    id number primary key, 
    subject_id number, 
    exam_date date, 
    constraint fk_ex2 foreign key (subject_id) 
        references subject (id));
        
create table assessment (
    student_id number not null,
    exam_id number not null, 
    grade number(4,2) default -1,
    constraint pk_ev1 primary key (student_id, exam_id), 
    constraint fk_ev1 foreign key (student_id) references student(id), 
    constraint fk_ex1 foreign key (exam_id) references exam(id));
    
insert into student values (1,'A','Abc',2,'Inf',231); 
insert into student values(2,'B','Bbc',2,'Inf',231);
insert into subject values(1,'Algebra');
insert into exam values(1,1,sysdate-700); 
insert into exam values(2,1,sysdate-300);
insert into assessment values(1,1,3); 
insert into assessment values(2,1,10); 
insert into assessment values(1,2,9);

SELECT EV.student_id||EV.grade||EX.EXAM_DATE||S.TITLE
 as Info
FROM elearn_app_admin.assessment ev,
 elearn_app_admin.exam ex, elearn_app_admin.subject s
WHERE ev.exam_id=ex.id
AND ex.subject_id=s.id;

CREATE OR REPLACE PROCEDURE PROC_CDYNAM(sql_query VARCHAR2) AS
    TYPE type_ref_c IS REF CURSOR; 
    ref_c type_ref_c;
    v_string VARCHAR2(200); 
BEGIN
    OPEN ref_c FOR sql_query; 
    LOOP
        FETCH ref_c INTO v_string;
        EXIT WHEN ref_c%NOTFOUND; 
        DBMS_OUTPUT.PUT_LINE('STUDENT: '||v_string);
    END LOOP;
    CLOSE ref_c;
END;
/

grant execute on proc_cdynam to elearn_assistant3;

--2.2
CREATE OR REPLACE PROCEDURE  PROC_DYNAM(sql_query VARCHAR2)
AS
    TYPE solutions_table IS TABLE OF 
            ELEARN_APP_ADMIN.SOLVES%ROWTYPE;
    v_table solutions_table;
BEGIN
    EXECUTE IMMEDIATE(sql_query) BULK COLLECT INTO v_table; 
    FOR i IN 1..v_table.COUNT LOOP
        DBMS_OUTPUT.PUT_LINE('STUDENT:'||v_table(i).STUDENT_ID
        ||' HAS THE GRADE:' || NVL(v_table(i).GRADE,0) || ' AT THE 
        HOMEWORK:' || v_table(i).HOMEWORK_ID); 
    END LOOP;
END;
/

GRANT EXECUTE ON PROC_DYNAM TO ELEARN_professor1;

select * from solves;

CREATE OR REPLACE PROCEDURE  PROC_DYNAM(sql_query VARCHAR2)
     AUTHID CURRENT_USER
AS
    TYPE solutions_table IS TABLE OF 
            ELEARN_APP_ADMIN.SOLVES%ROWTYPE;
    v_table solutions_table;
BEGIN
    EXECUTE IMMEDIATE(sql_query) BULK COLLECT INTO v_table; 
    FOR i IN 1..v_table.COUNT LOOP
        DBMS_OUTPUT.PUT_LINE('STUDENT:'||v_table(i).STUDENT_ID
        ||' HAS THE GRADE:' || NVL(v_table(i).GRADE,0) || ' AT THE 
        HOMEWORK:' || v_table(i).HOMEWORK_ID); 
    END LOOP;
END;
/

INSERT INTO SOLVES (HOMEWORK_ID,STUDENT_ID,UPLOAD_DATE) 
VALUES(1,2,SYSDATE-3); 
INSERT INTO SOLVES (HOMEWORK_ID,STUDENT_ID,UPLOAD_DATE) 
VALUES(2,1,SYSDATE-7); 
COMMIT;

select * from solves;

grant select on solves to ELEARN_professor1;

CREATE OR REPLACE PROCEDURE 
    PROC_DYNAM(sql_query VARCHAR2) AUTHID CURRENT_USER
AS
    TYPE solutions_table IS TABLE OF 
            ELEARN_APP_ADMIN.SOLVES%ROWTYPE;
    v_table solutions_table;
    is_ok NUMBER(1) :=0; 
BEGIN
    IF REGEXP_LIKE(sql_query,'SELECT [A-Za-z0-9*]+ [^;]') THEN
        is_ok:=1; 
    END IF;
    IF is_ok = 1 THEN BEGIN
        EXECUTE IMMEDIATE(sql_query) BULK COLLECT INTO v_table;
        FOR i IN 1..v_table.COUNT LOOP
            DBMS_OUTPUT.PUT_LINE('STUDENT:'||v_table(i).STUDENT_ID
            ||' HAS THE GRADE:' || NVL(v_table(i).GRADE,0) || ' AT 
            THE HOMEWORK:' || v_table(i).HOMEWORK_ID); 
        END LOOP;
        END; 
    ELSE
        DBMS_OUTPUT.PUT_LINE('The command contains suspicious 
        malicious code. Only queries are allowed');
    END IF;
END;
/

GRANT DELETE ON ELEARN_APP_ADMIN.SOLVES TO ELEARN_professor1;

select * from solves;
REVOKE DELETE ON ELEARN_APP_ADMIN.SOLVES FROM ELEARN_professor1;


--3
ALTER TABLE USER_ ADD PASSWORD VARCHAR2(32);

CREATE OR REPLACE FUNCTION encryption1(plain_text IN VARCHAR2) 
RETURN VARCHAR2 AS 
    raw_string RAW(20);
    raw_password RAW(20); 
    result RAW(20);
    password VARCHAR2(20) := '12345678';
    operating_mode NUMBER; 
    encrypted_text VARCHAR2(32); 
BEGIN
    raw_string:=utl_i18n.string_to_raw(plain_text,'AL32UTF8');
    raw_password :=utl_i18n.string_to_raw(password,'AL32UTF8');
    operating_mode := DBMS_CRYPTO.ENCRYPT_DES + 
    DBMS_CRYPTO.PAD_ZERO + DBMS_CRYPTO.CHAIN_ECB;
    result := DBMS_CRYPTO.ENCRYPT(raw_string,
    operating_mode,raw_password);
    --dbms_output.put_line(result); 
    encrypted_text := RAWTOHEX(result); 
    RETURN encrypted_text;
END;
/

UPDATE USER_
SET PASSWORD=encryption1('Password1') 
WHERE ID=1; 
UPDATE USER_
SET PASSWORD=encryption1('Password2') 
WHERE ID=2;

select * from user_;

CREATE OR REPLACE PROCEDURE 
VERIFY_LOGIN (P_USERNAME VARCHAR2,P_PASSWORD VARCHAR2) AS
    v_ok NUMBER(2) :=-1; 
BEGIN
    EXECUTE IMMEDIATE 'SELECT COUNT(*) FROM USER_ WHERE USERNAME='''||P_USERNAME||''' AND PASSWORD=encryption1('''||P_PASSWORD||''')' INTO v_ok;
    DBMS_OUTPUT.PUT_LINE('SELECT COUNT(*) FROM USER_ WHERE 
    USERNAME='''||P_USERNAME||''' AND 
    PAROLA=encryption1('''||P_PASSWORD||''')');
    IF v_ok=0 THEN 
        DBMS_OUTPUT.PUT_LINE('VERIFICATION FAILED');
    ELSE
        DBMS_OUTPUT.PUT_LINE('VERIFICATION SUCCESSFUL'); 
    END IF;
END;
/

grant execute on VERIFY_LOGIN to elearn_professor1;

--option1: can it be done through a static query?
CREATE OR REPLACE PROCEDURE 
 VERIFY_LOGIN_SAFE (P_USERNAME VARCHAR2,P_PASSWORD VARCHAR2) AS
v_ok NUMBER(2) :=-1; 
BEGIN
    SELECT COUNT(*) INTO v_ok FROM USER_ WHERE USERNAME=P_USERNAME
    AND PASSWORD=encryption1(P_PASSWORD);
    IF v_ok=0 THEN 
        DBMS_OUTPUT.PUT_LINE('VERIFICATION FAILED');
    ELSE
        DBMS_OUTPUT.PUT_LINE('VERIFICATION SUCCESSFUL'); 
    END IF;
END;
/

grant execute on VERIFY_LOGIN_SAFE to elearn_professor1;

--option2: suppose there is no static sql possible
CREATE OR REPLACE PROCEDURE 
 VERIFY_LOGIN_SAFE2 (P_USERNAME VARCHAR2,P_PASSWORD VARCHAR2) 
AS
    v_ok NUMBER(2) :=-1; 
BEGIN
    EXECUTE IMMEDIATE 'SELECT COUNT(*) FROM USER_ WHERE USERNAME=:name AND PASSWORD=encryption1(:passwd)' 
           INTO v_ok USING P_USERNAME,P_PASSWORD;
    IF v_ok=0 THEN 
        DBMS_OUTPUT.PUT_LINE('VERIFICATION FAILED');
    ELSE
        DBMS_OUTPUT.PUT_LINE('VERIFICATION SUCCESSFUL'); 
    END IF;
END;
/

grant execute on VERIFY_LOGIN_SAFE2 to elearn_professor1;

ALTER TABLE USER_ DROP COLUMN PASSWORD;

--Exercise 2
CREATE OR REPLACE PROCEDURE FIND_DANGERS(P_UPLOAD_DATE VARCHAR2) AS 
  TYPE t_table IS TABLE OF ELEARN_APP_ADMIN.SOLVES%ROWTYPE;
  v_table t_table; 
BEGIN
  EXECUTE IMMEDIATE 'SELECT * FROM SOLVES WHERE TO_CHAR(UPLOAD_DATE,''DD-MM-YYYY HH24:MI:SS'') LIKE''%'||P_UPLOAD_DATE ||'%'''
        BULK COLLECT INTO v_table; 
  FOR i IN 1..v_table.COUNT LOOP
    DBMS_OUTPUT.PUT_LINE('STUDENT:' || v_table(i).STUDENT_ID
    || ' HAS THE GRADE:' ||NVL(v_table(i).GRADE,-1)|| 'AT THE 
    HOMEWORK:' || v_table(i).HOMEWORK_ID || 'UPLOADED ON: '
    || v_table(i).UPLOAD_DATE);
  END LOOP;
END;
/

grant execute on FIND_DANGERS to elearn_assistant3;

desc solves;
desc user_;

select * from student;
alter table student add (resume_studies number(1));

update student set resume_studies =  0 where id = 1;
update student set resume_studies =  1 where id = 2;

commit;

--Lab 5
--1
select sys_context('app_ctx', 'working_hours') from dual;

select * from elearn_app_admin.solves;

execute elearn_app_admin.proc_marking(1,2,3,10);

--2
--2.1
SELECT EV.student_id||EV.grade||EX.EXAM_DATE||S.TITLE
 as Info
FROM elearn_app_admin.assessment ev,
 elearn_app_admin.exam ex, elearn_app_admin.subject s
WHERE ev.exam_id=ex.id
AND ex.subject_id=s.id;

exec elearn_app_admin.proc_cdynam('select last_name from student');

exec elearn_app_admin.proc_cdynam('SELECT EV.student_id||'' '' ||EV.grade||'' ''||EX.EXAM_DATE||S.TITLE  as Info FROM elearn_app_admin.assessment ev,  elearn_app_admin.exam ex, elearn_app_admin.subject s WHERE ev.exam_id=ex.id AND ex.subject_id=s.id');

exec elearn_app_admin.proc_cdynam('delete from assessment');

--Exercise 2
select * from session_privs;
select * from session_roles;
select * from user_tab_privs;
select * from user_col_privs;

execute elearn_app_admin.find_dangers('2023');
execute elearn_app_admin.find_dangers('12-2023');

execute elearn_app_admin.find_dangers('11-2023%'' union select 99 as id_homework, id as id_stud, date_in, 99 as grade, 99 as id_corrector from user_ where username like ''' );
execute elearn_app_admin.find_dangers('2023%'' and student_id in (select id from student where resume_studies = 1) and ''AAA'' like ''');

--Lab 5
--2.2
EXEC ELEARN_APP_ADMIN.PROC_DYNAM('SELECT * FROM ELEARN_APP_ADMIN.SOLVES');
EXEC ELEARN_APP_ADMIN.PROC_DYNAM('DECLARE v_id NUMBER(4); BEGIN DELETE FROM ELEARN_APP_ADMIN.SOLVES;COMMIT; SELECT student_id INTO v_id FROM ELEARN_APP_ADMIN.SOLVES WHERE STUDENT_ID=1 AND HOMEWORK_ID=2; END; ');

select * from elearn_app_admin.solves;

select * from session_privs;
select * from user_tab_privs;

delete from elearn_app_admin.solves;

--after adding authid current_user:
EXEC ELEARN_APP_ADMIN.PROC_DYNAM('SELECT * FROM ELEARN_APP_ADMIN.SOLVES');
EXEC ELEARN_APP_ADMIN.PROC_DYNAM('DECLARE v_id NUMBER(4); BEGIN DELETE FROM ELEARN_APP_ADMIN.SOLVES;COMMIT; SELECT student_id INTO v_id FROM ELEARN_APP_ADMIN.SOLVES WHERE STUDENT_ID=1 AND HOMEWORK_ID=2; END; ');

--after using regexp_like:
EXEC ELEARN_APP_ADMIN.PROC_DYNAM('SELECT * FROM ELEARN_APP_ADMIN.SOLVES');
EXEC ELEARN_APP_ADMIN.PROC_DYNAM('DECLARE v_id NUMBER(4); BEGIN DELETE FROM ELEARN_APP_ADMIN.SOLVES;COMMIT; SELECT student_id INTO v_id FROM ELEARN_APP_ADMIN.SOLVES WHERE STUDENT_ID=1 AND HOMEWORK_ID=2; END; ');

--3
EXEC elearn_app_admin.VERIFY_LOGIN('ELEARN_STUDENT2','Password1');
EXEC elearn_app_admin.VERIFY_LOGIN('ELEARN_STUDENT2','Password2');

EXEC elearn_app_admin.VERIFY_LOGIN('ELEARN_STUDENT2''--','Password2');
EXEC elearn_app_admin.VERIFY_LOGIN('ABRACADABRA99'' OR 1=1 --','HOCUS-POCUS');

--option1
--ACCEPT USERNAME PROMPT 'USER NAME:' 
--ACCEPT PASSWORD PROMPT 'PASSWORD:'
--EXEC elearn_app_admin.VERIFY_LOGIN_SAFE ('&USERNAME','&PASSWORD');

EXEC elearn_app_admin.VERIFY_LOGIN_SAFE('ELEARN_STUDENT2','Password1');
EXEC elearn_app_admin.VERIFY_LOGIN_SAFE('ELEARN_STUDENT2','Password2');

EXEC elearn_app_admin.VERIFY_LOGIN_SAFE('ELEARN_STUDENT2''--','Password2');
EXEC elearn_app_admin.VERIFY_LOGIN_SAFE('ABRACADABRA99'' OR 1=1 --','HOCUS-POCUS');

--option 2
EXEC elearn_app_admin.VERIFY_LOGIN_SAFE2('ELEARN_STUDENT2','Password1');
EXEC elearn_app_admin.VERIFY_LOGIN_SAFE2('ELEARN_STUDENT2','Password2');

EXEC elearn_app_admin.VERIFY_LOGIN_SAFE2('ELEARN_STUDENT2''--','Password2');
EXEC elearn_app_admin.VERIFY_LOGIN_SAFE2('ABRACADABRA99'' OR 1=1 --','HOCUS-POCUS');

--Lab 5
--1
select sys_context('app_ctx', 'working_hours') from dual;

select * from elearn_app_admin.solves;

execute elearn_app_admin.proc_marking(1,2,3,10);

--2
--2.1
SELECT EV.student_id||EV.grade||EX.EXAM_DATE||S.TITLE
 as Info
FROM elearn_app_admin.assessment ev,
 elearn_app_admin.exam ex, elearn_app_admin.subject s
WHERE ev.exam_id=ex.id
AND ex.subject_id=s.id;

exec elearn_app_admin.proc_cdynam('select last_name from student');

exec elearn_app_admin.proc_cdynam('SELECT EV.student_id||'' '' ||EV.grade||'' ''||EX.EXAM_DATE||S.TITLE  as Info FROM elearn_app_admin.assessment ev,  elearn_app_admin.exam ex, elearn_app_admin.subject s WHERE ev.exam_id=ex.id AND ex.subject_id=s.id');

exec elearn_app_admin.proc_cdynam('delete from assessment');

--Lab 5
--1
create or replace trigger tr_before_update before update on solves
begin
   if  sys_context('app_ctx', 'working_hours') = 'no' then
      dbms_output.put_line('Out of working hours');
      raise_application_error(-20009, 'You cannot update table solves right now!');
   end if;   
end;
/

select * from solves;

update solves 
set upload_date= sysdate 
where upload_date is null;

update solves set student_id = 1 where student_id=40;

commit;

--2
--2.1

desc student
alter table student rename to student_lab4;

create table student(
    id number primary key,
    last_name varchar2(30), 
    first_name varchar2(30), 
    current_year number, 
    speciality varchar2(3), 
    group_ number);
    
create table subject (
    id number primary key, 
    title varchar2(20));
    
create table exam (
    id number primary key, 
    subject_id number, 
    exam_date date, 
    constraint fk_ex2 foreign key (subject_id) 
        references subject (id));
        
create table assessment (
    student_id number not null,
    exam_id number not null, 
    grade number(4,2) default -1,
    constraint pk_ev1 primary key (student_id, exam_id), 
    constraint fk_ev1 foreign key (student_id) references student(id), 
    constraint fk_ex1 foreign key (exam_id) references exam(id));
    
insert into student values (1,'A','Abc',2,'Inf',231); 
insert into student values(2,'B','Bbc',2,'Inf',231);
insert into subject values(1,'Algebra');
insert into exam values(1,1,sysdate-700); 
insert into exam values(2,1,sysdate-300);
insert into assessment values(1,1,3); 
insert into assessment values(2,1,10); 
insert into assessment values(1,2,9);

SELECT EV.student_id||EV.grade||EX.EXAM_DATE||S.TITLE
 as Info
FROM elearn_app_admin.assessment ev,
 elearn_app_admin.exam ex, elearn_app_admin.subject s
WHERE ev.exam_id=ex.id
AND ex.subject_id=s.id;

CREATE OR REPLACE PROCEDURE PROC_CDYNAM(sql_query VARCHAR2) AS
    TYPE type_ref_c IS REF CURSOR; 
    ref_c type_ref_c;
    v_string VARCHAR2(200); 
BEGIN
    OPEN ref_c FOR sql_query; 
    LOOP
        FETCH ref_c INTO v_string;
        EXIT WHEN ref_c%NOTFOUND; 
        DBMS_OUTPUT.PUT_LINE('STUDENT: '||v_string);
    END LOOP;
    CLOSE ref_c;
END;
/

grant execute on proc_cdynam to elearn_assistant3;

--2.2
CREATE OR REPLACE PROCEDURE  PROC_DYNAM(sql_query VARCHAR2)
AS
    TYPE solutions_table IS TABLE OF 
            ELEARN_APP_ADMIN.SOLVES%ROWTYPE;
    v_table solutions_table;
BEGIN
    EXECUTE IMMEDIATE(sql_query) BULK COLLECT INTO v_table; 
    FOR i IN 1..v_table.COUNT LOOP
        DBMS_OUTPUT.PUT_LINE('STUDENT:'||v_table(i).STUDENT_ID
        ||' HAS THE GRADE:' || NVL(v_table(i).GRADE,0) || ' AT THE 
        HOMEWORK:' || v_table(i).HOMEWORK_ID); 
    END LOOP;
END;
/
