/*
BANK LOAN PORTFOLIO & CREDIT RISK
SQL ANALYSIS — BUSINESS / DASHBOARD VERSION

Database : bank_loan_analytics
Table    : loan_data_cleaned

Business definition from the project:
Good Loan = Fully Paid / Current
Bad Loan  = Charged Off

Important:
INT_RATE and DTI are stored as decimals.
Example: 0.12 = 12%.

This script is organized in the same order as the business analysis:
1. Data understanding and validation
2. Summary KPIs
3. Good vs Bad Loan
4. Loan status
5. Risk analysis
6. Time analysis
7. Overview dimensions
8. Advanced SQL analysis
9. Power BI source view
*/


/* ============================================================
   0. DATABASE / TABLE CHECK
   ============================================================ */

USE bank_loan;

DESCRIBE loan_data_cleaned;

SELECT COUNT(*) AS total_rows
FROM loan_data_cleaned;


/* ============================================================
   1. DATA QUALITY / RAW DATA VALIDATION
   ============================================================ */

-- 1.1 Duplicate full rows
SELECT COUNT(*) AS duplicate_rows
FROM (
    SELECT
        ID,
        MEMBER_ID,
        ISSUE_DATE,
        PURPOSE,
        VERIFICATION_STATUS,
        GRADE,
        HOME_OWNERSHIP,
        ADDRESS_STATE,
        LOAN_STATUS,
        EMP_LENGTH,
        EMP_TITLE,
        LAST_CREDIT_PULL_DATE,
        LAST_PAYMENT_DATE,
        NEXT_PAYMENT_DATE,
        SUB_GRADE,
        TERM,
        ANNUAL_INCOME,
        DTI,
        INSTALLMENT,
        INT_RATE,
        LOAN_AMOUNT,
        TOTAL_ACC,
        TOTAL_PAYMENT,
        COUNT(*) AS row_count
    FROM loan_data_cleaned
    GROUP BY
        ID, MEMBER_ID, ISSUE_DATE, PURPOSE, VERIFICATION_STATUS,
        GRADE, HOME_OWNERSHIP, ADDRESS_STATE, LOAN_STATUS,
        EMP_LENGTH, EMP_TITLE, LAST_CREDIT_PULL_DATE,
        LAST_PAYMENT_DATE, NEXT_PAYMENT_DATE, SUB_GRADE, TERM,
        ANNUAL_INCOME, DTI, INSTALLMENT, INT_RATE,
        LOAN_AMOUNT, TOTAL_ACC, TOTAL_PAYMENT
    HAVING COUNT(*) > 1
) AS duplicates;


-- 1.2 Duplicate loan IDs
SELECT COUNT(*) AS duplicate_loan_ids
FROM (
    SELECT ID
    FROM loan_data_cleaned
    GROUP BY ID
    HAVING COUNT(*) > 1
) AS t;


-- 1.3 Missing values in the key employment field
SELECT
    COUNT(*) AS missing_emp_title
FROM loan_data_cleaned
WHERE EMP_TITLE IS NULL;


-- 1.4 Negative-value validation
SELECT
    SUM(CASE WHEN LOAN_AMOUNT < 0 THEN 1 ELSE 0 END) AS negative_loan_amounts,
    SUM(CASE WHEN DTI < 0 THEN 1 ELSE 0 END) AS negative_dti,
    SUM(CASE WHEN INT_RATE < 0 THEN 1 ELSE 0 END) AS negative_interest_rates
FROM loan_data_cleaned;


/* ============================================================
   2. SUMMARY DASHBOARD KPIs
   ============================================================ */

-- 2.1 Total Loan Applications
SELECT COUNT(*) AS total_applications
FROM loan_data_cleaned;


-- 2.2 Total Funded Amount
SELECT SUM(LOAN_AMOUNT) AS total_funded
FROM loan_data_cleaned;


-- 2.3 Total Amount Received
SELECT SUM(TOTAL_PAYMENT) AS total_received
FROM loan_data_cleaned;


-- 2.4 Average Interest Rate
SELECT ROUND(AVG(INT_RATE) * 100, 2) AS avg_interest_rate_pct
FROM loan_data_cleaned;


-- 2.5 Average DTI
SELECT ROUND(AVG(DTI) * 100, 2) AS avg_dti_pct
FROM loan_data_cleaned;


-- 2.6 All summary KPIs in one result
SELECT
    COUNT(*) AS total_applications,
    SUM(LOAN_AMOUNT) AS total_funded,
    SUM(TOTAL_PAYMENT) AS total_received,
    ROUND(AVG(INT_RATE) * 100, 2) AS avg_interest_rate_pct,
    ROUND(AVG(DTI) * 100, 2) AS avg_dti_pct
FROM loan_data_cleaned;


