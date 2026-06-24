
-- PostgreSQL은 기본적으로 오토 커밋이 켜진 상태로 동작합니다.
-- INSERT, UPDATE, DELETE를 실행하면 무조건 COMMIT이 들어가서 데이터가 영구적으로 저장됩니다.
-- 명시적 트랜잭션을 시작하려면 BEGIN 또는 START TRANSACTION을 사용합니다.

SELECT * FROM dept;

BEGIN; -- 1. 트랜잭션 시작(수동 트랜잭션 관리)

INSERT INTO dept
	(dept_name, loca, dept_bonus, man_gender)
VALUES
	('test4', 1900, 4000000, 'M');


INSERT INTO dept
	(dept_name, loca, dept_bonus, man_gender)
VALUES
	('test5', 2000, 3000000, 'F');

DELETE FROM dept
WHERE dept_no = 4;


-- 보류중인 모든 데이터 변경사항을 취소(폐기)하고 트랜잭션 종료.
ROLLBACK;

-- 보류중인 모든 데이터 변경사항을 영구적으로 적용하면서 트랜잭션 종료.
COMMIT;


BEGIN;


-- 세이브포인트: 커밋은 아니지만 특정 데이터베이스 시점을 저장하고 싶을 때 사용
-- 트랜잭션이 열려 있을 때만 사용이 가능합니다.
SAVEPOINT insert_test4;


SELECT * FROM dept;

-- 특정 세이브포인트로 롤백
ROLLBACK TO insert_test4;

ROLLBACK;










