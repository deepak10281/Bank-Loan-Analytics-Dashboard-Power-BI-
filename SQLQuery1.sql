/* =====================================================================
   BANK LOAN REPORT - QUERY DOCUMENT
   Source: Data Tutorials (https://www.youtube.com/@datatutorials1)
   Table : bank_loan_data
   Note  : MTD = month 12 (December), PMTD = month 11 (November)
   ===================================================================== */

USE bank_loan_db;

-- ============================================================
-- STEP 1: Check the raw data after import
-- Dates should still look like 11-02-2021 (DD-MM-YYYY text)
-- ============================================================
SELECT id, issue_date, dti, int_rate, installment, loan_amount, total_payment
FROM bank_loan_data
LIMIT 3;

-- ============================================================
-- STEP 2: Turn off safe-update mode for this session
-- (otherwise DBeaver/MySQL blocks UPDATE without a WHERE clause)
-- ============================================================
SET SQL_SAFE_UPDATES = 0;

-- ============================================================
-- STEP 3: Convert DD-MM-YYYY text to real MySQL dates (YYYY-MM-DD)
-- WARNING: run this ONCE only. Running it again turns the
-- already-converted dates into NULL.
-- ============================================================
UPDATE bank_loan_data
SET issue_date            = STR_TO_DATE(issue_date, '%d-%m-%Y'),
    last_credit_pull_date = STR_TO_DATE(last_credit_pull_date, '%d-%m-%Y'),
    last_payment_date     = STR_TO_DATE(last_payment_date, '%d-%m-%Y'),
    next_payment_date     = STR_TO_DATE(next_payment_date, '%d-%m-%Y');

-- ============================================================
-- STEP 4: Change the column type from VARCHAR to DATE
-- (so MONTH(), YEAR() etc. work properly and without warnings)
-- ============================================================
ALTER TABLE bank_loan_data
    MODIFY issue_date            DATE,
    MODIFY last_credit_pull_date DATE,
    MODIFY last_payment_date     DATE,
    MODIFY next_payment_date     DATE;

-- ============================================================
-- STEP 5: Verify the conversion
-- Expected first row: 2021-02-11 | month 2 | 0.01 | 0.1527
-- ============================================================
SELECT issue_date, MONTH(issue_date), dti, int_rate
FROM bank_loan_data
LIMIT 3;

/* =====================================================================
   PART 1: BANK LOAN REPORT | SUMMARY
   ===================================================================== */

/* ---------------------------- KPIs ---------------------------------- */

-- Q1. Total Loan Applications
SELECT COUNT(id) AS Total_Applications FROM bank_loan_data;

-- Q2. MTD Loan Applications
SELECT COUNT(id) AS Total_Applications FROM bank_loan_data
WHERE MONTH(issue_date) = 12;

-- Q3. PMTD Loan Applications
SELECT COUNT(id) AS Total_Applications FROM bank_loan_data
WHERE MONTH(issue_date) = 11;

-- Q4. Total Funded Amount
SELECT SUM(loan_amount) AS Total_Funded_Amount FROM bank_loan_data;

-- Q5. MTD Total Funded Amount
SELECT SUM(loan_amount) AS Total_Funded_Amount FROM bank_loan_data
WHERE MONTH(issue_date) = 12;

-- Q6. PMTD Total Funded Amount
SELECT SUM(loan_amount) AS Total_Funded_Amount FROM bank_loan_data
WHERE MONTH(issue_date) = 11;

-- Q7. Total Amount Received
SELECT SUM(total_payment) AS Total_Amount_Collected FROM bank_loan_data;

-- Q8. MTD Total Amount Received
SELECT SUM(total_payment) AS Total_Amount_Collected FROM bank_loan_data
WHERE MONTH(issue_date) = 12;

-- Q9. PMTD Total Amount Received
SELECT SUM(total_payment) AS Total_Amount_Collected FROM bank_loan_data
WHERE MONTH(issue_date) = 11;

-- Q10. Average Interest Rate
SELECT AVG(int_rate)*100 AS Avg_Int_Rate FROM bank_loan_data;

-- Q11. MTD Average Interest Rate
SELECT AVG(int_rate)*100 AS MTD_Avg_Int_Rate FROM bank_loan_data
WHERE MONTH(issue_date) = 12;

-- Q12. PMTD Average Interest Rate
SELECT AVG(int_rate)*100 AS PMTD_Avg_Int_Rate FROM bank_loan_data
WHERE MONTH(issue_date) = 11;

-- Q13. Average DTI
SELECT AVG(dti)*100 AS Avg_DTI FROM bank_loan_data;

-- Q14. MTD Average DTI
SELECT AVG(dti)*100 AS MTD_Avg_DTI FROM bank_loan_data
WHERE MONTH(issue_date) = 12;

-- Q15. PMTD Average DTI
SELECT AVG(dti)*100 AS PMTD_Avg_DTI FROM bank_loan_data
WHERE MONTH(issue_date) = 11;


/* ------------------------ GOOD LOAN ISSUED --------------------------- */

-- Q16. Good Loan Percentage
SELECT
    (COUNT(CASE WHEN loan_status = 'Fully Paid' OR loan_status = 'Current' THEN id END) * 100.0) /
    COUNT(id) AS Good_Loan_Percentage
FROM bank_loan_data;

