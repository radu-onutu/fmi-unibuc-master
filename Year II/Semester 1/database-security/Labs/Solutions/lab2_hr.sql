select user from dual;

select * from employees;

grant select on employees to testuser;
grant select on departments to testuser;

update employees set employee_id=100 where employee_id=101;

delete from employees where department_id=10;

--3
create table employees_bkp031125 as select * from employees;

delete from employees where salary< 1500;

commit;

delete from employees where employee_id not in (select distinct nvl(manager_id, 0) from employees)
   and employee_id not in (select distinct nvl(manager_id, 0) from departments) 
   and employee_id not in (select employee_id from job_history);

select count(*) from employees;

select distinct manager_id from employees;

commit;

insert into employees 
select * from  employees_bkp031125 
where employee_id in (select distinct nvl(manager_id, 0) from employees)
   or employee_id in (select distinct nvl(manager_id, 0) from departments) 
   or employee_id in (select employee_id from job_history); -- NOT OK!!!
   
-- Homework: insert the deleted rows, from the backup   

-- alternative solution:

INSERT INTO employees
SELECT *
FROM employees AS OF TIMESTAMP (SYSTIMESTAMP - INTERVAL '7' MINUTE)
WHERE employee_id NOT IN (SELECT employee_id FROM employees);

select * from employees where employee_id=150;

update employees 
set salary=21000
where employee_id=150;

commit;

update employees 
set salary=10000
where employee_id=150;

commit;
