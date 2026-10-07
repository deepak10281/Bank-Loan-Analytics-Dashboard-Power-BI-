USE bank_loan_analytics;

/* =====================================================
   BANK LOAN ANALYTICS - SHORT & SIMPLE QUERIES
   Table: loan_data
   Good Loan = Fully Paid / Current | Bad Loan = Charged Off
   INT_RATE and DTI are decimals (0.12 = 12%)
   ===================================================== */


/* ---------- PART 1: BASICS (SELECT, WHERE, GROUP BY) ---------- */

-- 1. Total applications
SELECT COUNT(*) AS total_applications FROM loan_data;

-- 2. Total funded amount
SELECT SUM(LOAN_AMOUNT) AS total_funded FROM loan_data;

-- 3. Total amount received
SELECT SUM(TOTAL_PAYMENT) AS total_received FROM loan_data;

-- 4. Average interest rate %
SELECT ROUND(AVG(INT_RATE) * 100, 2) AS avg_int_rate FROM loan_data;

-- 5. Average DTI %
SELECT ROUND(AVG(DTI) * 100, 2) AS avg_dti FROM loan_data;

-- 6. Good loan applications
SELECT COUNT(*) AS good_loans
FROM loan_data
WHERE LOAN_STATUS IN ('Fully Paid', 'Current');

-- 7. Bad loan applications
SELECT COUNT(*) AS bad_loans
FROM loan_data
WHERE LOAN_STATUS = 'Charged Off';

-- 8. Applications by loan status
SELECT LOAN_STATUS, COUNT(*) AS applications
FROM loan_data
GROUP BY LOAN_STATUS;

-- 9. Funded vs received by purpose
SELECT PURPOSE, SUM(LOAN_AMOUNT) AS funded, SUM(TOTAL_PAYMENT) AS received
FROM loan_data
GROUP BY PURPOSE
ORDER BY funded DESC;

-- 10. Top 5 states by applications
SELECT ADDRESS_STATE, COUNT(*) AS applications
FROM loan_data
GROUP BY ADDRESS_STATE
ORDER BY applications DESC
LIMIT 5;

-- 11. Loan term analysis
SELECT TRIM(TERM) AS term, COUNT(*) AS applications, SUM(LOAN_AMOUNT) AS funded
FROM loan_data
GROUP BY TRIM(TERM);

-- 12. Home ownership with at least 1000 applications (HAVING)
SELECT HOME_OWNERSHIP, COUNT(*) AS applications
FROM loan_data
GROUP BY HOME_OWNERSHIP
HAVING COUNT(*) >= 1000;


/* ---------- PART 2: CASE WHEN ---------- */

