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