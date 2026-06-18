/*
 # 조인이란?
 
 - 서로 다른 테이블 간에 설정된 관계가 결합하여 
 1개 이상의 테이블에서 데이터를 조회하기 위해서 사용합니다. 
 
 ANSI 조인 문법: 어느 데이터베이스든 문법이 동일합니다.
 - SELECT 컬럼리스트 
   FROM 테이블 
   JOIN 조인 대상 테이블 
   ON 조인 조건 
*/

-- employees 테이블의 부서 id와 일치하는 departments 테이블의 부서 id를 찾아서
-- 부서 이름을 조회하자 
SELECT
	e.first_name,
	e.department_id,
	d.department_name 
FROM employees e
JOIN departments d 
ON e.department_id = d.department_id;
/*
각각의 테이블에 독립적으로 존재하는 컬럼의 경우에는
테이블 이름을 생략해도 무방합니다. 그러나, 해석의 명확성을 위해
테이블 이름을 작성하셔서 소속을 표현해 주는 것이 바람직합니다.
테이블 이름이 너무 길 시에는 ALIAS를 작성하여 칭합니다.
두 테이블 모두 가지고 있는 컬럼의 경우 반드시 명시해 주셔야 합니다.
*/

-- 3개의 테이블을 내부 조인 (INNER JOIN) 
-- 내부 조인: 조인 조건에 일치하는 행만 반환하는 조인
-- 조인 조건에 일치하지 않는 데이터는 조회 대상에서 제외 
SELECT
	e.first_name,
	e.department_id,
	d.department_name,
	j.job_title 
FROM employees e
JOIN departments d 
ON e.department_id = d.department_id
JOIN jobs j
ON e.job_id = j.job_id;


-- 4개의 테이블 조인 
-- locations 테이블을 붙여서, 부서별 도시명을 꺼내 주세요. (city)
SELECT
	e.first_name,
	e.department_id,
	d.department_name,
	j.job_title,
	loc.city 
FROM employees e
JOIN departments d 
ON e.department_id = d.department_id
JOIN jobs j
ON e.job_id = j.job_id
JOIN locations loc
ON d.location_id = loc.location_id;


-- 외부 조인 (OUTER JOIN)
/*
 상호 테이블간에 일치되는 값으로 연결되는 내부 조인과는 다르게 
 어느 한 테이블에 공통 값이 없더라도 해당 row들이 조회 결과에 
 모두 포함되는 조인을 말합니다.
 */

SELECT
	e.first_name,
	e.department_id,
	d.department_name 
FROM employees e LEFT JOIN departments d 
ON e.department_id = d.department_id;


-- 풀 아우터 조인 (LEFT + RIGHT JOIN)
-- 좌측 테이블과 우측테이블의 데이터를 모두 읽어서 표현하는 외부 조인
SELECT
	e.first_name,
	e.department_id,
	d.department_name 
FROM employees e FULL JOIN departments d 
ON e.department_id = d.department_id;

-- CROSS JOIN은 JOIN 조건을 설정하기 않기 때문에 
-- 단순히 모든 컬럼에 대한 JOIN을 수행합니다. 
-- 실제로는 거의 사용하지 않습니다. 
-- 카티션 곱 (cartesian product): 실행 결과 행의 수 -> 각 테이블의 행을 곱해주면 됨.
SELECT *
FROM employees
CROSS JOIN departments;

-- SELF JOIN이란 동일 테이블 사이의 조인을 말합니다.
-- 동일 테이블 컬럼을 통해 기존의 존재하는 값을 매칭시켜 가져올 때 사용합니다.
SELECT 
	e1.employee_id, e1.first_name, e1.manager_id,
	e2.first_name, e2.employee_id 
FROM employees e1
JOIN employees e2
ON e1.manager_id = e2.employee_id;


-- 각 매니저가 담당하는 사원의 명수
-- 매니저 아이디, 매니저 이름, 사원수 
SELECT
	m.employee_id AS manager_id,
	m.first_name AS manager_name,
	COUNT(*) AS 사원수 
FROM employees e
JOIN employees m
ON e.manager_id = m.employee_id 
GROUP BY m.employee_id, m.first_name
ORDER BY manager_id;


-- NATURAL JOIN
-- 동일한 이름을 갖는 컬럼들에 대해 자동으로 조인조건을 생성하는 기법입니다.
-- 즉, 자동으로 2개 이상의 테이블에서 같은 이름을 가진 컬럼을 찾아 INNER JOIN을 수행합니다.
-- 동일한 이름의 컬럼이 여러 개라면 모두 다 조인 조건에 포함됩니다.
SELECT
    e.first_name,
    e.department_id,
    d.department_name 
FROM employees e
NATURAL JOIN departments d;

SELECT
    e.first_name,
    e.department_id,
    d.department_name 
FROM employees e
JOIN departments d
ON e.department_id = d.department_id
AND e.manager_id = d.manager_id;


-- USING JOIN
-- NATURAL JOIN과는 다르게, USING을 사용하면 원하는 컬럼에 대해서만 선택적 조인조건을
-- 부여할 수 있습니다.
SELECT
    e.first_name,
    e.department_id,
    d.department_name 
FROM employees e
JOIN departments d
USING(department_id);


SELECT department_id, COUNT(*) FROM employees 
GROUP BY department_id;













