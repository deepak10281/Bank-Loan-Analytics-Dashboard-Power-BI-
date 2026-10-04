/* ============================================================
   BANK LOAN PORTFOLIO & CREDIT RISK ANALYSIS
   Database : loan_db
   Table    : financial_loan
   Tool     : DBeaver / MySQL

   BUSINESS OBJECTIVES:
   1. Analyze loan portfolio performance
   2. Track Good vs Bad Loans
   3. Analyze repayment behavior
   4. Monitor funded and received amounts
   5. Analyze interest rate and DTI
   6. Analyze monthly loan trends
   7. Analyze regional performance
   8. Analyze loan purpose, term and home ownership
   9. Analyze credit risk using Grade/Sub-Grade
   10. Perform advanced SQL analysis
   ============================================================ */

USE loan_db;


/* ============================================================
   SECTION 1 - DATA VALIDATION
   ============================================================ */

-- Q1. Total number of records
SELECT
    COUNT(*) AS total_records
FROM financial_loan;


-- Q2. Check duplicate loan IDs
SELECT
    id,
    COUNT(*) AS duplicate_count
FROM financial_loan
GROUP BY id
HAVING COUNT(*) > 1;


-- Q3. Check loan statuses
SELECT
    loan_status,
    COUNT(*) AS loan_count
FROM financial_loan
GROUP BY loan_status
ORDER BY loan_count DESC;


-- Q4. Check loan grades
SELECT
    grade,
    COUNT(*) AS loan_count
FROM financial_loan
GROUP BY grade
ORDER BY grade;


-- Q5. Check loan purposes
SELECT
    purpose,
    COUNT(*) AS loan_count
FROM financial_loan
GROUP BY purpose
ORDER BY loan_count DESC;


/* ============================================================
   SECTION 2 - MAIN KPIs
   ============================================================ */

-- Q6. Total Loan Applications
SELECT
    COUNT(*) AS total_loan_applications
FROM financial_loan;


-- Q7. Total Funded Amount
SELECT
    SUM(loan_amount) AS total_funded_amount
FROM financial_loan;


-- Q8. Total Amount Received
SELECT
    SUM(total_payment) AS total_amount_received
FROM financial_loan;


-- Q9. Average Interest Rate
SELECT
    ROUND(AVG(int_rate) * 100, 2) AS average_interest_rate
FROM financial_loan;


-- Q10. Average DTI
SELECT
    ROUND(AVG(dti) * 100, 2) AS average_dti
FROM financial_loan;


/* ============================================================
   SECTION 3 - GOOD LOAN VS BAD LOAN
   Good Loan = Fully Paid + Current
   Bad Loan  = Charged Off
   ============================================================ */

-- Q11. Good vs Bad Loan Applications
SELECT
    CASE
        WHEN loan_status IN ('Fully Paid', 'Current')
            THEN 'Good Loan'
        WHEN loan_status = 'Charged Off'
            THEN 'Bad Loan'
        ELSE 'Other'
    END AS loan_category,
    COUNT(*) AS loan_applications
FROM financial_loan
GROUP BY
    CASE
        WHEN loan_status IN ('Fully Paid', 'Current')
            THEN 'Good Loan'
        WHEN loan_status = 'Charged Off'
            THEN 'Bad Loan'
        ELSE 'Other'
    END
ORDER BY loan_applications DESC;


-- Q12. Good Loan Percentage
SELECT
    ROUND(
        SUM(
            CASE
                WHEN loan_status IN ('Fully Paid', 'Current')
                THEN 1
                ELSE 0
            END
        ) * 100.0 / COUNT(*),
        2
    ) AS good_loan_percentage
FROM financial_loan;


-- Q13. Bad Loan Percentage
SELECT
    ROUND(
        SUM(
            CASE
                WHEN loan_status = 'Charged Off'
                THEN 1
                ELSE 0
            END
        ) * 100.0 / COUNT(*),
        2
    ) AS bad_loan_percentage
FROM financial_loan;


-- Q14. Good vs Bad Funded Amount
SELECT
    CASE
        WHEN loan_status IN ('Fully Paid', 'Current')
            THEN 'Good Loan'
        WHEN loan_status = 'Charged Off'
            THEN 'Bad Loan'
        ELSE 'Other'
    END AS loan_category,
    SUM(loan_amount) AS funded_amount
