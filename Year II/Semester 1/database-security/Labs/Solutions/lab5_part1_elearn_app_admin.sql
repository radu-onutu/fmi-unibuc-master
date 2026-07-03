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