-- 13. Good vs bad loan percentage
SELECT
    ROUND(SUM(CASE WHEN LOAN_STATUS <> 'Charged Off' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS good_loan_pct,
    ROUND(SUM(CASE WHEN LOAN_STATUS =  'Charged Off' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS bad_loan_pct
FROM loan_data;

-- 14. Bad loan rate by grade
SELECT
    GRADE,
    COUNT(*) AS applications,
    ROUND(SUM(CASE WHEN LOAN_STATUS = 'Charged Off' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS bad_loan_rate
FROM loan_data
GROUP BY GRADE
ORDER BY GRADE;

-- 15. Income groups
SELECT
    CASE
        WHEN ANNUAL_INCOME < 40000  THEN 'Low'
        WHEN ANNUAL_INCOME < 75000  THEN 'Medium'
        ELSE 'High'
    END AS income_group,
    COUNT(*) AS applications
FROM loan_data
GROUP BY income_group;


/* ---------- PART 3: DATE FUNCTIONS ---------- */

-- 16. Monthly applications, funded and received
SELECT
    MONTH(ISSUE_DATE)     AS month_no,
    MONTHNAME(ISSUE_DATE) AS month_name,
    COUNT(*)              AS applications,
    SUM(LOAN_AMOUNT)      AS funded,
    SUM(TOTAL_PAYMENT)    AS received
FROM loan_data
GROUP BY MONTH(ISSUE_DATE), MONTHNAME(ISSUE_DATE)
ORDER BY month_no;


/* ---------- PART 4: SUBQUERIES ---------- */

-- 17. Loans bigger than the average loan amount
SELECT COUNT(*) AS above_avg_loans
FROM loan_data
WHERE LOAN_AMOUNT > (SELECT AVG(LOAN_AMOUNT) FROM loan_data);

-- 18. States with more applications than the average state
SELECT ADDRESS_STATE, COUNT(*) AS applications
FROM loan_data
GROUP BY ADDRESS_STATE
HAVING COUNT(*) > (
    SELECT AVG(cnt)
    FROM (SELECT COUNT(*) AS cnt FROM loan_data GROUP BY ADDRESS_STATE) AS t
);

-- 19. Percentage share of each loan status
SELECT
    LOAN_STATUS,
    COUNT(*) AS applications,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM loan_data), 2) AS pct_share
FROM loan_data
GROUP BY LOAN_STATUS;


/* ---------- PART 5: CTEs ---------- */

-- 20. Latest month (MTD) KPIs
WITH latest AS (
    SELECT MAX(ISSUE_DATE) AS max_date FROM loan_data
)
SELECT
    COUNT(*)           AS mtd_applications,
    SUM(LOAN_AMOUNT)   AS mtd_funded,
    SUM(TOTAL_PAYMENT) AS mtd_received
FROM loan_data, latest
WHERE YEAR(ISSUE_DATE)  = YEAR(max_date)
  AND MONTH(ISSUE_DATE) = MONTH(max_date);

-- 21. Good vs bad loan summary
WITH classified AS (
    SELECT
        LOAN_AMOUNT,
        TOTAL_PAYMENT,
        CASE WHEN LOAN_STATUS = 'Charged Off' THEN 'Bad Loan' ELSE 'Good Loan' END AS loan_type
    FROM loan_data
)
SELECT
    loan_type,
    COUNT(*)           AS applications,
    SUM(LOAN_AMOUNT)   AS funded,
    SUM(TOTAL_PAYMENT) AS received
FROM classified
GROUP BY loan_type;

-- 22. Grades with bad loan rate above the overall rate
WITH grade_rate AS (
    SELECT GRADE,
           AVG(LOAN_STATUS = 'Charged Off') * 100 AS bad_rate
    FROM loan_data
    GROUP BY GRADE
)
SELECT GRADE, ROUND(bad_rate, 2) AS bad_loan_rate
FROM grade_rate
WHERE bad_rate > (SELECT AVG(LOAN_STATUS = 'Charged Off') * 100 FROM loan_data)
ORDER BY bad_rate DESC;


/* ---------- PART 6: WINDOW FUNCTIONS ---------- */

-- 23. Percentage of total applications by purpose  (SUM OVER)
SELECT
    PURPOSE,
    COUNT(*) AS applications,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS pct_of_total
FROM loan_data
GROUP BY PURPOSE
ORDER BY applications DESC;

-- 24. Rank states by funded amount  (RANK)
SELECT
    ADDRESS_STATE,
    SUM(LOAN_AMOUNT) AS funded,
    RANK() OVER (ORDER BY SUM(LOAN_AMOUNT) DESC) AS state_rank
FROM loan_data
GROUP BY ADDRESS_STATE
ORDER BY state_rank
LIMIT 10;

-- 25. Month-over-month change in funded amount  (LAG)
WITH monthly AS (
    SELECT MONTH(ISSUE_DATE) AS month_no, SUM(LOAN_AMOUNT) AS funded
    FROM loan_data
    GROUP BY MONTH(ISSUE_DATE)
)
SELECT
    month_no,
    funded,
    LAG(funded) OVER (ORDER BY month_no) AS prev_month_funded,
    ROUND((funded - LAG(funded) OVER (ORDER BY month_no)) * 100.0
          / LAG(funded) OVER (ORDER BY month_no), 2) AS mom_pct
FROM monthly;

-- 26. Running total of applications by month  (SUM OVER with ORDER BY)
WITH monthly AS (
    SELECT MONTH(ISSUE_DATE) AS month_no, COUNT(*) AS applications
    FROM loan_data
    GROUP BY MONTH(ISSUE_DATE)
)
SELECT
    month_no,
    applications,
    SUM(applications) OVER (ORDER BY month_no) AS running_total
FROM monthly;

-- 27. Top purpose within each grade  (ROW_NUMBER + PARTITION BY)
WITH ranked AS (
    SELECT
        GRADE,
        PURPOSE,
        COUNT(*) AS applications,
        ROW_NUMBER() OVER (PARTITION BY GRADE ORDER BY COUNT(*) DESC) AS rn
    FROM loan_data
    GROUP BY GRADE, PURPOSE
)
SELECT GRADE, PURPOSE, applications
FROM ranked
WHERE rn = 1
ORDER BY GRADE;

-- 28. 3-month moving average of funded amount  (AVG OVER ROWS)
WITH monthly AS (
    SELECT MONTH(ISSUE_DATE) AS month_no, SUM(LOAN_AMOUNT) AS funded
    FROM loan_data
    GROUP BY MONTH(ISSUE_DATE)
)
SELECT
    month_no,
    funded,
    ROUND(AVG(funded) OVER (ORDER BY month_no ROWS BETWEEN 2 PRECEDING AND CURRENT ROW), 0) AS moving_avg_3m
FROM monthly;


/* ---------- PART 7: VIEW FOR POWER BI ---------- */
-- Columns are listed one by one (no SELECT *) so it works even if
-- your table already has a LOAN_QUALITY column.

CREATE OR REPLACE VIEW vw_loan_powerbi AS
SELECT
    ID, MEMBER_ID, ISSUE_DATE, PURPOSE, VERIFICATION_STATUS, GRADE, SUB_GRADE,
    HOME_OWNERSHIP, ADDRESS_STATE, LOAN_STATUS, EMP_LENGTH, EMP_TITLE,
    LAST_CREDIT_PULL_DATE, LAST_PAYMENT_DATE, NEXT_PAYMENT_DATE,
    TRIM(TERM) AS TERM, ANNUAL_INCOME, DTI, INSTALLMENT, INT_RATE,
    LOAN_AMOUNT, TOTAL_ACC, TOTAL_PAYMENT,
    CASE WHEN LOAN_STATUS = 'Charged Off' THEN 'Bad Loan' ELSE 'Good Loan' END AS LOAN_CATEGORY
FROM loan_data;