FROM financial_loan
GROUP BY
    CASE
        WHEN loan_status IN ('Fully Paid', 'Current')
            THEN 'Good Loan'
        WHEN loan_status = 'Charged Off'
            THEN 'Bad Loan'
        ELSE 'Other'
    END;


-- Q15. Good vs Bad Amount Received
SELECT
    CASE
        WHEN loan_status IN ('Fully Paid', 'Current')
            THEN 'Good Loan'
        WHEN loan_status = 'Charged Off'
            THEN 'Bad Loan'
        ELSE 'Other'
    END AS loan_category,
    SUM(total_payment) AS amount_received
FROM financial_loan
GROUP BY
    CASE
        WHEN loan_status IN ('Fully Paid', 'Current')
            THEN 'Good Loan'
        WHEN loan_status = 'Charged Off'
            THEN 'Bad Loan'
        ELSE 'Other'
    END;


/* ============================================================
   SECTION 4 - LOAN STATUS ANALYSIS
   ============================================================ */

-- Q16. Applications by Loan Status
SELECT
    loan_status,
    COUNT(*) AS applications
FROM financial_loan
GROUP BY loan_status
ORDER BY applications DESC;


-- Q17. Funded Amount by Loan Status
SELECT
    loan_status,
    SUM(loan_amount) AS funded_amount
FROM financial_loan
GROUP BY loan_status
ORDER BY funded_amount DESC;


-- Q18. Amount Received by Loan Status
SELECT
    loan_status,
    SUM(total_payment) AS amount_received
FROM financial_loan
GROUP BY loan_status
ORDER BY amount_received DESC;


-- Q19. Average Interest Rate by Loan Status
SELECT
    loan_status,
    ROUND(AVG(int_rate) * 100, 2) AS average_interest_rate
FROM financial_loan
GROUP BY loan_status
ORDER BY average_interest_rate DESC;


-- Q20. Average DTI by Loan Status
SELECT
    loan_status,
    ROUND(AVG(dti) * 100, 2) AS average_dti
FROM financial_loan
GROUP BY loan_status
ORDER BY average_dti DESC;


/* ============================================================
   SECTION 5 - MONTHLY LOAN ANALYSIS
   ============================================================ */

-- Q21. Monthly Loan Applications
SELECT
    DATE_FORMAT(
        STR_TO_DATE(issue_date, '%m/%d/%Y'),
        '%Y-%m'
    ) AS year_month,
    COUNT(*) AS loan_applications
FROM financial_loan
GROUP BY
    DATE_FORMAT(
        STR_TO_DATE(issue_date, '%m/%d/%Y'),
        '%Y-%m'
    )
ORDER BY year_month;


-- Q22. Monthly Funded Amount
SELECT
    DATE_FORMAT(
        STR_TO_DATE(issue_date, '%m/%d/%Y'),
        '%Y-%m'
    ) AS year_month,
    SUM(loan_amount) AS funded_amount
FROM financial_loan
GROUP BY
    DATE_FORMAT(
        STR_TO_DATE(issue_date, '%m/%d/%Y'),
        '%Y-%m'
    )
ORDER BY year_month;


-- Q23. Monthly Amount Received
SELECT
    DATE_FORMAT(
        STR_TO_DATE(issue_date, '%m/%d/%Y'),
        '%Y-%m'
    ) AS year_month,
    SUM(total_payment) AS amount_received
FROM financial_loan
GROUP BY
    DATE_FORMAT(
        STR_TO_DATE(issue_date, '%m/%d/%Y'),
        '%Y-%m'
    )
ORDER BY year_month;


/* ============================================================
   SECTION 6 - REGIONAL ANALYSIS
   ============================================================ */

-- Q24. Loan Applications by State
SELECT
    address_state,
    COUNT(*) AS loan_applications
FROM financial_loan
GROUP BY address_state
ORDER BY loan_applications DESC;


-- Q25. Funded Amount by State
SELECT
    address_state,
    SUM(loan_amount) AS funded_amount
FROM financial_loan
GROUP BY address_state
ORDER BY funded_amount DESC;


-- Q26. Bad Loans by State
SELECT
    address_state,
    COUNT(*) AS bad_loans
FROM financial_loan
WHERE loan_status = 'Charged Off'
GROUP BY address_state
ORDER BY bad_loans DESC;