-- Q17. Good Loan Applications
SELECT COUNT(id) AS Good_Loan_Applications FROM bank_loan_data
WHERE loan_status = 'Fully Paid' OR loan_status = 'Current';

-- Q18. Good Loan Funded Amount
SELECT SUM(loan_amount) AS Good_Loan_Funded_amount FROM bank_loan_data
WHERE loan_status = 'Fully Paid' OR loan_status = 'Current';

-- Q19. Good Loan Amount Received
SELECT SUM(total_payment) AS Good_Loan_amount_received FROM bank_loan_data
WHERE loan_status = 'Fully Paid' OR loan_status = 'Current';


/* ------------------------- BAD LOAN ISSUED --------------------------- */

-- Q20. Bad Loan Percentage
SELECT
    (COUNT(CASE WHEN loan_status = 'Charged Off' THEN id END) * 100.0) /
    COUNT(id) AS Bad_Loan_Percentage
FROM bank_loan_data;

-- Q21. Bad Loan Applications
SELECT COUNT(id) AS Bad_Loan_Applications FROM bank_loan_data
WHERE loan_status = 'Charged Off';

-- Q22. Bad Loan Funded Amount
SELECT SUM(loan_amount) AS Bad_Loan_Funded_amount FROM bank_loan_data
WHERE loan_status = 'Charged Off';

-- Q23. Bad Loan Amount Received
SELECT SUM(total_payment) AS Bad_Loan_amount_received FROM bank_loan_data
WHERE loan_status = 'Charged Off';


/* ----------------------------- LOAN STATUS --------------------------- */

-- Q24. Loan Status summary (count, amount received, funded amount, avg interest rate, avg DTI)
SELECT
    loan_status,
    COUNT(id) AS LoanCount,
    SUM(total_payment) AS Total_Amount_Received,
    SUM(loan_amount) AS Total_Funded_Amount,
    AVG(int_rate * 100) AS Interest_Rate,
    AVG(dti * 100) AS DTI
FROM
    bank_loan_data
GROUP BY
    loan_status;

-- Q25. Loan Status MTD (December) - amount received and funded amount
SELECT
    loan_status,
    SUM(total_payment) AS MTD_Total_Amount_Received,
    SUM(loan_amount) AS MTD_Total_Funded_Amount
FROM bank_loan_data
WHERE MONTH(issue_date) = 12
GROUP BY loan_status;


/* =====================================================================
   PART 2: BANK LOAN REPORT | OVERVIEW
   ===================================================================== */

SELECT
    MONTH(issue_date) AS Month_Number,
    MONTHNAME(issue_date) AS Month_name,
    COUNT(id) AS Total_Loan_Applications,
    SUM(loan_amount) AS Total_Funded_Amount,
    SUM(total_payment) AS Total_Amount_Received
FROM bank_loan_data
GROUP BY MONTH(issue_date), MONTHNAME(issue_date)
ORDER BY MONTH(issue_date);

-- Q27. STATE: Applications, funded amount and amount received by state
SELECT
    address_state AS State,
    COUNT(id) AS Total_Loan_Applications,
    SUM(loan_amount) AS Total_Funded_Amount,
    SUM(total_payment) AS Total_Amount_Received
FROM bank_loan_data
GROUP BY address_state
ORDER BY address_state;

-- Q28. TERM: Applications, funded amount and amount received by loan term
SELECT
    term AS Term,
    COUNT(id) AS Total_Loan_Applications,
    SUM(loan_amount) AS Total_Funded_Amount,
    SUM(total_payment) AS Total_Amount_Received
FROM bank_loan_data
GROUP BY term
ORDER BY term;

-- Q29. EMPLOYEE LENGTH: Applications, funded amount and amount received by employment length
SELECT
    emp_length AS Employee_Length,
    COUNT(id) AS Total_Loan_Applications,
    SUM(loan_amount) AS Total_Funded_Amount,
    SUM(total_payment) AS Total_Amount_Received
FROM bank_loan_data
GROUP BY emp_length
ORDER BY emp_length;

-- Q30. PURPOSE: Applications, funded amount and amount received by loan purpose
SELECT
    purpose AS PURPOSE,
    COUNT(id) AS Total_Loan_Applications,
    SUM(loan_amount) AS Total_Funded_Amount,
    SUM(total_payment) AS Total_Amount_Received
FROM bank_loan_data
GROUP BY purpose
ORDER BY purpose;

-- Q31. HOME OWNERSHIP: Applications, funded amount and amount received by home ownership
SELECT
    home_ownership AS Home_Ownership,
    COUNT(id) AS Total_Loan_Applications,
    SUM(loan_amount) AS Total_Funded_Amount,
    SUM(total_payment) AS Total_Amount_Received
FROM bank_loan_data
GROUP BY home_ownership
ORDER BY home_ownership;


/* =====================================================================
   NOTE: Filters on dashboards
   Multiple filters are applied on all dashboards. You can check results
   for a filter by modifying the query and comparing the output.
   ===================================================================== */

-- Q32. Example filter: Purpose-wise results when Grade 'A' is selected on the dashboard
SELECT
    purpose AS PURPOSE,
    COUNT(id) AS Total_Loan_Applications,
    SUM(loan_amount) AS Total_Funded_Amount,
    SUM(total_payment) AS Total_Amount_Received
FROM bank_loan_data
WHERE grade = 'A'
GROUP BY purpose
ORDER BY purpose;

