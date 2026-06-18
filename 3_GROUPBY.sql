
-- 집계 함수 (aggregate function)
-- AVG, MAX, MIN, SUM, COUNT
-- 여러 행을 묶어서 한 번에 함수를 적용
-- 그룹화를 따로 하지 않는다면 그룹은 테이블 전체가 됩니다.
SELECT 
	AVG(salary),
	MAX(salary),
	MIN(salary),
	SUM(salary),
	COUNT(salary)
FROM employees;

SELECT COUNT(*) FROM employees;
SELECT COUNT(first_name) FROM employees;
SELECT COUNT(commission_pct) FROM employees; -- null이 아닌 행의 수
SELECT COUNT(manager_id) FROM employees; -- null은 카운팅 되지 않습니다.


-- 부서별로 그룹화, 집계함수 사용
SELECT
	department_id,
	AVG(salary),
	COUNT(*)
FROM employees
GROUP BY department_id;

-- 집계 함수는 단독적으로 사용할 때는 테이블 전체가 그룹의 대상이 되지만
-- 일반 컬럼과 동시에 조회할 수 없습니다. 일반 컬럼을 그룹화 해야 합니다.
SELECT
	department_id,
	AVG(salary),
	COUNT(*)
FROM employees; -- 에러 


-- GROUP BY절을 사용할 때 GROUP절에 묶이지 않은 컬럼은 조회할 수 없습니다.
SELECT
	job_id,
	department_id,
	AVG(salary),
	COUNT(*)
FROM employees
GROUP BY department_id; -- 에러 

-- GROUP BY절 2개 이상 사용
SELECT
	job_id,
	department_id,
	AVG(salary),
	COUNT(*)
FROM employees
GROUP BY department_id, job_id
ORDER BY department_id;

-- GROUP BY를 통해 그룹화 할 때, 조건을 지정할 경우 HAVING을 사용
-- WHERE은 일반 조건절, GROUP BY보다 먼저 진행됩니다.
SELECT
	department_id,
	AVG(salary),
	COUNT(*)
FROM employees
GROUP BY department_id
HAVING AVG(salary) > 7000;

-- 부서 아이디가 50 이상인 사원을 부서별로 그룹화 시키고
-- 그룹 급여 평균 5000 이상만 조회
-- SQL 실행 순서: FROM -> WHERE -> GROUP BY -> HAVING -> SELECT -> ORDER BY
SELECT
	department_id,
	AVG(salary) AS 평균급여 
FROM employees
WHERE department_id >= 50
GROUP BY department_id
HAVING AVG(salary) >= 5000
ORDER BY 평균급여 DESC;

/*
사원 테이블에서 commission_pct(커미션) 컬럼이 null이 아닌 사람들의
department_id(부서별) salary(월급)의 평균, 합계, count를 구합니다.
조건 1) 월급의 평균은 커미션을 적용시킨 월급입니다.
조건 2) 평균은 소수 2째 자리에서 절사 하세요.
 */
SELECT 
	department_id,
	TRUNC(AVG(salary + salary*commission_pct), 2) AS avg_salary,
	SUM(salary + salary*commission_pct) AS total_salary,
	COUNT(*) AS count
FROM employees
WHERE commission_pct IS NOT NULL
GROUP BY department_id;