/* ============================================================
   3. GOOD VS BAD LOAN ANALYSIS
   ============================================================ */

-- 3.1 Good Loan applications
SELECT COUNT(*) AS good_loan_applications
FROM loan_data_cleaned
WHERE LOAN_STATUS IN ('Fully Paid', 'Current');


-- 3.2 Bad Loan applications
SELECT COUNT(*) AS bad_loan_applications
FROM loan_data_cleaned
WHERE LOAN_STATUS = 'Charged Off';


-- 3.3 Good vs Bad Loan percentage
SELECT
    ROUND(
        100.0 * SUM(
            CASE
                WHEN LOAN_STATUS IN ('Fully Paid', 'Current') THEN 1
                ELSE 0
            END
        ) / COUNT(*), 2
    ) AS good_loan_pct,
    ROUND(
        100.0 * SUM(
            CASE
                WHEN LOAN_STATUS = 'Charged Off' THEN 1
                ELSE 0
            END
        ) / COUNT(*), 2
    ) AS bad_loan_pct
FROM loan_data_cleaned;


-- 3.4 Good vs Bad Loan summary
SELECT
    loan_category,
    COUNT(*) AS applications,
    SUM(LOAN_AMOUNT) AS funded_amount,
    SUM(TOTAL_PAYMENT) AS amount_received
FROM (
    SELECT
        CASE
            WHEN LOAN_STATUS IN ('Fully Paid', 'Current') THEN 'Good Loan'
            WHEN LOAN_STATUS = 'Charged Off' THEN 'Bad Loan'
            ELSE 'Other'
        END AS loan_category,
        LOAN_AMOUNT,
        TOTAL_PAYMENT
    FROM loan_data_cleaned
) AS loan_data
GROUP BY loan_category;


/* ============================================================
   4. LOAN STATUS ANALYSIS
   ============================================================ */

-- 4.1 Applications by loan status
SELECT
    LOAN_STATUS,
    COUNT(*) AS applications
FROM loan_data_cleaned
GROUP BY LOAN_STATUS
ORDER BY applications DESC;


-- 4.2 Loan status share of total applications
SELECT
    LOAN_STATUS,
    COUNT(*) AS applications,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM loan_data), 2) AS pct_share
FROMloan_data_cleaned
GROUP BY LOAN_STATUS
ORDER BY applications DESC;


-- 4.3 Funded vs received by loan status
SELECT
    LOAN_STATUS,
    COUNT(*) AS applications,
    SUM(LOAN_AMOUNT) AS funded_amount,
    SUM(TOTAL_PAYMENT) AS amount_received
from loan_data_cleaned
GROUP BY LOAN_STATUS
ORDER BY funded_amount DESC;


/* ============================================================
   5. RISK ANALYSIS
   ============================================================ */

-- 5.1 Bad Loan Rate by Grade
SELECT
    GRADE,
    COUNT(*) AS applications,
    SUM(CASE WHEN LOAN_STATUS = 'Charged Off' THEN 1 ELSE 0 END) AS bad_loans,
    ROUND(
        SUM(CASE WHEN LOAN_STATUS = 'Charged Off' THEN 1 ELSE 0 END)
        * 100.0 / COUNT(*),
        2
    ) AS bad_loan_rate_pct
from loan_data_cleaned
GROUP BY GRADE
ORDER BY GRADE;


-- 5.2 Grades above the overall Bad Loan rate
WITH grade_rate AS (
    SELECT
        GRADE,
        AVG(
            CASE WHEN LOAN_STATUS = 'Charged Off'
                 THEN 1.0 ELSE 0.0 END
        ) * 100 AS bad_rate
    FROM loan_data_cleaned
    GROUP BY GRADE
),
overall_rate AS (
    SELECT
        AVG(
            CASE WHEN LOAN_STATUS = 'Charged Off'
                 THEN 1.0 ELSE 0.0 END
        ) * 100 AS bad_rate
    FROM loan_data_cleaned
)
SELECT
    g.GRADE,
    ROUND(g.bad_rate, 2) AS bad_loan_rate_pct
FROM grade_rate g
CROSS JOIN overall_rate o
WHERE g.bad_rate > o.bad_rate
ORDER BY g.bad_rate DESC;


-- 5.3 Average interest rate by loan status
SELECT
    LOAN_STATUS,
    ROUND(AVG(INT_RATE) * 100, 2) AS avg_interest_rate_pct
FROM loan_data_cleaned
GROUP BY LOAN_STATUS
ORDER BY avg_interest_rate_pct DESC;


-- 5.4 Average DTI by loan status
SELECT
    LOAN_STATUS,
    ROUND(AVG(DTI) * 100, 2) AS avg_dti_pct
FROM loan_data_cleaned
GROUP BY LOAN_STATUS
ORDER BY avg_dti_pct DESC;


