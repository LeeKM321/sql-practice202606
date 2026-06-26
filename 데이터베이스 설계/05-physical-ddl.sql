-- =====================================================================
-- 물리 모델 DDL — 도서관 대출 관리 시스템 (PostgreSQL)
-- ---------------------------------------------------------------------
-- 설계 다섯째 산출물(물리적 모델링 - 기본).
-- CP62 논리 모델(04-logical-normalization.md)을 실제 PostgreSQL 스키마로 구현한다.
--   * 자료형 선택  * 제약(NOT NULL·DEFAULT·UNIQUE·CHECK)
--   * 키(PK·FK·UK) * 참조 무결성 동작(CASCADE / SET NULL / RESTRICT)
--
-- 재실행 안전: 맨 위에서 의존 역순으로 DROP 후 다시 생성한다.
-- 실행: psql -f 05-physical-ddl.sql  (또는 DBeaver에서 전체 실행)
-- =====================================================================

-- ── 0. 재실행을 위한 정리 (자식 → 부모 순서로 삭제) ──────────────────
DROP TABLE IF EXISTS book_author CASCADE;
DROP TABLE IF EXISTS loan        CASCADE;
DROP TABLE IF EXISTS copy        CASCADE;
DROP TABLE IF EXISTS book        CASCADE;
DROP TABLE IF EXISTS author      CASCADE;
DROP TABLE IF EXISTS member      CASCADE;

-- 참조 동작 비교용 데모 테이블도 정리
DROP TABLE IF EXISTS demo_employee CASCADE;
DROP TABLE IF EXISTS demo_department CASCADE;


-- ── 1. MEMBER (회원) ────────────────────────────────────────────────
-- 인공 기본키(member_id) + 자연키(email)는 UNIQUE 대체키로.
CREATE TABLE member (
    member_id  SERIAL       PRIMARY KEY,           -- 자동증가 정수 PK (대리키)
    name       VARCHAR(50)  NOT NULL,
    email      VARCHAR(100) NOT NULL UNIQUE,        -- 대체키: 유일하지만 PK는 아님 (C-1)
    phone      VARCHAR(20),                         -- NULL 허용(선택)
    joined_at  DATE         NOT NULL DEFAULT CURRENT_DATE
);

-- ── 2. BOOK (도서) ──────────────────────────────────────────────────
CREATE TABLE book (
    book_id    SERIAL       PRIMARY KEY,
    isbn       VARCHAR(20)  NOT NULL UNIQUE,        -- 대체키 (C-6)
    title      VARCHAR(200) NOT NULL,
    publisher  VARCHAR(100)                         -- NULL 허용(선택)
);

-- ── 3. AUTHOR (저자) ────────────────────────────────────────────────
CREATE TABLE author (
    author_id  SERIAL      PRIMARY KEY,
    name       VARCHAR(50) NOT NULL
);

-- ── 4. COPY (사본) ──────────────────────────────────────────────────
-- 도서에 의존하는 중심 엔티티. book_id 는 FK.
-- 참조 동작: 사본이 남아 있는 도서는 함부로 못 지우게 RESTRICT.
CREATE TABLE copy (
    copy_id    SERIAL      PRIMARY KEY,
    book_id    INTEGER     NOT NULL,
    location   VARCHAR(50),                         -- 서가 위치(선택)
    CONSTRAINT fk_copy_book
        FOREIGN KEY (book_id) REFERENCES book (book_id)
        ON DELETE RESTRICT                          -- 사본이 있으면 도서 삭제 거부
);

