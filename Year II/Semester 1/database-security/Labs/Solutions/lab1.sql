-- lab. 1

create or replace procedure encrypt1(text in varchar2, encrypted_text out varchar2) as
   key varchar2(8) := '12345678';
   raw_text raw(100);
   raw_key raw(100);
   op_mode pls_integer;
begin
   raw_text := utl_i18n.string_to_raw(text, 'AL32UTF8');
   raw_key := utl_i18n.string_to_raw(key, 'AL32UTF8');
   
   op_mode := dbms_crypto.encrypt_des + dbms_crypto.pad_zero + dbms_crypto.chain_ecb;
   
   encrypted_text := dbms_crypto.encrypt(raw_text, op_mode, raw_key);
   
   dbms_output.put_line('Encryption result: ' || encrypted_text);

end;
/

--Test
variable encryption_result varchar2(200);
execute encrypt1('Plain Text', :encryption_result);
print encryption_result;

--Test 2 (with anonymous block)
declare
  result varchar2(200);
begin
   encrypt1('Plain Text', result);
   dbms_output.put_line('Test result: ' || result); 
end;
/

--2
create or replace procedure decrypt1(encrypted_text in varchar2, decrypted_text out varchar2) as
   key varchar2(8) := '12345678';
   --raw_text raw(100);
   raw_key raw(100);
   op_mode pls_integer;
begin
   
   raw_key := utl_i18n.string_to_raw(key, 'AL32UTF8');
   
   op_mode := dbms_crypto.encrypt_des + dbms_crypto.pad_zero + dbms_crypto.chain_ecb;
   
   decrypted_text := utl_i18n.raw_to_char(dbms_crypto.decrypt(encrypted_text, op_mode, raw_key), 'AL32UTF8');
   
   dbms_output.put_line('Decryption result: ' || decrypted_text);

end;
/

--Test 1 (bind variable)
variable decryption_result varchar2(200);
execute decrypt1(:encryption_result, :decryption_result);
print decryption_result;

--Test 2 (with anonymous block)
declare
  encrypt_result varchar2(200);
  decrypt_result varchar2(200);
begin
   encrypt1('Plain Text', encrypt_result);
   decrypt1(encrypt_result, decrypt_result); 
   dbms_output.put_line('Test result: ' || decrypt_result); 
end;
/

-- ex. 3
create sequence seq_id_key start with 1 increment by 1;

drop sequence seq_id_key;

create table keys_table (
    id_key number constraint pk_keys_table primary key,
    key raw(16) not null,
    table_name varchar2(30) not null
);

drop table keys_table;

create table employees_crypt (
    parity number(1),
    employee_id_crypt varchar2(100) primary key,
    salary_crypt varchar2(100)
);

drop table employees_crypt;

create or replace procedure encrypt_even_odd as
    odd_key raw(16);
    even_key raw(16);
    key raw(16);
    
    operation_mode pls_integer;
    
    cursor c_crypt is select employee_id, salary from employees;
    
    raw_empid raw(100);
    raw_salary raw(100);
    
    result_empid raw(100);
    result_salary raw(100);
    
    cnt number := 1;
    
 begin
    odd_key := dbms_crypto.randombytes(16);
    even_key := dbms_crypto.randombytes(16);
    
    insert into keys_table values (seq_id_key.nextval, odd_key, 'employees');
    insert into keys_table values (seq_id_key.nextval, even_key, 'employees');
    
    operation_mode := dbms_crypto.encrypt_aes128 + dbms_crypto.pad_pkcs5+ dbms_crypto.chain_cbc;
    
    for rec in c_crypt loop
        raw_empid := utl_i18n.string_to_raw(rec.employee_id, 'AL32UTF8');
        raw_salary := utl_i18n.string_to_raw(rec.salary, 'AL32UTF8');
        
        if (mod(cnt, 2) =1) then 
            key := odd_key;
        else 
            key := even_key;
        end if;
        
        result_empid := dbms_crypto.encrypt(raw_empid, operation_mode, key);
        result_salary := dbms_crypto.encrypt(raw_salary, operation_mode, key);
        
        insert into employees_crypt values (mod(cnt, 2), result_empid, result_salary);
        cnt := cnt+ 1;
    end loop;    
    commit;
 end;
 /
 
 -- ACID = atomicitate, consistenta, integritate, durabilitate  
 
