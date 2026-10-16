# 🏦 Bank Loan Analysis | End-to-End Data Analytics Project

> **Finance Domain | Data Analytics | SQL | Power BI | Python**

<p align="center">
  <a href="https://app.fabric.microsoft.com/links/WM-Ofi9lY5?ctid=fdcf6fad-c3f0-4c66-8ca1-1e3aaac65150&pbi_source=linkShare">
    <<img width="1536" height="863" alt="Summary" src="https://github.com/user-attachments/assets/0cf761bb-2189-4632-8eaa-872fe3150395" />
>
  </a>
</p>

<p align="center">
  <a href="https://app.fabric.microsoft.com/links/WM-Ofi9lY5?ctid=fdcf6fad-c3f0-4c66-8ca1-1e3aaac65150&pbi_source=linkShare">
    <strong>🚀 View Live Power BI Dashboard</strong>
  </a>
</p>




## 📌 Project Overview

**Bank Loan Analysis** is an end-to-end data analytics project designed to monitor and evaluate lending performance, loan portfolio health, borrower characteristics, and loan trends.

The project transforms raw bank-loan data into business-focused analysis using **Python, MS SQL Server, and Power BI**. It covers data exploration and analysis, SQL-based business queries, KPI development, and interactive dashboard reporting.

The business requirements focus on tracking loan applications, funded amounts, amounts received, average interest rate, DTI, and Good Loan vs Bad Loan performance. The dashboards also analyze monthly trends, states, loan terms, employee length, loan purpose, and home ownership.

---

## 🎯 Business Objective

The objective is to provide decision-makers with a clear view of:

- Loan application volume and growth
- Total funded and received amounts
- Average interest rate and DTI
- Good Loan vs Bad Loan performance
- Loan status performance
- Monthly lending trends
- Geographic lending activity
- Loan term distribution
- Borrower employment length
- Loan purpose distribution
- Home ownership distribution

The project is built around the requirement to use loan data to support **data-driven lending decisions, portfolio monitoring, and trend identification**.

---

## 🛠️ Tech Stack

| Technology | Purpose |
|---|---|
| 🐍 **Python** | Data loading, exploration, analysis and preparation |
| 🗄️ **MS SQL Server** | Database storage and business-question SQL analysis |
| 📊 **Power BI** | Interactive dashboards, KPIs, visual analytics and navigation |
| 🧮 **DAX** | Measures and KPI calculations |
| 🔄 **Power Query** | Data transformation and preparation |
| 📈 **Excel / MS Office** | Supporting data and analysis workflow |

---

## 🔄 End-to-End Workflow

```text
Business Requirements
        ↓
Understand Finance / Loan Domain
        ↓
Load & Explore Data in Python
        ↓
Data Cleaning & Preparation
        ↓
Load Data into MS SQL Server
        ↓
Write SQL Queries for Business Problems
        ↓
Validate / Compare Results
        ↓
Connect SQL Server to Power BI
        ↓
Build KPIs & DAX Measures
        ↓
Create Interactive Dashboards
        ↓
Business Insights & Decision Support
```

The project documentation describes the workflow around SQL Server database creation, table creation, querying, data cleaning/modeling/processing, Power Query, date tables, time intelligence and DAX, followed by KPI and visualization development.

---

# 📊 Dashboard 1 — Summary

<img width="1536" height="863" alt="Summary" src="https://github.com/user-attachments/assets/651d768c-3cdc-433a-b203-d39abc3714f1" />


### Key Performance Indicators

The Summary dashboard tracks:

- **Total Loan Applications**
- **Total Funded Amount**
- **Total Amount Received**
- **Average Interest Rate**
- **Average Debt-to-Income Ratio (DTI)**
- **MTD performance**
- **MoM changes**

### Good Loan vs Bad Loan

The dashboard classifies:

**Good Loans**
- Fully Paid
- Current

**Bad Loans**
- Charged Off

The corresponding KPIs include:

- Good Loan Application %
- Good Loan Applications
- Good Loan Funded Amount
- Good Loan Total Received Amount
- Bad Loan Application %
- Bad Loan Applications
- Bad Loan Funded Amount
- Bad Loan Total Received Amount

### Loan Status Analysis

The Loan Status grid provides a consolidated view of:

- Loan Applications
- Funded Amount
- Amount Received
- MTD Funded Amount
- MTD Amount Received
- Average Interest Rate
- Average DTI

---

# 📈 Dashboard 2 — Overview

<img width="1532" height="860" alt="Overview" src="https://github.com/user-attachments/assets/1e310056-78a7-4a76-a4b8-f4db892d1693" />


The Overview dashboard provides visual analysis across multiple dimensions.

