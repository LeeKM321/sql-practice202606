-- WHERE절 비교 (데이터 값은 대/소문자를 구분합니다.)
SELECT
	first_name,
	last_name,
	job_id
FROM employees
WHERE job_id = 'IT_PROG';


SELECT
	*
FROM employees
WHERE last_name = 'King';


SELECT 
	*
FROM employees
WHERE salary >= 15000
AND salary < 20000;


SELECT 
	*
FROM employees
WHERE hire_date = '1994-08-17'; -- 날짜는 ISO 형식(하이픈 연결)


-- 데이터의 행 제한 (BETWEEN, IN, LIKE)
SELECT 
	*
FROM employees
WHERE salary BETWEEN 15000 AND 20000;

-- 날짜도 BETWEEN 연산 가능!
SELECT 
	*
FROM employees
WHERE hire_date BETWEEN '1994-01-01' AND '1994-12-31';

-- IN 연산자 (특정 값들과 비교할 때 사용)
SELECT 
	*
FROM employees
WHERE job_id IN ('IT_PROG', 'AD_VP', 'FI_MGR');

SELECT 
	*
FROM employees
WHERE manager_id IN (101, 102, 103);

-- LIKE 연산 (지정 문자열 포함 여부)
SELECT
	first_name, last_name, hire_date
FROM employees
WHERE first_name LIKE 'W%';

SELECT
	first_name, last_name, hire_date
FROM employees
WHERE first_name LIKE '%t';

SELECT
	first_name, last_name, hire_date
FROM employees
WHERE first_name LIKE '%t%';

-- 날짜 타입에서 LIKE 사용 시에는 날짜타입을 문자열로 변경하는 TO_CHAR 사용
-- TO_CHAR(날짜컬럼, 형태)
SELECT
	first_name, last_name, hire_date
FROM employees
WHERE TO_CHAR(hire_date, 'YY-MM-DD') LIKE '94%';

-- PostgreSQL 스타일
SELECT
	first_name, last_name, hire_date
FROM employees
WHERE hire_date::TEXT LIKE '1994%';

-- IS NULL: null 값을 찾음.
SELECT * FROM employees
WHERE commission_pct IS NULL;

SELECT * FROM employees
WHERE commission_pct IS NOT NULL;

-- AND가 OR보다 연산 순서가 빠름.
SELECT
	*
FROM employees
WHERE job_id = 'IT_PROG'
OR job_id = 'FI_MGR'
AND salary >= 6000;

SELECT
	*
FROM employees
WHERE (job_id = 'IT_PROG'
OR job_id = 'FI_MGR')
AND salary >= 6000;


-- 데이터의 정렬 (SELECT 구문의 가장 마지막에 배치, 실행도 가장 마지막에 실행)
-- ASC: 오름차 (default)
-- DESC: 내림차 
SELECT 
	*
FROM employees
ORDER BY hire_date;

SELECT
	first_name,
	last_name,
	job_id
FROM employees
WHERE job_id = 'IT_PROG'
ORDER BY first_name DESC;

SELECT
	first_name,
	salary * 12 AS 연봉
FROM employees
ORDER BY 연봉 DESC;












