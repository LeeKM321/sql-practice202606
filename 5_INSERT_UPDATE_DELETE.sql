
-- 표준 SQL로 테이블 구조 확인하기
SELECT
	column_name, data_type, is_nullable, column_default 
FROM information_schema."columns"
WHERE table_name = 'departments';

-- INSERT 첫번째 방법 (모든 컬럼 데이터를 한번에 지정해서 삽입)
-- VALUES 같은 경우 순서대로 컬럼 데이터를 전달 (null 허용 컬럼은 안주셔도 됩니다.)
INSERT INTO departments
VALUES(302, '아이티영업부');

SELECT * FROM departments;

-- INSERT 두번째 방법 (직접 컬럼을 지목해서 저장, null 허용 여부 잘 확인)
INSERT INTO departments
	(department_id, location_id, department_name)
VALUES(305, 1900, '총무부');

--------------------------------------------------------------------

-- UPDATE
-- UPDATE 테이블이름 SET 컬럼=값, 컬럼=값.... WHERE 누구를 수정할지 (조건)
-- 조건을 지정하지 않으면 대상이 테이블 전체가 됨! (주의!)

UPDATE departments
SET department_name = '야옹이!'
WHERE department_id = 300;

SELECT * FROM departments;

UPDATE departments
SET
	department_name = 'IT부서',
	manager_id = 101,
	location_id = 2000
WHERE department_id = 300;

-------------------------------------------------------------------------

DELETE FROM departments
WHERE department_id = 300; -- WHERE을 작성하지 않으면 테이블 전체 행이 대상이 됩니다.













