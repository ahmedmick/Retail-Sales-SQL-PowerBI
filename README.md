# Retail Sales Analysis: SQL & Power BI

## Business Problem
An online retailer wants to understand its sales performance: when it earns the most, which products drive revenue, and which customers are worth keeping. 
This project cleans and analyzes transaction records in SQL and presents the results in a Power BI dashboard.

## Questions
1. How does revenue change over time?
2. Which products sell the most?
3. Who are the most valuable customers?

## Dataset
Online Retail II (UCI Machine Learning Repository): transactions of a UK-based
online retailer from December 2009 to December 2011. The Kaggle copy of the
dataset was used.
- 1,067,371 rows, 8 columns
- 5,942 customers, 43 countries

## Tools
PostgreSQL (pgAdmin), Power BI

## Data Cleaning
The raw table (`sales_data`) was left untouched, and a cleaned copy (`sales_clean`)
was created in `sql/02_clean_data.sql`.

| Step | Rows |
|---|---|
| Raw data | 1,067,371 |
| Removed: price of 0 or below | 6,225 |
| Removed: non-product stock codes (postage, fees, adjustments, test entries) | 5,778 |
| Removed: exact duplicates | 34,035 |
| **Clean data** | **1,021,333** |

Decisions made:
- Cancelled invoices were kept, so revenue is net of cancellations.
- Rows with a missing customer ID (22.8%) were kept, and are excluded only from
  the customer analysis.
- The 92 non-standard stock codes were reviewed one by one. The decisions and
  reasons are in `docs/non_products_decisions.csv`.

## KPI Definitions
- **Revenue:** net revenue (sales minus cancellations)
- **Orders:** distinct invoices that are not cancellations
- **Customers:** distinct customer IDs (rows with no ID are not counted)
- **Average order value:** net revenue divided by orders

## Project Status
Data profiling and cleaning are complete. Revenue trends, top products,
customer segmentation (RFM), and the Power BI dashboard are in progress.
## Structure of Project

```
Retail-Sales-SQL-PowerBI/
├── data/
│   └── online_retail_II.csv
├── docs/
│   └── non_products_decisions.csv
├── sql/
│   ├── 01_profile_data.sql
│   ├── 02_clean_data.sql
│   ├── 03_revenue_trends.sql (in progress)
│   ├── 04_top_products.sql (in progress)
│   └── 05_rfm_analysis.sql (in progress)
├── powerbi/
│   ├── Dashboard.pbix
│   └── my_dashboard.png
└── README.md
```
