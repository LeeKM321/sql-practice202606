
-- 1. 사용자 계정(Role) 목록 확인
SELECT * FROM pg_roles;


-- 2. 계정 생성 명령
-- PostgreSQL에서는 USER와 ROLE이 거의 같은 개념입니다.
-- LOGIN 권한을 주어야 실제로 접속 가능한 유저 역할을 하게 됩니다.  
CREATE USER user1 WITH PASSWORD 'user1';
-- CREATE ROLE user1 WITH LOGIN PASSWORD 'user1';


/*
 PostgreSQL DCL: GRANT(권한 부여), REVOKE(권한 회수) 
 
 Postgres는 기본적으로 데이터베이스 접속 권한과 스키마 사용 권한이 먼저 필요합니다.
 계정을 생성했다고 바로 활성화가 되는 게 아니라 데이터베이스, 스키마에 접근할 수 있는 권한을 
 일괄적으로 부여해야 합니다.
 */

-- 데이터베이스 접속 권한 부여  
GRANT CONNECT ON DATABASE postgres TO user1;

-- 특정 스키마의 객체(테이블, 시퀀스 등...)들을 사용할 수 있는 권한 부여 
GRANT USAGE ON SCHEMA public TO user1;

-- 특정 테이블만 조회할 수 있는 권한 부여
GRANT SELECT ON TABLE public.employees TO user1;

SELECT * FROM employees;
DELETE FROM employees WHERE employee_id = 100;


-- 3. ROLE(권한의 묶음) 실습 
CREATE ROLE new_emp_role;

-- 롤에 권한 부여하기 
GRANT USAGE ON SCHEMA public TO new_emp_role;
GRANT SELECT, UPDATE, INSERT ON TABLE public.employees TO new_emp_role;
GRANT SELECT, UPDATE ON TABLE public.departments TO new_emp_role;

-- 유저에게 롤 부여하기 (user1은 new_emp_role의 권한을 상속받는다)
GRANT new_emp_role TO user1;

SELECT * FROM employees;

UPDATE employees 
SET salary = 12345
WHERE employee_id = 195;

SELECT * FROM departments;

-- 4. 관리자 권한 부여하기 
ALTER USER user1 WITH SUPERUSER; -- 슈퍼유저 권한 부여 
ALTER USER user1 WITH NOSUPERUSER; -- 슈퍼유저 권한 회수 


CREATE DATABASE test_db;


SELECT datname FROM pg_database;

CREATE SCHEMA my_schema;
DROP SCHEMA my_schema;











