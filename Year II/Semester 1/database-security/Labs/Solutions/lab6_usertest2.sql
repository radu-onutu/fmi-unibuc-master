create table student (
  id number(4) primary key,
  last_name varchar2(30) not null,
  first_name varchar2(30) not null,
  year_study number(1) not null,
  specialty varchar2(10),
  group_ number(3)
);

create table subject (
  id number(4) primary key,
  title varchar2(50));
  
create table homework (
  id number(4) primary key,
  subject_id number(4) references subject(id),
  post_date date,
  teacher_id number(4));
  
create table solves (
    student_id number(4) not null references student(id),
    homework_id number(4) not null references homework(id),
    upload_date date,
    grade number(4,2),
    evaluation_date date,
    primary key(student_id, homework_id));
    
insert into student values(135,'Avramescu','Anton',5,'Inf',531); 
insert into student values(212,'Antim','Tudor',5,'Inf',532); 
insert into student values(314,'Tinca','Ana',5,'Inf',531);
insert into student values(411,'Caludescu','Aristida',5,'Inf',532);

insert into subject values(1,'DB Security');

insert into homework values(1,1,SYSDATE-45,1); 
insert into homework values(2,1,SYSDATE-30,1); 
insert into homework values(3,1,SYSDATE+7,2); 
insert into homework values(4,1,SYSDATE+28,1);

insert into solves values(135,1,sysdate-50,null,null); 
insert into solves values(212,1,sysdate-45,null,null); 
insert into solves values(135,2,sysdate-35,null,null); 
insert into solves values(212,2,sysdate-35,null,null); 
insert into solves values(314,2,sysdate-30,null,null); 
insert into solves values(135,3,sysdate,null,null);
COMMIT; 

select * from student;
select * from homework; 
select * from subject;
select * from solves;

create or replace package pack_masking is
    function f_masking(str varchar2) return varchar2; 
    function f_masking(nb number) return number; 
    function f_masking_group(nb number) return number;
end;
/

create or replace package body pack_masking is
    type t_tabind is table of number index by pls_integer; 
    v_tabind t_tabind;
    function f_masking (str varchar2) return varchar2 is 
        v_str varchar2(100);
        v_len number; 
    begin
        v_str := substr(str,1,1);
        select length(str) into v_len from dual;
        v_str := rpad(v_str,v_len,'*'); -- we keep only the first 
        --character and we fill with "* " up to the 
        --original string’s length
        return v_str; 
    end f_masking;
    
    function f_masking(nb number) return number is
        v_len number; 
        v_min number; 
        v_max number;
        v_seed VARCHAR2(100); 
        v_new_nb number;
    begin
        if v_tabind.exists(nb) then
            return v_tabind(nb); --it will be used when we mask the 
            --foreign key in the table SOLVES
        else
            --we generate a random number which should start with the 
            -- same digit and should have the same length as nb 
            v_len:=length(to_char(nb)); 
            dbms_output.put_line('length='||v_len);
            v_min:=to_number(rpad(substr(to_char(nb),1,1),v_len,'0'));
            v_max:=to_number(rpad(substr(to_char(nb),1,1),v_len,'9'));
            dbms_output.put_line('min='||v_min||' max=' || v_max);
            v_seed:=TO_CHAR(SYSTIMESTAMP,'YYYYDDMMHH24MISSFFFF');
            DBMS_RANDOM.seed (val => v_seed);
            v_new_nb:=round(DBMS_RANDOM.value(
            low => v_min, high => v_max),0);
            v_tabind(nb):=v_new_nb; 
            return v_new_nb;
        end if;
    end f_masking;
    
    function f_masking_group (nb number) return number is 
        v_new_nb number;
        v_len number; 
    begin
        v_len:=length(to_char(nb)); 
        v_new_nb:=to_number(rpad(substr(to_char(nb),1,1),v_len,'0')); 
        return v_new_nb;
    end;
end;
/

--The expdp command which will be launched in Command Prompt (cmd)
expdp usertest2/usertest2@localhost:1521/orclpdb.local tables=student,solves remap_data=student.last_name:pack_masking.f_masking remap_data=student.first_name:pack_masking.f_masking remap_data=student.group_:pack_masking.f_masking_group remap_data=student.id:pack_masking.f_masking remap_data=solves.student_id:pack_masking.f_masking directory=DIREXP dumpfile=EXPORT_FILE.dmp

--The impdp command which will be launched in Command Prompt (cmd)
impdp usertest2/usertest2@localhost:1521/orclpdb.local directory=DIREXP dumpfile=EXPORT_FILE.DMP TABLES=student,solves remap_table=student:stud1 remap_table=solves:solv1

select * from stud1;
select * from student;
select * from solv1; 
select * from solves;

desc stud1;
desc solv1;