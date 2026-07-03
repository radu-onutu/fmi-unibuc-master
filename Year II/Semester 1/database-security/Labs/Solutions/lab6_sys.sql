--Lab 6
select user from dual;
show con_name;

create user usertest2 identified by usertest2;
grant connect, resource to usertest2;
alter user usertest2 quota unlimited on users;

CREATE OR REPLACE DIRECTORY DIREXP AS 'D:\DBSEC';
grant read, write on directory DIREXP to usertest2;