-- 5.5 Income groups
SELECT
    CASE
        WHEN ANNUAL_INCOME < 40000 THEN 'Low'
        WHEN ANNUAL_INCOME < 75000 THEN 'Medium'
        ELSE 'High'
    END AS income_group,
    COUNT(*) AS applications,
    SUM(LOAN_AMOUNT) AS funded_amount
FROM loan_data_cleaned
GROUP BY
    CASE
        WHEN ANNUAL_INCOME < 40000 THEN 'Low'
        WHEN ANNUAL_INCOME < 75000 THEN 'Medium'
        ELSE 'High'
    END
ORDER BY applications DESC;


/* ============================================================
   6. TIME / MONTHLY ANALYSIS
   ============================================================ */

-- 6.1 Monthly applications, funded and received
SELECT
    MONTH(ISSUE_DATE) AS month_no,
    MONTHNAME(ISSUE_DATE) AS month_name,
    COUNT(*) AS applications,
    SUM(LOAN_AMOUNT) AS funded_amount,
    SUM(TOTAL_PAYMENT) AS amount_received
FROM loan_data_cleaned
GROUP BY MONTH(ISSUE_DATE), MONTHNAME(ISSUE_DATE)
ORDER BY month_no;


-- 6.2 Latest available month KPIs
WITH latest AS (
    SELECT MAX(ISSUE_DATE) AS max_date
    FROM loan_data_cleaned
)
SELECT
    COUNT(*) AS latest_month_applications,
    SUM(LOAN_AMOUNT) AS latest_month_funded,
    SUM(TOTAL_PAYMENT) AS latest_month_received
FROM loan_data_cleaned
CROSS JOIN latest
WHERE YEAR(ISSUE_DATE) = YEAR(max_date)
  AND MONTH(ISSUE_DATE) = MONTH(max_date);


/* ============================================================
   7. OVERVIEW DASHBOARD ANALYSIS
   ============================================================ */

-- 7.1 Top 5 states by applications
SELECT
    ADDRESS_STATE,
    COUNT(*) AS applications
FROM loan_data_cleaned
GROUP BY ADDRESS_STATE
ORDER BY applications DESC
LIMIT 5;


-- 7.2 Rank states by funded amount
SELECT
    ADDRESS_STATE,
    SUM(LOAN_AMOUNT) AS funded_amount,
    RANK() OVER (ORDER BY SUM(LOAN_AMOUNT) DESC) AS state_rank
FROM loan_data_cleaned
GROUP BY ADDRESS_STATE
ORDER BY state_rank
LIMIT 10;


-- 7.3 Loan term analysis
SELECT
    TRIM(TERM) AS term,
    COUNT(*) AS applications,
    SUM(LOAN_AMOUNT) AS funded_amount
FROM loan_data_cleaned
GROUP BY TRIM(TERM)
ORDER BY applications DESC;


-- 7.4 Home ownership analysis
SELECT
    HOME_OWNERSHIP,
    COUNT(*) AS applications,
    SUM(LOAN_AMOUNT) AS funded_amount
FROM loan_data_cleaned
GROUP BY HOME_OWNERSHIP
ORDER BY applications DESC;


-- 7.5 Home ownership groups with at least 1,000 applications
SELECT
    HOME_OWNERSHIP,
    COUNT(*) AS applications
from loan_data_cleaned
GROUP BY HOME_OWNERSHIP
HAVING COUNT(*) >= 1000
ORDER BY applications DESC;


-- 7.6 Loan purpose breakdown
SELECT
    PURPOSE,
    COUNT(*) AS applications,
    SUM(LOAN_AMOUNT) AS funded_amount,
    SUM(TOTAL_PAYMENT) AS amount_received
FROM loan_data_cleaned
GROUP BY PURPOSE
ORDER BY applications DESC;


-- 7.7 Purpose share of total applications
SELECT
    PURPOSE,
    COUNT(*) AS applications,
    ROUND(
        COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (),
        2
    ) AS pct_of_total
FROM loan_data_cleaned
GROUP BY PURPOSE
ORDER BY applications DESC;


/* ============================================================
   8. SUBQUERIES
   ============================================================ */

-- 8.1 Number of loans above the average loan amount
SELECT COUNT(*) AS above_avg_loans
from loan_data_cleaned
WHERE LOAN_AMOUNT > (
    SELECT AVG(LOAN_AMOUNT)
    FROM loan_data_cleaned
);


-- 8.2 States with applications above the average state count
SELECT
    ADDRESS_STATE,
    COUNT(*) AS applications