-- ── 5. LOAN (대출) ──────────────────────────────────────────────────
-- 행위(트랜잭션) 엔티티. 회원·사본을 FK 로 참조.
-- returned_at NULL = 아직 반납 안 함(대출 중).
-- CHECK 로 업무 규칙(반납예정일 >= 대출일)을 DB 차원에서 강제.
CREATE TABLE loan (
    loan_id      SERIAL  PRIMARY KEY,
    member_id    INTEGER NOT NULL,
    copy_id      INTEGER NOT NULL,
    loaned_at    DATE    NOT NULL DEFAULT CURRENT_DATE,
    due_at       DATE    NOT NULL,
    returned_at  DATE,                              -- NULL = 대출 중
    CONSTRAINT fk_loan_member
        FOREIGN KEY (member_id) REFERENCES member (member_id)
        ON DELETE RESTRICT,                         -- 대출 이력 있는 회원 삭제 거부
    CONSTRAINT fk_loan_copy
        FOREIGN KEY (copy_id) REFERENCES copy (copy_id)
        ON DELETE RESTRICT,
    CONSTRAINT chk_loan_due_after_loaned
        CHECK (due_at >= loaned_at)                 -- 반납예정일은 대출일 이후 (C-3 토대)
);

-- ── 6. BOOK_AUTHOR (저술 — 연결 엔티티) ─────────────────────────────
-- N:M 해소. 복합 기본키 (book_id, author_id).
-- 참조 동작: 도서/저자가 사라지면 그 연결 행은 의미가 없으므로 CASCADE.
CREATE TABLE book_author (
    book_id    INTEGER NOT NULL,
    author_id  INTEGER NOT NULL,
    PRIMARY KEY (book_id, author_id),               -- 복합 PK = 같은 (책,저자) 쌍 중복 방지
    CONSTRAINT fk_ba_book
        FOREIGN KEY (book_id) REFERENCES book (book_id)
        ON DELETE CASCADE,                          -- 도서 삭제 시 연결 행도 함께 삭제
    CONSTRAINT fk_ba_author
        FOREIGN KEY (author_id) REFERENCES author (author_id)
        ON DELETE CASCADE
);


-- =====================================================================
-- 7. 참조 동작(ON DELETE) 비교 데모 — SET NULL 포함
-- ---------------------------------------------------------------------
-- 본 도서관 스키마는 CASCADE(book_author)·RESTRICT(copy·loan)를 쓴다.
-- 세 번째 동작 SET NULL 을, 익숙한 부서-사원 관계로 따로 보여준다.
--   부서가 사라지면 사원은 남되 소속(department_id)만 NULL 로 비운다.
-- =====================================================================
CREATE TABLE demo_department (
    dept_id  SERIAL      PRIMARY KEY,
    name     VARCHAR(50) NOT NULL
);

CREATE TABLE demo_employee (
    emp_id        SERIAL      PRIMARY KEY,
    name          VARCHAR(50) NOT NULL,
    department_id INTEGER,                          -- NULL 허용해야 SET NULL 가능
    CONSTRAINT fk_emp_dept
        FOREIGN KEY (department_id) REFERENCES demo_department (dept_id)
        ON DELETE SET NULL                          -- 부서 삭제 시 사원의 소속만 비움
);


-- =====================================================================
-- 8. 샘플 데이터 (검증·실습용)
-- =====================================================================
INSERT INTO member (name, email, phone) VALUES
    ('김철수', 'kim@ex.com',  '010-1111-2222'),
    ('이영희', 'lee@ex.com',  NULL),
    ('박지민', 'park@ex.com', '010-3333-4444');

INSERT INTO book (isbn, title, publisher) VALUES
    ('978-89-001', '클린 코드',       '인사이트'),
    ('978-89-002', '해리포터',         '문학사'),
    ('978-89-003', '리팩터링',         '한빛');

INSERT INTO author (name) VALUES
    ('마틴'),       -- author_id = 1
    ('펑'),         -- author_id = 2
    ('롤링');       -- author_id = 3

-- 클린코드(1) = 마틴(1) + 펑(2), 해리포터(2) = 롤링(3), 리팩터링(3) = 마틴(1)
INSERT INTO book_author (book_id, author_id) VALUES
    (1, 1), (1, 2), (2, 3), (3, 1);

