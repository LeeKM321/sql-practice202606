-- =====================================================================
-- 물리 모델 - 성능 + 설계 검증/역정규화 — 도서관 대출 관리 (PostgreSQL)
-- ---------------------------------------------------------------------
-- 설계 여섯째 산출물(물리적 모델링 - 성능 + 검증·최적화·역정규화).
--   * 인덱스: 왜 빠른가 / 무엇에 거나 / EXPLAIN 으로 효과 측정
--   * FK 열은 자동 인덱스가 아니다 → 직접 건다
--   * 부분 인덱스(현재 대출 중)
--   * 역정규화: 의도적 중복으로 조회 가속 + 그 위험(정합성 드리프트)
--   * 인덱스 안티패턴(과다 인덱스)
--
-- ※ 선행: 05-physical-ddl.sql 을 먼저 실행해 스키마+기본 데이터가 있어야 한다.
--   본 파일은 그 위에 *대용량 데이터*를 얹어 인덱스 효과를 눈으로 보여준다.
-- 실행: psql -f 05-physical-ddl.sql  그리고  psql -f 06-index-and-optimization.sql
-- =====================================================================

-- ── 1. 인덱스 효과를 보려면 데이터가 많아야 한다 (대량 적재) ──────────
-- 회원 1,000명 / 도서 200종 / 사본 400권 / 대출 50,000건 추가.

INSERT INTO member (name, email)
SELECT 'user' || g, 'user' || g || '@bulk.com'
FROM   generate_series(1, 1000) AS g;

INSERT INTO book (isbn, title)
SELECT 'BULK-' || g, 'book ' || g
FROM   generate_series(1, 200) AS g;

-- 대량 도서마다 사본 2권
INSERT INTO copy (book_id, location)
SELECT b.book_id, 'BULK'
FROM   book b CROSS JOIN generate_series(1, 2)
WHERE  b.isbn LIKE 'BULK-%';

-- 대출 50,000건: g 를 회원/사본 배열에 매핑(절대 id 가정 없이 안전).
-- returned_at: 5건 중 1건은 NULL(=현재 대출 중) → 부분 인덱스 demo 용.
WITH m AS (SELECT array_agg(member_id ORDER BY member_id) a FROM member),
     c AS (SELECT array_agg(copy_id   ORDER BY copy_id)   a FROM copy)
INSERT INTO loan (member_id, copy_id, loaned_at, due_at, returned_at)
SELECT m.a[1 + (g % array_length(m.a, 1))],
       c.a[1 + (g % array_length(c.a, 1))],
       DATE '2026-01-01' + (g % 150),
       DATE '2026-01-01' + (g % 150) + 14,
       CASE WHEN g % 5 = 0 THEN NULL
            ELSE DATE '2026-01-01' + (g % 150) + 7 END
FROM   generate_series(1, 50000) AS g, m, c;

-- 통계 갱신(플래너가 올바른 판단을 하도록)
ANALYZE member;
ANALYZE loan;
ANALYZE copy;


-- =====================================================================
-- 2. 인덱스 없이 — 풀 스캔(Seq Scan) 확인
-- ---------------------------------------------------------------------
-- "특정 회원의 대출 내역"을 찾는다. loan.member_id 에 인덱스가 없으면
-- 5만 행을 처음부터 끝까지 훑는다(Seq Scan).
-- =====================================================================
EXPLAIN ANALYZE
SELECT * FROM loan WHERE member_id = 500;
-- 예상: Seq Scan on loan ... (5만 행 전체 훑음)


-- =====================================================================
-- 3. 인덱스 만들기
-- ---------------------------------------------------------------------
-- ★ PK·UNIQUE 는 자동으로 인덱스가 생긴다(member_pkey, member_email_key 등).
--   하지만 FK 열은 PostgreSQL 에서 자동 인덱스가 *아니다* → 직접 걸어야 한다.
-- =====================================================================

-- 3-1. FK·검색에 자주 쓰는 열에 인덱스 (가장 흔한 실무 패턴)
CREATE INDEX idx_loan_member_id ON loan (member_id);
CREATE INDEX idx_loan_copy_id   ON loan (copy_id);
CREATE INDEX idx_copy_book_id   ON copy (book_id);

