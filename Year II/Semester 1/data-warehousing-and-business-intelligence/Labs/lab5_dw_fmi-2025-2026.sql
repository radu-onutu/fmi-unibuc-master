--lab 5 DW dimension
 
--1
DESC produse_***

/*
ierarhia:     produs ? categorie ? domeniu ? subgrupa ? grupa ? raion 
dependentele: produs ? denumire, descriere, um 
*/
CREATE DIMENSION prod_dim_***
LEVEL produs IS (produse_***.id_produs)
LEVEL categorie IS (produse_***.categorie_5)
LEVEL domeniu IS (produse_***.categorie_4)
LEVEL subgrupa IS (produse_***.categorie_3)
LEVEL grupa IS (produse_***.categorie_2)
LEVEL raion IS (produse_***.categorie_1)
HIERARCHY h1
(produs CHILD OF
 categorie CHILD OF
 domeniu CHILD OF
 subgrupa CHILD OF
 grupa CHILD OF
 raion)
ATTRIBUTE produs 
DETERMINES (produse_***.denumire,
produse_***.descriere, produse_***.um);

--2
DESC timp_***
/*
ierarhiile
zi -> saptamana -> luna -> an
zi -> luna -> trimestru -> semestru -> an
*/

CREATE DIMENSION timp_dim_***
LEVEL zi IS (timp_***.id_timp)
LEVEL saptamana IS (timp_***.saptamana_luna)
LEVEL luna IS (timp_***.luna)
LEVEL trimestru IS (timp_***.trimestru)
LEVEL semestru IS (timp_***.semestru)
LEVEL an IS (timp_***.an)
HIERARCHY h1
(zi CHILD OF
 saptamana CHILD OF
 luna CHILD OF
 an)
HIERARCHY h2
(zi CHILD OF
 luna CHILD OF
 trimestru CHILD OF
 semestru CHILD OF
 an);

--3
DESC user_dimensions 

SELECT dimension_name, invalid, compile_state
FROM   user_dimensions
WHERE  dimension_name like upper('%***');

--4
EXECUTE DEMO_DIM.PRINT_DIM ('timp_dim_***');

--5
EXECUTE DBMS_OUTPUT.ENABLE(10000);
EXECUTE DEMO_DIM.PRINT_ALLDIMS;

--6
--a
DESC timp_***

CREATE TABLE timp_test2_***
( id_timp    number primary key,
  data       date not null,
  saptamana  varchar2(10) not null,
  luna       varchar2(10) not null,
  trimestru  varchar2(10) not null,
  an         number(4) not null);
  
--b
SELECT to_char(sysdate,'j'), 
       sysdate, 
       to_char(sysdate,'w'),
       to_char(sysdate,'mm'), 
       to_char(sysdate,'q'),
       to_char(sysdate,'yyyy') 
FROM   dual;

INSERT INTO timp_test2_***
VALUES (to_char(sysdate,'j'), 
       sysdate, 
       to_char(sysdate,'w'),
       to_char(sysdate,'mm'), 
       to_char(sysdate,'q'),
       to_char(sysdate,'yyyy'));

INSERT INTO timp_test2_***
VALUES (to_char(sysdate+1,'j'), 
       sysdate+1, 
       to_char(sysdate+1,'w'),
       to_char(sysdate+1,'mm'), 
       to_char(sysdate+1,'q'),
       to_char(sysdate+1,'yyyy'));

COMMIT;
SELECT * FROM timp_test2_***;

--c
/*
ierarhia: zi ? saptamana ? luna ? trimestru ? an
*/
CREATE DIMENSION timp_test2_dim_***
LEVEL zi IS (timp_test2_***.data)
LEVEL saptamana IS (timp_test2_***.saptamana)
LEVEL luna IS (timp_test2_***.luna)
LEVEL trimestru IS (timp_test2_***.trimestru)
LEVEL an IS (timp_test2_***.an)
HIERARCHY h
(zi CHILD OF
 saptamana CHILD OF
 luna CHILD OF
 trimestru CHILD OF
 an);

--d
SELECT  to_char(add_months(sysdate,3),'j'),
        add_months(sysdate,3),
        to_char(add_months(sysdate,3),'w'),
        to_char(add_months(sysdate,3),'mm'),
        to_char(add_months(sysdate,3),'q'),
        to_char(add_months(sysdate,3),'yyyy')
FROM dual;

INSERT INTO timp_test2_***
VALUES (to_char(add_months(sysdate,3),'j'),
        add_months(sysdate,3),
        to_char(add_months(sysdate,3),'w'),
        to_char(add_months(sysdate,3),'mm'),
        to_char(add_months(sysdate,3),'q'),
        to_char(add_months(sysdate,3),'yyyy'));

