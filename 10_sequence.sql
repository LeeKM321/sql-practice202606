
-- 1. 시퀀스 생성 (순차적으로 증가, 감소하는 값을 만들어 주는 객체)
CREATE SEQUENCE test_seq
	START WITH 1000 -- 시작값 
	INCREMENT BY 100 -- 증감값
	MAXVALUE 10000 -- 최대값 
	MINVALUE 1 -- 최소값 
	NO CYCLE; -- 순환 여부 (기본값이 NOCYCLE이라 생략 가능 )

CREATE TABLE test_tbl (
	test_no INT PRIMARY KEY,
	test_msg VARCHAR(100)
);


-- 2. 데이터 삽입 (시퀀스 값 활용)
INSERT INTO test_tbl
VALUES(nextval('test_seq'), 'test message');

SELECT * FROM test_tbl;


-- 3. 시퀀스 단독 조회
SELECT currval('test_seq');


-- 4. 시퀀스 속성 수정 
-- START WITH은 수정할 수 없습니다.
ALTER SEQUENCE test_seq MAXVALUE 9999;
ALTER SEQUENCE test_seq INCREMENT BY 5;

-- 5. 시퀀스 삭제
DROP SEQUENCE test_seq;