-- Q27. Bad Loan Rate by State
SELECT
    address_state,
    COUNT(*) AS total_loans,
    SUM(
        CASE
            WHEN loan_status = 'Charged Off'
            THEN 1
            ELSE 0
        END
    ) AS bad_loans,
    ROUND(
        SUM(
            CASE
                WHEN loan_status = 'Charged Off'
                THEN 1
                ELSE 0
            END
        ) * 100.0 / COUNT(*),
        2
    ) AS bad_loan_rate
FROM financial_loan
GROUP BY address_state
ORDER BY bad_loan_rate DESC;


/* ============================================================
   SECTION 7 - LOAN TERM ANALYSIS
   ============================================================ */

-- Q28. Applications by Loan Term
SELECT
    term,
    COUNT(*) AS loan_applications
FROM financial_loan
GROUP BY term
ORDER BY loan_applications DESC;


-- Q29. Funded Amount by Loan Term
SELECT
    term,
    SUM(loan_amount) AS funded_amount
FROM financial_loan
GROUP BY term
ORDER BY funded_amount DESC;


-- Q30. Average Interest Rate by Loan Term
SELECT
    term,
    ROUND(AVG(int_rate) * 100, 2) AS average_interest_rate
FROM financial_loan
GROUP BY term
ORDER BY average_interest_rate DESC;


/* ============================================================
   SECTION 8 - HOME OWNERSHIP ANALYSIS
   ============================================================ */

-- Q31. Applications by Home Ownership
SELECT
    home_ownership,
    COUNT(*) AS loan_applications
FROM financial_loan
GROUP BY home_ownership
ORDER BY loan_applications DESC;


-- Q32. Funded Amount by Home Ownership
SELECT
    home_ownership,
    SUM(loan_amount) AS funded_amount
FROM financial_loan
GROUP BY home_ownership
ORDER BY funded_amount DESC;


-- Q33. Bad Loan Rate by Home Ownership
SELECT
    home_ownership,
    COUNT(*) AS total_loans,
    SUM(
        CASE
            WHEN loan_status = 'Charged Off'
            THEN 1
            ELSE 0
        END
    ) AS bad_loans,
    ROUND(
        SUM(
            CASE
                WHEN loan_status = 'Charged Off'
                THEN 1
                ELSE 0
            END
        ) * 100.0 / COUNT(*),
        2
    ) AS bad_loan_rate
FROM financial_loan
GROUP BY home_ownership
ORDER BY bad_loan_rate DESC;


/* ============================================================
   SECTION 9 - LOAN PURPOSE ANALYSIS
   ============================================================ */

-- Q34. Applications by Loan Purpose
SELECT
    purpose,
    COUNT(*) AS loan_applications
FROM financial_loan
GROUP BY purpose
ORDER BY loan_applications DESC;


-- Q35. Funded Amount by Loan Purpose
SELECT
    purpose,
    SUM(loan_amount) AS funded_amount
FROM financial_loan
GROUP BY purpose
ORDER BY funded_amount DESC;


-- Q36. Average Loan Amount by Purpose
SELECT
    purpose,
    ROUND(AVG(loan_amount), 2) AS average_loan_amount
FROM financial_loan
GROUP BY purpose
ORDER BY average_loan_amount DESC;


-- Q37. Bad Loan Rate by Purpose
SELECT
    purpose,
    COUNT(*) AS total_loans,
    SUM(
        CASE
            WHEN loan_status = 'Charged Off'
            THEN 1
            ELSE 0
        END
    ) AS bad_loans,
    ROUND(
        SUM(
            CASE
                WHEN loan_status = 'Charged Off'
                THEN 1
                ELSE 0
            END
        ) * 100.0 / COUNT(*),
        2
    ) AS bad_loan_rate
FROM financial_loan
GROUP BY purpose
ORDER BY bad_loan_rate DESC;


/* ============================================================
   SECTION 10 - CREDIT RISK / GRADE ANALYSIS
   ============================================================ */

-- Q38. Applications by Grade
SELECT
    grade,
    COUNT(*) AS loan_applications
FROM financial_loan
GROUP BY grade
ORDER BY grade;


-- Q39. Funded Amount by Grade
SELECT
    grade,
    SUM(loan_amount) AS funded_amount
FROM financial_loan
GROUP BY grade
ORDER BY funded_amount DESC;


-- Q40. Average Interest Rate by Grade
SELECT
    grade,
    ROUND(AVG(int_rate) * 100, 2) AS average_interest_rate
FROM financial_loan
GROUP BY grade
ORDER BY grade;


