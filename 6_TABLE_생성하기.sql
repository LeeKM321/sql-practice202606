
CREATE TABLE dept (
	dept_no BIGSERIAL,
	dept_name VARCHAR(14),
	loca VARCHAR(15), -- 타 DBMS는 ()안의 숫자를 byte 크기, postgres는 글자 수
	dept_date TIMESTAMP DEFAULT NOW(),
	dept_bonus NUMERIC(8)
);


SELECT * FROM dept;

INSERT INTO dept
	(dept_name, loca, dept_bonus)
VALUES('test2', '경기도', 2000000);


-- 컬럼명 수정
ALTER TABLE dept
RENAME COLUMN dept_bonus TO bonus;

-- 컬럼 추가
ALTER TABLE dept
ADD COLUMN dept_comment VARCHAR(100);

-- 컬럼 삭제 
ALTER TABLE dept
DROP COLUMN bonus;

SELECT * FROM dept2;

-- 테이블명 변경 
ALTER TABLE dept
RENAME TO dept2;

-- 컬럼 속성 변경 (타입 변경하실 때 기존 테이블에 들어가 있는 값을 확인하셔야 합니다!)
ALTER TABLE dept2
ALTER COLUMN loca TYPE NUMERIC(4);

-- 테이블 삭제 (구조는 남겨두고 내부 데이터만 모두 삭제)
TRUNCATE TABLE dept2;

-- 테이블 자체 삭제 
DROP TABLE dept2;










