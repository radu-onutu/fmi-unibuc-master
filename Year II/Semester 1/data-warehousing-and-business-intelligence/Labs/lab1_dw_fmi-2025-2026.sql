--LAB 1 DW&BI
--4
--b
SELECT * FROM TAB; 
--c
SELECT TABLE_NAME FROM USER_TABLES;
--d
--e
SELECT TABLE_NAME FROM all_TABLES;
SELECT TABLE_NAME FROM all_TABLES
where table_name like 'DIM%';

--6
BEGIN 
FOR i IN (SELECT SYNONYM_NAME AS v_sinonim 
          FROM   USER_SYNONYMS 
          WHERE  INSTR(SYNONYM_NAME,'DIM_') <> 0)  
LOOP  
EXECUTE IMMEDIATE 'RENAME ' || i.v_sinonim || ' TO ' ||  
LTRIM(i.v_sinonim, 'DIM_'); 
END LOOP; 
END; 
/ 

--b
SELECT SYNONYM_NAME FROM USER_SYNONYMS;

--8
--a
CREATE TABLE vanzari_***  
AS  
SELECT *  
FROM   vanzari;

select count(*) from vanzari_***;

--d
desc user_constraints 
select CONSTRAINT_NAME,CONSTRAINT_TYPE,
       DELETE_RULE,STATUS
from user_constraints
where table_name = upper('vanzari_***');

select CONSTRAINT_NAME,CONSTRAINT_TYPE,
       DELETE_RULE,STATUS
from all_constraints
where table_name = upper('vanzari');

--9
--a
select table_name from user_tables
where TABLE_NAME LIKE '%_%';

select table_name from user_tables
where TABLE_NAME not LIKE '%_%';

select table_name from user_tables
where REGEXP_LIKE (TABLE_NAME, '(_)');

select table_name from user_tables
where not REGEXP_LIKE (TABLE_NAME, '(_)');

select table_name from user_tables
where TABLE_NAME LIKE '%\_%' escape '\';

--b
select synonym_name
from user_synonyms
where not REGEXP_LIKE (synonym_NAME, '(_)')
and synonym_name <>upper('vanzari');

--d
BEGIN
 FOR i IN (SELECT SYNONYM_NAME AS v_sinonim
 FROM USER_SYNONYMS
 WHERE not REGEXP_LIKE (synonym_NAME, '(_)')
and synonym_NAME <> upper('vanzari')) 
 LOOP 
 EXECUTE IMMEDIATE 'create table ' || i.v_sinonim 
 || '_*** as select * from ' || i.v_sinonim;
 END LOOP;
END;
/