-- Q41. Bad Loan Rate by Grade
SELECT
    grade,
    COUNT(*) AS total_loans,
    SUM(
        CASE
            WHEN loan_status = 'Charged Off'
            THEN 1
            ELSE 0
        END
    ) AS bad_loans,
    ROUND(
        SUM(
            CASE
                WHEN loan_status = 'Charged Off'
                THEN 1
                ELSE 0
            END
        ) * 100.0 / COUNT(*),
        2
    ) AS bad_loan_rate
FROM financial_loan
GROUP BY grade
ORDER BY bad_loan_rate DESC;


-- Q42. Sub-Grade Analysis
SELECT
    sub_grade,
    COUNT(*) AS loan_applications,
    SUM(loan_amount) AS funded_amount,
    ROUND(AVG(int_rate) * 100, 2) AS average_interest_rate
FROM financial_loan
GROUP BY sub_grade
ORDER BY funded_amount DESC;


/* ============================================================
   SECTION 11 - DTI RISK ANALYSIS
   ============================================================ */

-- Q43. DTI Risk Groups
SELECT
    CASE
        WHEN dti < 0.10 THEN 'Low DTI'
        WHEN dti < 0.20 THEN 'Medium DTI'
        ELSE 'High DTI'
    END AS dti_group,
    COUNT(*) AS loan_applications,
    ROUND(AVG(dti) * 100, 2) AS average_dti
FROM financial_loan
GROUP BY
    CASE
        WHEN dti < 0.10 THEN 'Low DTI'
        WHEN dti < 0.20 THEN 'Medium DTI'
        ELSE 'High DTI'
    END
ORDER BY average_dti;


-- Q44. Bad Loan Rate by DTI Group
SELECT
    CASE
        WHEN dti < 0.10 THEN 'Low DTI'
        WHEN dti < 0.20 THEN 'Medium DTI'
        ELSE 'High DTI'
    END AS dti_group,
    COUNT(*) AS total_loans,
    SUM(
        CASE
            WHEN loan_status = 'Charged Off'
            THEN 1
            ELSE 0
        END
    ) AS bad_loans,
    ROUND(
        SUM(
            CASE
                WHEN loan_status = 'Charged Off'
                THEN 1
                ELSE 0
            END
        ) * 100.0 / COUNT(*),
        2
    ) AS bad_loan_rate
FROM financial_loan
GROUP BY
    CASE
        WHEN dti < 0.10 THEN 'Low DTI'
        WHEN dti < 0.20 THEN 'Medium DTI'
        ELSE 'High DTI'
    END
ORDER BY bad_loan_rate DESC;


/* ============================================================
   SECTION 12 - REPAYMENT ANALYSIS
   ============================================================ */

-- Q45. Overall Repayment Percentage
SELECT
    SUM(loan_amount) AS total_loan_amount,
    SUM(total_payment) AS total_payment_received,
    ROUND(
        SUM(total_payment) * 100.0 /
        NULLIF(SUM(loan_amount), 0),
        2
    ) AS repayment_percentage
FROM financial_loan;


-- Q46. Repayment Percentage by Loan Status
SELECT
    loan_status,
    SUM(loan_amount) AS total_loan_amount,
    SUM(total_payment) AS total_payment_received,
    ROUND(
        SUM(total_payment) * 100.0 /
        NULLIF(SUM(loan_amount), 0),
        2
    ) AS repayment_percentage
FROM financial_loan
GROUP BY loan_status
ORDER BY repayment_percentage DESC;


/* ============================================================
   SECTION 13 - INCOME ANALYSIS
   ============================================================ */

-- Q47. Average Income by Loan Status
SELECT
    loan_status,
    ROUND(AVG(annual_income), 2) AS average_annual_income
FROM financial_loan
GROUP BY loan_status
ORDER BY average_annual_income DESC;


-- Q48. Average Loan Amount by Income Group
SELECT
    CASE
        WHEN annual_income < 30000 THEN 'Below 30K'
        WHEN annual_income < 60000 THEN '30K - 60K'
        WHEN annual_income < 100000 THEN '60K - 100K'
        ELSE 'Above 100K'
    END AS income_group,
    COUNT(*) AS loan_applications,
    ROUND(AVG(loan_amount), 2) AS average_loan_amount
FROM financial_loan
GROUP BY
    CASE
        WHEN annual_income < 30000 THEN 'Below 30K'
        WHEN annual_income < 60000 THEN '30K - 60K'
        WHEN annual_income < 100000 THEN '60K - 100K'
        ELSE 'Above 100K'
    END