EXECUTE encrypt_even_odd;

SELECT * FROM keys_table;

SELECT * FROM employees_crypt;

-- ex. 4
UPDATE employees_crypt
SET salary_crypt = '1F4'
WHERE rownum = 1;

SELECT * FROM employees_crypt;

rollback;

--ex. 5
create table employees_decrypt (
    employee_id varchar2(100) primary key,
    salary varchar2(100)
);

create or replace procedure decrypt_even_odd as
    odd_key raw(16);
    even_key raw(16);
    key raw(16);
    
    operation_mode pls_integer;
    
    cursor c_crypt is select parity, employee_id_crypt, salary_crypt from employees_crypt;
    
    raw_empid raw(100);
    raw_salary raw(100);
    
    result_empid raw(100);
    result_salary raw(100);
    
 begin
    SELECT key INTO odd_key FROM keys_table 
    WHERE id_key = (select max(id_key) from keys_table
                    where mod(id_key, 2) = 1);
                    
    SELECT key INTO even_key FROM keys_table 
    WHERE id_key = (select max(id_key) from keys_table
                    where mod(id_key, 2) = 0);
    
    operation_mode := dbms_crypto.encrypt_aes128 + dbms_crypto.pad_pkcs5+ dbms_crypto.chain_cbc;
    
    for rec in c_crypt loop
        raw_empid := rec.employee_id_crypt;
        raw_salary := rec.salary_crypt;
        
        if (rec.parity = 1) then 
            key := odd_key;
        else 
            key := even_key;
        end if;
        
        result_empid := dbms_crypto.decrypt(raw_empid, operation_mode, key);
        result_salary := dbms_crypto.decrypt(raw_salary, operation_mode, key);
        
        insert into employees_decrypt values (utl_i18n.raw_to_char(result_empid, 'AL32UTF8'), 
                                              utl_i18n.raw_to_char(result_salary, 'AL32UTF8'));
        
    end loop;    
    commit;
 end;
 /

EXECUTE decrypt_even_odd;

SELECT * FROM employees;

select * from keys_table;

select * from employees_crypt;


truncate table employees_crypt;

EXECUTE encrypt_even_odd;

select * from employees_decrypt;

select * from employees;

select * from employees_decrypt where employee_id='100';

truncate table employees_decrypt;

EXECUTE decrypt_even_odd;

select * from employees_decrypt;

--ex. 6
 CREATE OR REPLACE FUNCTION HASH_SH256 RETURN RAW IS
    v_emp employees%ROWTYPE;
    v_hash RAW(32);
BEGIN
    SELECT * INTO v_emp FROM EMPLOYEES WHERE employee_id = 104;
    v_hash := DBMS_CRYPTO.hash(
                UTL_RAW.cast_to_raw(
                         v_emp.employee_id || v_emp.first_name || v_emp.last_name || v_emp.email || v_emp.phone_number || v_emp.hire_date || v_emp.job_id || v_emp.salary || v_emp.commission_pct || v_emp.manager_id || v_emp.department_id
                       ),
                DBMS_CRYPTO.HASH_SH256
              );

    RETURN v_hash;
END;
/

DECLARE
    hash1 RAW(32);
    hash2 RAW(32);
BEGIN
    hash1 := HASH_SH256();
    DBMS_OUTPUT.PUT_LINE(hash1);
    UPDATE EMPLOYEES SET salary = salary + 0.2 * salary WHERE employee_id = 104;
    hash2 := HASH_SH256();
    DBMS_OUTPUT.PUT_LINE(hash2);
    if hash1 != hash2 then
        dbms_output.put_line('Integrity KO!');
    else
        dbms_output.put_line('Integrity OK!');
    end if;    
END;
/

rollback;