INSERT INTO timp_test2_***
VALUES (to_char(add_months(sysdate,12),'j'),
        add_months(sysdate,12),
        to_char(add_months(sysdate,12),'w'),
        to_char(add_months(sysdate,12),'mm'),
        to_char(add_months(sysdate,12),'q'),
        to_char(add_months(sysdate,12),'yyyy'));

SELECT * FROM timp_test2_***;
COMMIT;

--e
EXECUTE DBMS_DIMENSION.VALIDATE_DIMENSION(UPPER('timp_test2_dim_***'),FALSE,TRUE,'st_id1_***');

--f
SELECT *
FROM   DIMENSION_EXCEPTIONS
WHERE  STATEMENT_ID = 'st_id1_***';

--g
SELECT *
FROM   timp_test2_***
WHERE  ROWID IN (SELECT BAD_ROWID
                 FROM   DIMENSION_EXCEPTIONS
                 WHERE  STATEMENT_ID = 'st_id1_***');
                
--h     
DELETE FROM timp_test2_***
WHERE id_timp IN (2461005,2461370);

SELECT * FROM timp_test2_***;

--i
EXECUTE DBMS_DIMENSION.VALIDATE_DIMENSION(UPPER('timp_test2_dim_***'),FALSE,TRUE,'st_id2_***');

SELECT *
FROM   DIMENSION_EXCEPTIONS
WHERE  STATEMENT_ID = 'st_id2_***';

SELECT *
FROM   timp_test2_***
WHERE  ROWID IN (SELECT BAD_ROWID
                 FROM DIMENSION_EXCEPTIONS
                 WHERE STATEMENT_ID = 'st_id2_***');
--k   
TRUNCATE TABLE timp_test2_***;

DESC timp_test2_***

SELECT  to_char(sysdate,'j'),
        sysdate,
        to_char(sysdate,'yyyy-mm-w'),
        to_char(sysdate,'yyyy-mm'),
        to_char(sysdate,'yyyy-q'),
        to_char(sysdate,'yyyy')
FROM  DUAL;

INSERT INTO timp_test2_***
VALUES (to_char(sysdate,'j'),
        sysdate,
        to_char(sysdate,'yyyy-mm-w'),
        to_char(sysdate,'yyyy-mm'),
        to_char(sysdate,'yyyy-q'),
        to_char(sysdate,'yyyy'));

INSERT INTO timp_test2_***
VALUES (to_char(sysdate+1,'j'),
        sysdate+1,
        to_char(sysdate+1,'yyyy-mm-w'),
        to_char(sysdate+1,'yyyy-mm'),
        to_char(sysdate+1,'yyyy-q'),
        to_char(sysdate+1,'yyyy'));
--to_char(add_months(sysdate,3)
INSERT INTO timp_test2_***
VALUES (
to_char(add_months(sysdate,3),'j'),
to_char(add_months(sysdate,3)),
to_char(add_months(sysdate,3),'yyyy-mm-w'),
to_char(add_months(sysdate,3),'yyyy-mm'),
to_char(add_months(sysdate,3),'yyyy-q'),
to_char(add_months(sysdate,3),'yyyy'));

INSERT INTO timp_test2_***
VALUES (
to_char(add_months(sysdate,12),'j'),
to_char(add_months(sysdate,12)),
to_char(add_months(sysdate,12),'yyyy-mm-w'),
to_char(add_months(sysdate,12),'yyyy-mm'),
to_char(add_months(sysdate,12),'yyyy-q'),
to_char(add_months(sysdate,12),'yyyy'));

SELECT * FROM timp_test2_***;
COMMIT;

EXECUTE DBMS_DIMENSION.VALIDATE_DIMENSION(UPPER('timp_test2_dim_***'),FALSE,TRUE,'st_id3_***');

SELECT *
FROM   DIMENSION_EXCEPTIONS
WHERE STATEMENT_ID = 'st_id3_***';

SELECT *
FROM timp_test2_***
WHERE ROWID IN (SELECT BAD_ROWID
                FROM DIMENSION_EXCEPTIONS
                WHERE STATEMENT_ID = 'st_id3_***');

--l
ALTER TABLE timp_test2_***
ADD (luna_name   varchar2(30),
     luna_number number);

UPDATE  timp_test2_***
SET luna_name=to_char(data,'month'),
    luna_number = to_char(data,'mm');

SELECT * FROM timp_test2_*** order by luna_name;   
SELECT * FROM timp_test2_*** order by luna_number; 

desc timp_***
SELECT * FROM timp_*** order by luna;
     