ORDER BY average_loan_amount DESC;


/* ============================================================
   SECTION 14 - VERIFICATION ANALYSIS
   ============================================================ */

-- Q49. Applications by Verification Status
SELECT
    verification_status,
    COUNT(*) AS loan_applications
FROM financial_loan
GROUP BY verification_status
ORDER BY loan_applications DESC;


-- Q50. Bad Loan Rate by Verification Status
SELECT
    verification_status,
    COUNT(*) AS total_loans,
    SUM(
        CASE
            WHEN loan_status = 'Charged Off'
            THEN 1
            ELSE 0
        END
    ) AS bad_loans,
    ROUND(
        SUM(
            CASE
                WHEN loan_status = 'Charged Off'
                THEN 1
                ELSE 0
            END
        ) * 100.0 / COUNT(*),
        2
    ) AS bad_loan_rate
FROM financial_loan
GROUP BY verification_status
ORDER BY bad_loan_rate DESC;


/* ============================================================
   SECTION 15 - TOP 10 ANALYSIS
   ============================================================ */

-- Q51. Top 10 States by Funded Amount
SELECT
    address_state,
    SUM(loan_amount) AS funded_amount
FROM financial_loan
GROUP BY address_state
ORDER BY funded_amount DESC
LIMIT 10;


-- Q52. Top 10 Loan Purposes by Funded Amount
SELECT
    purpose,
    SUM(loan_amount) AS funded_amount
FROM financial_loan
GROUP BY purpose
ORDER BY funded_amount DESC
LIMIT 10;


-- Q53. Top 10 Customers by Borrowed Amount
SELECT
    member_id,
    COUNT(*) AS loan_count,
    SUM(loan_amount) AS total_borrowed
FROM financial_loan
GROUP BY member_id
ORDER BY total_borrowed DESC
LIMIT 10;


/* ============================================================
   SECTION 16 - MULTIPLE LOAN CUSTOMERS
   ============================================================ */

-- Q54. Customers with Multiple Loans
SELECT
    member_id,
    COUNT(*) AS number_of_loans,
    SUM(loan_amount) AS total_borrowed
FROM financial_loan
GROUP BY member_id
HAVING COUNT(*) > 1
ORDER BY number_of_loans DESC;


/* ============================================================
   SECTION 17 - HIGH RISK LOANS
   ============================================================ */

-- Q55. High Risk Loans
-- Grades E, F and G are treated as high risk
SELECT
    COUNT(*) AS high_risk_loans,
    SUM(loan_amount) AS high_risk_funded_amount,
    ROUND(AVG(int_rate) * 100, 2) AS average_high_risk_interest_rate
FROM financial_loan
WHERE grade IN ('E', 'F', 'G');


-- Q56. High Risk Loan Percentage
SELECT
    ROUND(
        SUM(
            CASE
                WHEN grade IN ('E', 'F', 'G')
                THEN 1
                ELSE 0
            END
        ) * 100.0 / COUNT(*),
        2
    ) AS high_risk_loan_percentage
FROM financial_loan;


/* ============================================================
   SECTION 18 - RANKING USING WINDOW FUNCTIONS
   ============================================================ */

-- Q57. Rank States by Funded Amount
SELECT
    address_state,
    SUM(loan_amount) AS funded_amount,
    RANK() OVER (
        ORDER BY SUM(loan_amount) DESC
    ) AS state_rank
FROM financial_loan
GROUP BY address_state
ORDER BY state_rank;


-- Q58. Rank Grades by Funded Amount
SELECT
    grade,
    SUM(loan_amount) AS funded_amount,
    RANK() OVER (
        ORDER BY SUM(loan_amount) DESC
    ) AS grade_rank
FROM financial_loan
GROUP BY grade
ORDER BY grade_rank;


/* ============================================================
   SECTION 19 - MONTHLY RUNNING TOTAL
   ============================================================ */

-- Q59. Running Funded Amount
WITH monthly_loans AS
(
    SELECT
        DATE_FORMAT(
            STR_TO_DATE(issue_date, '%m/%d/%Y'),
            '%Y-%m'
        ) AS year_month,
        SUM(loan_amount) AS monthly_funded_amount
    FROM financial_loan
    GROUP BY
        DATE_FORMAT(
            STR_TO_DATE(issue_date, '%m/%d/%Y'),
            '%Y-%m'
        )
)
SELECT
    year_month,
    monthly_funded_amount,
    SUM(monthly_funded_amount) OVER (
        ORDER BY year_month
    ) AS running_funded_amount
