# 🏦 Bank Loan Analytics Dashboard | Power BI + SQL + Python

An interactive **Power BI dashboard** that analyzes a bank's 2021 loan portfolio: lending performance, repayment behavior, and credit risk. The project covers the full analytics workflow: data cleaning in Python, analysis in SQL, KPI calculation in DAX, and a dark-themed two-page dashboard.

🔗 **[View the live dashboard](https://app.powerbi.com/links/79FSmRYO24?ctid=fdcf6fad-c3f0-4c66-8ca1-1e3aaac65150&pbi_source=linkShare)**

---

## 📌 Project Overview

The dashboard helps stakeholders:

- Monitor lending performance and how it changes month over month
- Compare good loans against bad loans
- Track repayment behavior (amount funded vs amount received)
- Identify high-risk grades, purposes, terms and regions
- Understand borrower profiles (income, DTI, home ownership, employment)

---

## 🎯 Problem Statement

The bank needs a comprehensive **Bank Loan Report** to monitor its lending activity, track portfolio health, and spot trends that can guide lending strategy. The report must show:

- Total Loan Applications, Funded Amount and Amount Received
- Average Interest Rate and Average Debt-to-Income (DTI) Ratio
- Month-to-Date (MTD) values and Month-over-Month (MoM) change for each KPI
- Good Loan vs Bad Loan performance
- Loan trends by month, region, term, home ownership and purpose

**Loan classification used in this project**

| Category | Loan Status |
|----------|-------------|
| ✅ Good Loan | Fully Paid, Current |
| ❌ Bad Loan | Charged Off |

---

## 📊 Dashboard Features

### 📍 Dashboard 1: Summary

**KPIs:** Total Loan Applications · Total Funded Amount · Total Amount Received · Average Interest Rate · Average DTI (each with MTD and MoM change)

**Visuals**
- 🍩 Good Loan applications, funded amount and amount received
- 🍩 Bad Loan applications, funded amount and amount received
- 📋 Loan Status grid view (applications, funded, received, interest rate, DTI)

### 📍 Dashboard 2: Overview

**Visuals**
- 📈 Monthly trend of applications, funded amount and amount received
- 🗺 Regional analysis by state (filled map)
- 🍩 Loan term analysis (36 vs 60 months)
- 📊 Employee length analysis
- 📊 Home ownership analysis
- 🌳 Loan purpose breakdown

**Interactive features**
- Slicers: Purpose, Grade
- Page navigation buttons
- Reset Filters button

---

## 📈 Key Business Insights

All figures come from the 38,576 loans issued between 1 Jan and 12 Dec 2021.

### Portfolio health

| Metric | Value |
|--------|-------|
| Total Loan Applications | 38,576 |
| Total Funded Amount | $435.76M |
| Total Amount Received | $473.07M |
| Average Interest Rate | 12.05% |
| Average DTI | 13.33% |
| Good Loans | 33,243 (86.18%) |
| Bad Loans | 5,333 (13.82%) |

### What the data shows

1. **The portfolio is growing fast.** Monthly applications rose from 2,332 in January to 4,314 in December, and monthly funding grew from $25.0M to $54.0M. December is a partial month (data ends 12 Dec), yet it still grew 6.9% in applications and 13.0% in funded amount over November.
2. **Bad loans lose money.** Charged Off loans were funded $65.5M but returned only $37.3M, which is about 57% of the principal. Good loans returned more than they were funded.
3. **Risk climbs steadily with grade.** The bad loan rate is 5.7% for Grade A, 11.5% for B, 16.0% for C, 20.7% for D, 24.8% for E, 30.3% for F and 31.3% for G.
4. **60-month loans are twice as risky.** 60-month loans have a 22.3% bad loan rate against 10.7% for 36-month loans, even though they make up only 26.8% of applications.
5. **Small business is the riskiest purpose.** It has a 25.6% bad loan rate, far above the portfolio's 13.8%. Debt consolidation is the largest purpose (47.2% of applications, $232.5M funded) with a 14.6% bad loan rate.
6. **Lending is concentrated by region.** California alone accounts for 17.9% of applications and $78.5M funded. Florida has the highest bad loan rate among the top states at 17.3%.
7. **Charged Off loans carry higher rates and DTI.** Their average interest rate is 13.9% against 11.6% for Fully Paid loans, and their average DTI is 14.0% against 13.2%.
8. **Renters and mortgage holders drive the volume.** Together they make up 92.4% of applications; renters have a higher bad loan rate (14.6%) than mortgage holders (13.0%).

---

## 🛠 Tools & Technologies

| Tool | Purpose |
|------|---------|
| **Power BI** | Dashboard development |
| **DAX** | KPI, MTD and MoM calculations |
| **Power Query** | Data transformation |
| **SQL (MySQL)** | Data analysis (CTEs, subqueries, window functions) |
| **Python (pandas, matplotlib, seaborn)** | Data cleaning and exploratory analysis |
| **Excel** | Source dataset |

---

## 🧾 Dataset Information

**Source file:** `Financial_loan_data.xlsx`, with 38,576 loan applications and 23 columns.

| Column | Description |
|--------|-------------|
| ISSUE_DATE | Date the loan was issued |
| ID / MEMBER_ID | Unique loan and customer identifiers |
| PURPOSE | Reason for the loan |
| VERIFICATION_STATUS | Whether income or details were verified |
| GRADE / SUB_GRADE | Risk grade (A = lowest risk, G = highest risk) and its sub-category |
| HOME_OWNERSHIP | Rent, Mortgage, Own, etc. |
| ADDRESS_STATE | Borrower's state |
| LOAN_STATUS | Fully Paid, Current or Charged Off |
| EMP_LENGTH / EMP_TITLE | Employment length and job title |
| TERM | 36 or 60 months |
| ANNUAL_INCOME | Borrower's yearly income |
| DTI | Debt-to-Income ratio |
| INSTALLMENT | Fixed monthly payment |
| INT_RATE | Interest rate charged |
| LOAN_AMOUNT | Amount funded |
| TOTAL_ACC | Total credit accounts held |
| TOTAL_PAYMENT | Total amount repaid |
| LAST_CREDIT_PULL_DATE / LAST_PAYMENT_DATE / NEXT_PAYMENT_DATE | Credit and payment dates |

> `INT_RATE` and `DTI` are stored as decimals (0.1864 = 18.64%). `TERM` values contain a leading space, so the SQL scripts use `TRIM(TERM)`.

---

## 🗃 SQL Analysis

Two scripts are included (MySQL 8.0+). Both expect a table named `loan_data` in a database named `bank_loan_analytics`.

| File | What it covers |
|------|----------------|
| `Bank_Loan_Analytics.sql` | Full script: table setup, data quality checks, KPIs, MTD/MoM scorecard, good vs bad loans, grade and segment risk analysis, banded analysis, Top-N, and a Power BI view |
| `Bank_Loan_Simple_Queries.sql` | 28 short queries for learning: basics, `CASE WHEN`, date functions, subqueries, CTEs and window functions (`RANK`, `LAG`, `ROW_NUMBER`, running totals, moving averages) |

**Example: MoM change in funded amount using a CTE and `LAG`**

```sql
WITH monthly AS (
    SELECT MONTH(ISSUE_DATE) AS month_no, SUM(LOAN_AMOUNT) AS funded
    FROM loan_data
    GROUP BY MONTH(ISSUE_DATE)
)
SELECT
    month_no,
    funded,
    ROUND((funded - LAG(funded) OVER (ORDER BY month_no)) * 100.0
          / LAG(funded) OVER (ORDER BY month_no), 2) AS mom_pct
FROM monthly;
```

---

## 🎨 Dashboard Theme

| Element | Color |
|---------|-------|
| Canvas Background | `#0B0D12` |
| Visual Background | `#11151C` |
| Borders | `#232A35` |
| Accent Gold | `#F5A524` |
| KPI Value | `#F0E199` |
| Titles | White |

---

## 📸 Dashboard Preview

### Dashboard 1: Summary
<img width="3075" height="1763" alt="Dashboard 1 - Summary" src="https://github.com/user-attachments/assets/e476622d-8338-4137-be54-7ab068eb3643" />

### Dashboard 2: Overview
<img width="3075" height="1763" alt="Dashboard 2 - Overview" src="https://github.com/user-attachments/assets/f86d944a-12c1-4007-841e-d8fbb7add6ef" />

---

## 📂 Project Files

```
Bank-Loan-Analytics-Dashboard/
├── Bank_Loan_Dashboard.pbix            # Power BI dashboard
├── Financial_loan_data.xlsx            # Source dataset
├── Bank_Loan_Description.pdf           # Column descriptions
├── Problem_Statement.pptx              # Project brief and theme
├── Bank_Loan_Analysis_Using_Python.ipynb   # Data cleaning & EDA
├── Bank_Loan_Analytics.sql             # Full SQL analysis script
├── Bank_Loan_Simple_Queries.sql        # Short beginner-friendly queries
└── README.md
```

---

## 🚀 How to Use

1. Clone or download this repository.
2. Open `Bank_Loan_Dashboard.pbix` in **Power BI Desktop**, or use the live link above.
3. To reproduce the SQL analysis, load `Financial_loan_data.xlsx` into MySQL as `loan_data` (see the setup section in `Bank_Loan_Analytics.sql`) and run the scripts.

---

## 🔥 Skills Demonstrated

- Data cleaning and exploratory analysis (Python)
- SQL analytics: CTEs, subqueries, window functions
- DAX measures, including MTD and MoM
- Dashboard design and data storytelling
- Credit risk and financial portfolio analysis

---

## 👨‍💻 Author

**Deepak Malviya**

🔗 [LinkedIn](https://www.linkedin.com/in/deepak102825/)

---

## ⭐ Support

If you like this project, give the repository a ⭐ and share your feedback!

## 📜 License

This project is licensed under the MIT License.