### 📅 Monthly Trends
Tracks loan activity by **Issue Date** to identify lending trends and seasonality.

### 🗺️ Regional Analysis
Analyzes loan activity by **State** to identify regions with significant lending activity.

### ⏳ Loan Term Analysis
Compares loan applications across terms such as:

- 36 months
- 60 months

### 👨‍💼 Employee Length Analysis
Analyzes lending metrics across borrower employment-length categories.

### 🎯 Loan Purpose Analysis
Breaks down lending activity by purposes such as:

- Debt consolidation
- Credit card
- Home improvement
- Major purchase
- Small business
- Car
- Wedding
- Other

### 🏠 Home Ownership Analysis
Analyzes lending activity across:

- Rent
- Mortgage
- Own

---

# 🔎 Dashboard 3 — Details

<img width="1536" height="864" alt="Details" src="https://github.com/user-attachments/assets/4fd17199-b9e1-469e-8a9a-8ed075b1e3b7" />


The Details dashboard provides a consolidated, user-friendly view of individual loan records and important loan attributes.

It supports detailed analysis of:

- Loan ID
- Purpose
- Home Ownership
- Grade
- Sub Grade
- Issue Date
- Funded Amount
- Interest Rate
- Installment
- Amount Collection

This dashboard acts as the detailed drill-down layer behind the high-level KPI and analytical views.

---

# 🧮 SQL Analysis

SQL was used to answer the core business questions and validate dashboard metrics.

Examples of analysis performed:

```sql
-- Total Loan Applications
SELECT COUNT(id) AS Total_Applications
FROM bank_loan_data;
```

```sql
-- Total Funded Amount
SELECT SUM(loan_amount) AS Total_Funded_Amount
FROM bank_loan_data;
```

```sql
-- Total Amount Received
SELECT SUM(total_payment) AS Total_Amount_Collected
FROM bank_loan_data;
```

```sql
-- Good Loan Applications
SELECT COUNT(id) AS Good_Loan_Applications
FROM bank_loan_data
WHERE loan_status IN ('Fully Paid', 'Current');
```

```sql
-- Bad Loan Applications
SELECT COUNT(id) AS Bad_Loan_Applications
FROM bank_loan_data
WHERE loan_status = 'Charged Off';
```

SQL analysis also groups lending metrics by **month, state, term, employee length, purpose, home ownership and loan status**.

---

# 🐍 Python Analysis

Python was used for the initial data-analysis stage.

The project documentation shows a dataset containing **38,576 rows and 24 columns**, with fields covering borrower, loan, risk, date and payment information.

Core analysis included:

- Dataset import
- Data inspection
- Metadata / shape checks
- Column inspection
- Data-type inspection
- Exploratory analysis
- Loan and borrower analysis
- Preparation for downstream SQL / BI reporting

Example Python libraries used in the project:

```python
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
import plotly.express as px
```

---

# 📚 Domain Knowledge

The project incorporates lending-domain concepts such as:

- Loan Applications
- Credit Reports
- Loan Status
- Grade / Sub Grade
- DTI
- Annual Income
- Interest Rate
- Loan Amount
- Instalment
- Employment Length
- Home Ownership
- Verification Status
- Loan Term

DTI is used as an indicator of borrower debt burden relative to income, while Grade and Sub Grade support risk differentiation.

---

# 💡 Business Value

This project demonstrates how raw loan data can be converted into business intelligence for:

- **Portfolio monitoring**
- **Risk assessment**
- **Lending performance analysis**
- **Regional analysis**
- **Customer / borrower insights**
- **Profitability analysis**
- **Credit risk management**
- **Data-driven decision-making**

---

# 📌 Key Project Highlights

✅ End-to-end Data Analytics project  
✅ Finance / Banking domain  
✅ Python-based data analysis  
✅ MS SQL Server database and SQL analysis  
✅ Power BI interactive reporting  
✅ KPI development  
✅ Good vs Bad Loan analysis  
✅ MTD / MoM analysis  
✅ Loan-status analysis  
✅ Time-series analysis  
✅ Geographic analysis  
✅ Borrower segmentation  
✅ Interactive dashboard filters and navigation  

---

# 👨‍💻 Project Author

### **DEEPAK MALVIYA**

**Data Analyst | SQL | Power BI | Python | Data Analytics**

📧 **Email:** Deepakmalviya7604@gmail.com  
📱 **Phone:** +91 7989230916  

🔗 **LinkedIn:**  
https://www.linkedin.com/in/deepak102825/

🌐 **Portfolio:**  
https://deepak10281.github.io/Portfolio/

---

## ⭐ If you found this project useful

Feel free to explore the dashboards, SQL analysis and project documentation.

**Built by DEEPAK MALVIYA — turning data into actionable business insights.**
