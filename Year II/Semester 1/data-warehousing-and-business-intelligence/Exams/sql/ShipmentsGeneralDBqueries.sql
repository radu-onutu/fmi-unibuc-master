ALTER SESSION SET CONTAINER = XEPDB1;
ALTER DATABASE OPEN;

CREATE USER app_user_oltp IDENTIFIED BY "password123"
DEFAULT TABLESPACE users 
TEMPORARY TABLESPACE temp
QUOTA UNLIMITED ON users;

CREATE USER app_user_dw IDENTIFIED BY "password123"
DEFAULT TABLESPACE users
TEMPORARY TABLESPACE temp
QUOTA UNLIMITED ON users;

GRANT CREATE SESSION, CREATE TABLE, CREATE VIEW, CREATE SEQUENCE, CREATE TRIGGER, CREATE PROCEDURE TO app_user_oltp;
GRANT CREATE SESSION, CREATE TABLE, CREATE VIEW, CREATE SEQUENCE, CREATE TRIGGER, CREATE PROCEDURE TO app_user_dw;

-- pe oltp rulam urmatoarea comanda dupa create ca sa putem efectua ELT pe tabelele lui

BEGIN
  FOR t IN (
    SELECT table_name
    FROM user_tables
  ) LOOP
    EXECUTE IMMEDIATE
      'GRANT SELECT ON app_user_oltp.' || t.table_name || ' TO app_user_dw';
  END LOOP;
END;
/

-- pe oltp si dw rulam urmatoarele comenzi ca sa dam drop la tabele

BEGIN
  FOR t IN (
    SELECT table_name
    FROM user_tables
  ) LOOP
    EXECUTE IMMEDIATE
      'DROP TABLE ' || t.table_name || ' CASCADE CONSTRAINTS';
  END LOOP;
END;
/