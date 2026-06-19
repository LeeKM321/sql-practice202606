
-- 테이블 생성과 제약조건
-- : 테이블에 부적절한 데이터가 입력되는 것을 방지하기 위해 규칙을 설정하는 것.

-- 테이블 열레벨 제약조건 (PRIMARY KEY, UNIQUE, NOT NULL, FOREIGN KEY, CHECK)
-- PRIMARY KEY: 테이블의 고유 식별 컬럼입니다. (주요 키)
-- UNIQUE: 유일한 값을 갖게 하는 컬럼 (중복값 방지)
-- NOT NULL: null을 허용하지 않음. (필수값)
-- FOREIGN KEY: 참조하는 테이블의 PRIMARY KEY를 저장하는 컬럼
-- CHECK: 정의된 형식만 저장되도록 허용.

-- 컬럼 레벨 제약 조건 (컬럼 선언마다 제약조건 지정)
-- 제약조건 식별자는 생략이 가능합니다. (PostgreSQL에서 알아서 이름 지음)
CREATE TABLE dept (
	dept_no BIGSERIAL CONSTRAINT dept_deptno_pk PRIMARY KEY,
	dept_name VARCHAR(14) NOT NULL CONSTRAINT dept_deptname_uk UNIQUE,
	loca INTEGER CONSTRAINT dept_loca_locid_fk REFERENCES locations(location_id),
	dept_date TIMESTAMP DEFAULT NOW(),
	dept_bonus NUMERIC(8) CONSTRAINT dept_bonus_ck CHECK(dept_bonus > 1000000),
	man_gender VARCHAR(1) CONSTRAINT dept_gender_ck CHECK(man_gender IN ('M', 'F'))
);


-- 테이블 레벨 제약 조건 (모든 열을 선언 후 제약조건을 한번에 취하는 방식)
CREATE TABLE dept (
	dept_no BIGSERIAL,
	dept_name VARCHAR(14) NOT NULL,
	loca INTEGER, 
	dept_bonus NUMERIC(10),
	man_gender VARCHAR(1),
	
	CONSTRAINT dept_deptno_pk PRIMARY KEY(dept_no),
	CONSTRAINT dept_deptname_uk UNIQUE(dept_name),
	CONSTRAINT dept_loca_locid_fk FOREIGN KEY(loca) REFERENCES locations(location_id),
	CONSTRAINT dept_bonus_ck CHECK(dept_bonus > 1000000),
	CONSTRAINT dept_gender_ck CHECK(man_gender IN ('M', 'F'))
);

-- 제약조건 확인 (FK는 부모테이블(참조테이블)에 없는 값을 INSERT할 수 없음)
INSERT INTO dept
	(dept_name, loca, dept_bonus, man_gender)
VALUES
	('마케팅', 1800, 5000000, 'M');

SELECT * FROM dept;

UPDATE dept
SET loca = 4000
WHERE dept_no = 4; -- 실패 (fk 위반)

UPDATE dept
SET dept_no = 5
WHERE dept_no = 4; -- 실패 (pk 위반)

UPDATE dept
SET dept_bonus = 1000
WHERE dept_no = 4; -- 실패 (check 위반)

-- 타 테이블에서 나의 PK를 참조하는 경우 삭제가 마음대로 안됩니다.
DELETE FROM locations
WHERE location_id = 3000;

-- 제약 조건 삭제하기 (제약 조건 이름으로)
ALTER TABLE dept
DROP CONSTRAINT dept_gender_ck;

-- 제약 조건 추가하기 (꼭 테이블 생성때만 지정할 수 있는 게 아닙니다.)
ALTER TABLE dept
ADD CONSTRAINT man_gender_ck CHECK(man_gender IN ('M', 'F'));














