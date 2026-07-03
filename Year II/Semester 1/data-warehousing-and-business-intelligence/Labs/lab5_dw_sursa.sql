--lab 5 DW dimension

--1
DESC prod_dim_***

/*
ierarhia:     produs ? categorie ? domeniu ? subgrupa ? grupa ? raion 
dependentele: produs ? denumire, descriere, um 
*/


CREATE DIMENSION prod_dim_***
LEVEL nume_nivel1 IS (produse_***.coloana1)
LEVEL nume_nivel2 IS (produse_***.coloana2)
LEVEL nume_nivel3 IS (produse_***.coloana3)
LEVEL nume_nivel4 IS (produse_***.coloana4)
LEVEL nume_nivel5 IS (produse_***.coloana5)
LEVEL nume_nivel6 IS (produse_***.coloana6)
HIERARCHY h1
(nume_nivel1 CHILD OF
 nume_nivel2 CHILD OF
 nume_nivel3 CHILD OF
 nume_nivel4 CHILD OF
 nume_nivel5 CHILD OF
 nume_nivel6)
ATTRIBUTE nume_nivel 
DETERMINES (nume_tabela.coloana1, nume_tabela.coloana2, nume_tabela.coloana3);

--2
DESC timp_***
/*
ierarhiile
zi ? saptamana ? luna ? an
zi ? lun? ? trimestru ? semestru ?an
*/

CREATE DIMENSION timp_dim_***
LEVEL nume_nivel1 IS (timp_***.coloana1)
LEVEL nume_nivel2 IS (timp_***.coloana2)
LEVEL nume_nivel3 IS (timp_***.coloana3)
LEVEL nume_nivel4 IS (timp_***.coloana4)
LEVEL nume_nivel5 IS (timp_***.coloana5)
LEVEL nume_nivel6 IS (timp_***.coloana6)
HIERARCHY h1
(nume_nivel1 CHILD OF
 nume_nivel2 CHILD OF
 nume_nivel3 CHILD OF
 nume_nivel4)
HIERARCHY h2
(nume_nivel1 CHILD OF
 nume_nivel2 CHILD OF
 nume_nivel3 CHILD OF
 nume_nivel4 CHILD OF
 nume_nivel5);

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
SELECT to_char(sysdate,'j'), sysdate, to_char(sysdate,'w'),
       to_char(sysdate,'mm'), to_char(sysdate,'q'),to_char(sysdate,'yyyy') 
FROM   dual;

INSERT INTO timp_test2_***
VALUES (...);

INSERT INTO timp_test2_***
VALUES (...);

COMMIT;
SELECT * FROM timp_test2_***;

--c
/*
ierarhia: zi ? saptamana ? luna ? trimestru ? an
*/
CREATE DIMENSION timp_test2_dim_***
LEVEL nume_nivel1 IS (timp_test2_***.coloana1)
LEVEL nume_nivel2 IS (timp_test2_***.coloana2)
LEVEL nume_nivel3 IS (timp_test2_***.coloana3)
LEVEL nume_nivel4 IS (timp_test2_***.coloana4)
LEVEL nume_nivel5 IS (timp_test2_***.coloana5)
HIERARCHY h
(nume_nivel1 CHILD OF
 nume_nivel2 CHILD OF
 nume_nivel3 CHILD OF
 nume_nivel4 CHILD OF
 nume_nivel5);

--d
SELECT  to_char(add_months(sysdate,3),'j'),
        add_months(sysdate,3),
        to_char(add_months(sysdate,3),'w'),
        to_char(add_months(sysdate,3),'mm'),
        to_char(add_months(sysdate,3),'q'),
        to_char(add_months(sysdate,3),'yyyy')
FROM dual;

INSERT INTO timp_test2_***
VALUES (...);

INSERT INTO timp_test2_***
VALUES (...);

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
WHERE id_timp IN (...);

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
VALUES (...);

INSERT INTO timp_test2_***
VALUES (...);

INSERT INTO timp_test2_***
VALUES (...);

INSERT INTO timp_test2_***
VALUES (...);

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
     