-- 3-2. 부분 인덱스(partial index) — '현재 대출 중'만 자주 조회한다면,
--      returned_at IS NULL 인 행만 담는 작은 인덱스가 효율적.
CREATE INDEX idx_loan_active ON loan (member_id) WHERE returned_at IS NULL;

-- 3-3. 복합 인덱스 — '회원별 + 대출일순' 같이 함께 쓰는 조건.
CREATE INDEX idx_loan_member_date ON loan (member_id, loaned_at);

ANALYZE loan;
ANALYZE copy;


-- =====================================================================
-- 4. 인덱스 후 — 같은 쿼리가 Index Scan 으로
-- =====================================================================
EXPLAIN ANALYZE
SELECT * FROM loan WHERE member_id = 500;
-- 예상: 인덱스 스캔(Index Scan / Bitmap Index Scan) — member_id 인덱스를 타서
--       Seq Scan 보다 cost 가 확 줄어든다(해당 행만 콕 집음 → 훨씬 빠름).
--       (member_id 가 선두열인 인덱스가 여럿이면 플래너가 그중 하나를 고른다)

-- 부분 인덱스가 쓰이는지 (현재 대출 중)
EXPLAIN ANALYZE
SELECT * FROM loan WHERE member_id = 500 AND returned_at IS NULL;
-- 예상: idx_loan_active 사용


-- =====================================================================
-- 5. 역정규화(denormalization) — 의도적 중복으로 조회 가속
-- ---------------------------------------------------------------------
-- "회원별 현재 대출 건수"를 매번 COUNT 로 세면 비싸다. 자주 본다면
-- member 에 active_loans 열을 *미리 저장*(중복)해 둘 수 있다 → 빠른 조회.
-- 단, 대출/반납 때마다 *반드시 함께 갱신*해야 한다. 안 그러면 값이
-- 실제와 어긋난다(=정합성 드리프트). 이게 역정규화의 대가다.
-- =====================================================================
ALTER TABLE member ADD COLUMN active_loans INTEGER NOT NULL DEFAULT 0;

-- 현재 값으로 한 번 채워 넣기(초기화)
UPDATE member m
SET    active_loans = sub.cnt
FROM  (SELECT member_id, COUNT(*) AS cnt
       FROM   loan WHERE returned_at IS NULL
       GROUP  BY member_id) sub
WHERE m.member_id = sub.member_id;

-- 검증: 미리 저장한 값(active_loans) == 실제 COUNT 가 일치하는가?
-- 결과: 0행이면 완전 일치(드리프트 없음)
SELECT m.member_id, m.active_loans, x.real_cnt
FROM   member m
JOIN  (SELECT member_id, COUNT(*) real_cnt
       FROM loan WHERE returned_at IS NULL GROUP BY member_id) x
  ON   m.member_id = x.member_id
WHERE  m.active_loans <> x.real_cnt;   -- 불일치한 행만 (없어야 정상)


-- =====================================================================
-- 6. 설계 검증 / 안티패턴 (참고 — 주석)
-- ---------------------------------------------------------------------
-- (검증 체크리스트)
--   * 자주 쓰는 조회의 WHERE/JOIN 열에 인덱스가 있나? (특히 FK)
--   * 제약(NOT NULL·UNIQUE·FK·CHECK)으로 잘못된 데이터가 막히나?
--   * 역정규화한 값은 원본과 동기화되나?
--
-- (안티패턴 — 인덱스 과다)
--   인덱스는 조회를 빠르게 하지만 *쓰기(INSERT/UPDATE/DELETE)를 느리게*
--   하고 저장공간을 먹는다. 모든 열에 인덱스를 거는 건 안티패턴.
--   → "자주 조회하는 열에만" 선별해서 건다. 안 쓰는 인덱스는 짐일 뿐.
--   예: 거의 검색 안 하는 phone 에 인덱스 → 이득 없이 쓰기만 느려짐.
-- =====================================================================
-- 현재 loan 에 걸린 인덱스 목록 확인
SELECT indexname FROM pg_indexes WHERE tablename = 'loan' ORDER BY indexname;