-- 사본: 클린코드 2권, 해리포터 1권, 리팩터링 1권
INSERT INTO copy (book_id, location) VALUES
    (1, 'A-1'), (1, 'A-2'), (2, 'B-5'), (3, 'C-3');

-- 대출: 김철수가 클린코드 사본(1) 대출 중(미반납), 이영희는 반납 완료
INSERT INTO loan (member_id, copy_id, loaned_at, due_at, returned_at) VALUES
    (1, 1, '2026-06-01', '2026-06-15', NULL),
    (2, 3, '2026-06-02', '2026-06-16', '2026-06-10');

-- 데모(SET NULL)
INSERT INTO demo_department (name) VALUES ('개발팀'), ('운영팀');
INSERT INTO demo_employee (name, department_id) VALUES
    ('홍길동', 1), ('성춘향', 1), ('임꺽정', 2);


-- =====================================================================
-- 9. 검증 쿼리 (실행하면 결과가 맞는지 눈으로 확인)
-- =====================================================================

-- 9-1. 대출 중(미반납) 목록 — returned_at IS NULL
-- 결과: 김철수 / 클린 코드  (1행)
SELECT m.name AS 회원, b.title AS 도서, l.due_at AS 반납예정
FROM   loan l
JOIN   member m ON m.member_id = l.member_id
JOIN   copy   c ON c.copy_id   = l.copy_id
JOIN   book   b ON b.book_id   = c.book_id
WHERE  l.returned_at IS NULL;

-- 9-2. 도서별 저자 목록 (N:M 연결 확인)
-- 결과: 클린 코드=마틴,펑 / 리팩터링=마틴 / 해리포터=롤링
SELECT b.title AS 도서, string_agg(a.name, ', ' ORDER BY a.name) AS 저자들
FROM   book b
JOIN   book_author ba ON ba.book_id = b.book_id
JOIN   author a       ON a.author_id = ba.author_id
GROUP  BY b.title
ORDER  BY b.title;

-- 9-3. SET NULL 동작 확인: 개발팀(dept_id=1) 삭제 → 소속 사원의 department_id 가 NULL 로
DELETE FROM demo_department WHERE dept_id = 1;
-- 결과: 홍길동·성춘향 의 department_id = NULL, 임꺽정은 그대로 2
SELECT name, department_id FROM demo_employee ORDER BY emp_id;


-- =====================================================================
-- 10. 제약 위반 데모 (주석 해제하면 *의도된 에러* 발생 — 제약이 살아있다는 증거)
-- =====================================================================
-- (A) UNIQUE 위반: 이미 있는 이메일 재사용
-- INSERT INTO member (name, email) VALUES ('홍길동', 'kim@ex.com');
--   → ERROR: duplicate key value violates unique constraint "member_email_key"

-- (B) FK 위반: 없는 도서(999)의 사본 추가
-- INSERT INTO copy (book_id) VALUES (999);
--   → ERROR: insert or update on table "copy" violates foreign key constraint

-- (C) RESTRICT 위반: 사본이 있는 도서(1) 삭제 시도
-- DELETE FROM book WHERE book_id = 1;
--   → ERROR: update or delete on table "book" violates foreign key constraint ... on table "copy"

-- (D) CHECK 위반: 반납예정일이 대출일보다 과거
-- INSERT INTO loan (member_id, copy_id, due_at, loaned_at) VALUES (1, 2, '2026-06-01', '2026-06-10');
--   → ERROR: new row for relation "loan" violates check constraint "chk_loan_due_after_loaned"

-- (E) CASCADE 동작: 도서(3=리팩터링) 삭제 → book_author 의 (3,1) 행도 자동 삭제
--     (단 copy 가 RESTRICT 라, 먼저 copy 를 지워야 book 삭제 가능 — 동작 순서 학습용)
-- =====================================================================