FROM loan_data_cleaned
GROUP BY ADDRESS_STATE
HAVING COUNT(*) > (
    SELECT AVG(state_applications)
    FROM (
        SELECT
            ADDRESS_STATE,
            COUNT(*) AS state_applications
        FROM loan_data_cleaned
        GROUP BY ADDRESS_STATE
    ) AS state_counts
)
ORDER BY applications DESC;


/* ============================================================
   9. WINDOW-FUNCTION ANALYSIS
   ============================================================ */

-- 9.1 Month-over-month funded amount change
WITH monthly AS (
    SELECT
        MONTH(ISSUE_DATE) AS month_no,
        SUM(LOAN_AMOUNT) AS funded_amount
    FROM loan_data_cleaned
    GROUP BY MONTH(ISSUE_DATE)
),
lagged AS (
    SELECT
        month_no,
        funded_amount,
        LAG(funded_amount) OVER (ORDER BY month_no) AS previous_month_funded
    FROM monthly
)
SELECT
    month_no,
    funded_amount,
    previous_month_funded,
    ROUND(
        (funded_amount - previous_month_funded)
        * 100.0 / NULLIF(previous_month_funded, 0),
        2
    ) AS mom_pct
FROM lagged
ORDER BY month_no;


-- 9.2 Running total of applications by month
WITH monthly AS (
    SELECT
        MONTH(ISSUE_DATE) AS month_no,
        COUNT(*) AS applications
    FROM loan_data_cleaned
    GROUP BY MONTH(ISSUE_DATE)
)
SELECT
    month_no,
    applications,
    SUM(applications) OVER (
        ORDER BY month_no
    ) AS running_total_applications
FROM monthly
ORDER BY month_no;


-- 9.3 Top purpose within each grade
WITH ranked AS (
    SELECT
        GRADE,
        PURPOSE,
        COUNT(*) AS applications,
        ROW_NUMBER() OVER (
            PARTITION BY GRADE
            ORDER BY COUNT(*) DESC
        ) AS rn
    FROM loan_data_cleaned
    GROUP BY GRADE, PURPOSE
)
SELECT
    GRADE,
    PURPOSE,
    applications
FROM ranked
WHERE rn = 1
ORDER BY GRADE;


-- 9.4 Three-month moving average of funded amount
WITH monthly AS (
    SELECT
        MONTH(ISSUE_DATE) AS month_no,
        SUM(LOAN_AMOUNT) AS funded_amount
    FROM loan_data_cleaned
    GROUP BY MONTH(ISSUE_DATE)
)
SELECT
    month_no,
    funded_amount,
    ROUND(
        AVG(funded_amount) OVER (
            ORDER BY month_no
            ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
        ),
        0
    ) AS moving_avg_3m
FROM monthly
ORDER BY month_no;


/* ============================================================
   10. POWER BI SOURCE VIEW
   ============================================================ */

CREATE OR REPLACE VIEW vw_loan_powerbi AS
SELECT
    `ID`,
    `MEMBER_ID`,
    `ISSUE_DATE`,
    `PURPOSE`,
    `VERIFICATION_STATUS`,
    `GRADE`,
    `SUB_GRADE`,
    `HOME_OWNERSHIP`,
    `ADDRESS_STATE`,
    `LOAN_STATUS`,
    `EMP_LENGTH`,
    `EMP_TITLE`,
    `LAST_CREDIT_PULL_DATE`,
    `LAST_PAYMENT_DATE`,
    `NEXT_PAYMENT_DATE`,
    TRIM(`TERM`) AS `TERM`,
    `ANNUAL_INCOME`,
    `DTI`,
    `INSTALLMENT`,
    `INT_RATE`,
    `LOAN_AMOUNT`,
    `TOTAL_ACC`,
    `TOTAL_PAYMENT`,
    CASE
        WHEN `LOAN_STATUS` IN ('Fully Paid', 'Current')
            THEN 'Good Loan'
        WHEN `LOAN_STATUS` = 'Charged Off'
            THEN 'Bad Loan'
        ELSE 'Other'
    END AS `LOAN_CATEGORY`
FROM `loan_data_cleaned`;

/* ============================================================
   11. FINAL RECONCILIATION
   ============================================================ */

SELECT
    COUNT(*) AS applications,
    SUM(LOAN_AMOUNT) AS funded_amount,
    SUM(TOTAL_PAYMENT) AS amount_received,
    ROUND(AVG(INT_RATE) * 100, 2) AS avg_interest_rate_pct,
    ROUND(AVG(DTI) * 100, 2) AS avg_dti_pct,
    SUM(
        CASE
            WHEN LOAN_STATUS IN ('Fully Paid', 'Current')
            THEN 1 ELSE 0
        END
    ) AS good_loan_applications,
    SUM(
        CASE
            WHEN LOAN_STATUS = 'Charged Off'
            THEN 1 ELSE 0
        END
    ) AS bad_loan_applications
FROM loan_data_cleaned;