FROM monthly_loans
ORDER BY year_month;


/* ============================================================
   SECTION 20 - MONTH OVER MONTH GROWTH
   ============================================================ */

-- Q60. Month-over-Month Loan Application Growth
WITH monthly_loans AS
(
    SELECT
        DATE_FORMAT(
            STR_TO_DATE(issue_date, '%m/%d/%Y'),
            '%Y-%m'
        ) AS year_month,
        COUNT(*) AS loan_applications
    FROM financial_loan
    GROUP BY
        DATE_FORMAT(
            STR_TO_DATE(issue_date, '%m/%d/%Y'),
            '%Y-%m'
        )
),
monthly_growth AS
(
    SELECT
        year_month,
        loan_applications,
        LAG(loan_applications) OVER (
            ORDER BY year_month
        ) AS previous_month_applications
    FROM monthly_loans
)
SELECT
    year_month,
    loan_applications,
    previous_month_applications,
    ROUND(
        (loan_applications - previous_month_applications)
        * 100.0 /
        NULLIF(previous_month_applications, 0),
        2
    ) AS mom_growth_percentage
FROM monthly_growth
ORDER BY year_month;


/* ============================================================
   SECTION 21 - ADVANCED STATE + GRADE ANALYSIS
   ============================================================ */

-- Q61. Highest Funded Grade in Each State
WITH state_grade AS
(
    SELECT
        address_state,
        grade,
        SUM(loan_amount) AS funded_amount
    FROM financial_loan
    GROUP BY address_state, grade
),
ranked_state_grade AS
(
    SELECT
        address_state,
        grade,
        funded_amount,
        RANK() OVER (
            PARTITION BY address_state
            ORDER BY funded_amount DESC
        ) AS ranking
    FROM state_grade
)
SELECT
    address_state,
    grade,
    funded_amount
FROM ranked_state_grade
WHERE ranking = 1
ORDER BY address_state;


/* ============================================================
   SECTION 22 - TOP 3 LOAN PURPOSES
   ============================================================ */

-- Q62. Top 3 Purposes by Funded Amount
WITH purpose_summary AS
(
    SELECT
        purpose,
        SUM(loan_amount) AS funded_amount
    FROM financial_loan
    GROUP BY purpose
),
ranked_purposes AS
(
    SELECT
        purpose,
        funded_amount,
        DENSE_RANK() OVER (
            ORDER BY funded_amount DESC
        ) AS purpose_rank
    FROM purpose_summary
)
SELECT
    purpose,
    funded_amount,
    purpose_rank
FROM ranked_purposes
WHERE purpose_rank <= 3
ORDER BY purpose_rank;


/* ============================================================
   SECTION 23 - MASTER KPI QUERY
   ============================================================ */

-- Q63. Complete Executive KPI Summary
SELECT

    COUNT(*) AS total_loan_applications,

    SUM(loan_amount) AS total_funded_amount,

    SUM(total_payment) AS total_amount_received,

    ROUND(AVG(int_rate) * 100, 2) AS average_interest_rate,

    ROUND(AVG(dti) * 100, 2) AS average_dti,

    SUM(
        CASE
            WHEN loan_status IN ('Fully Paid', 'Current')
            THEN 1
            ELSE 0
        END
    ) AS good_loan_applications,

    SUM(
        CASE
            WHEN loan_status = 'Charged Off'
            THEN 1
            ELSE 0
        END
    ) AS bad_loan_applications,

    ROUND(
        SUM(
            CASE
                WHEN loan_status IN ('Fully Paid', 'Current')
                THEN 1
                ELSE 0
            END
        ) * 100.0 / COUNT(*),
        2
    ) AS good_loan_percentage,

    ROUND(
        SUM(
            CASE
                WHEN loan_status = 'Charged Off'
                THEN 1
                ELSE 0
            END
        ) * 100.0 / COUNT(*),
        2
    ) AS bad_loan_percentage,

    ROUND(
        SUM(total_payment) * 100.0 /
        NULLIF(SUM(loan_amount), 0),
        2
    ) AS repayment_percentage

FROM financial_loan;


/* ============================================================
   END OF BANK LOAN ANALYSIS PROJECT
   ============================================================ */