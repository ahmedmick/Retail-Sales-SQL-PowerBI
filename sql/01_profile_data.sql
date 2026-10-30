/*
 ---------------------------------------------------------------------------------
| Original Database URL: https://archive.ics.uci.edu/dataset/502/online+retail+ii |
 ---------------------------------------------------------------------------------
- I used a version of this dataset from kaggle and the URL is below:
 -----------------------------------------------------------------------------------
| Kaggle Database URL: https://www.kaggle.com/datasets/mashlyn/online-retail-ii-uci |
 -----------------------------------------------------------------------------------
Description of every column(copied from the database source page):
1 - invoice: Invoice number. Nominal. A 6-digit integral number uniquely assigned to each transaction. If this code starts with the letter 'C', it indicates a cancellation. 
2 - stockcode: Product (item) code. Nominal. A 5-digit integral number uniquely assigned to each distinct product (Note: not always 5 digits in this data). 
3 - description: Product (item) name. Nominal. 
4 - quantity: The quantities of each product (item) per transaction. Numeric.	
5 - invoicedate: Invoice date and time. Date/Time. The day and time when a transaction was generated. 
6 - price: Unit price. Numeric. Product price per unit in sterling (£). 
7 - customerid: Customer number. Nominal. A 5-digit integral number uniquely assigned to each customer. 
8 - country: Country name. Nominal. The name of the country where a customer resides.
*/

-- Overview of the Database's values
SELECT *
FROM sales_data
LIMIT 5;

-- Get the Name and Type of every Column
SELECT column_name, data_type
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE table_name = 'sales_data';
/*
 ---------------------------------------------------------------------------
|   "column_name"    :   "column_name"     :         "data_type"            |
| (Original Dataset) : ( Kaggle Version )  :                                |
 ---------------------------------------------------------------------------
|    "UnitPrice"     :      "price"		   :       "numeric (10, 2)"        |
|    "Quantity"      :     "quantity"	   :          "integer"             |
|   "InvoiceDate"    :    "invoicedate"    :  "timestamp without time zone" |
|    "CustomerID"    :    "customerid"     :     "character varying (20)"   |
|    "InvoiceNo"     :     "invoice"	   :     "character varying (20)"   |
|     "Country"      :     "country"       :     "character varying (50)"   |
|    "StockCode"     :    "stockcode"      :     "character varying (20)"   |
|   "Description"    :   "description"     :     "character varying (255)"  |
 ---------------------------------------------------------------------------
*/


-- Get the total row count
SELECT COUNT(*) AS "Total Counts of Rows"
FROM sales_data;
-- Total counts of Rows: 1067371

-- Get the total column count
SELECT COUNT(*) AS "Total Counts of Columns"
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE table_name = 'sales_data';
-- Total counts of Columns: 8

-- Get the counts of unique invoices
SELECT COUNT(DISTINCT invoice) AS "Total Counts of unique invoices"
FROM sales_data;
-- Total counts of unique invoices: 53628 (Note: unique invoices include cancellations)

-- Get the counts of unique customers
SELECT COUNT(DISTINCT customerid) AS "Total Counts of unique customers"
FROM sales_data;
-- Total counts of unique customers: 5942 (unique customers exclude those missing IDs)

-- Get the counts of unique products
SELECT COUNT(DISTINCT stockcode) AS "Total Counts of unique products"
FROM sales_data;
-- Total counts of unique products: 5305
-- Note: some stockcode has an additional letter which is another variant of the same product

-- Get the counts of unique countries
SELECT COUNT(DISTINCT country) AS "Total Counts of unique countries"
FROM sales_data;
-- Total counts of unique countries: 43

-- Get the range of the database's data
SELECT MIN(invoicedate) AS "Start Date", MAX(invoicedate) AS "End Date"
FROM sales_data;
-- Data ranges from 1 Dec 2009 to 9 Dec 2011

-- Data Quality Checks

/*
 -------------------------------------------------
|                 Summary Table                   |
 -------------------------------------------------
|                 Issue                  |  Rows  |
 -------------------------------------------------
| * Missing CustomerID                   | 243007 |
| * Missing description                  |   4382 |
| * Cancelled invoices                   |  19494 |
| * Quantity <= 0                        |  22950 |
| * Price <= 0                           |   6225 |
| * Duplicate groups                     |  32909 |
| * Rows with non-standard stock codes:  |   6093 |
|(5871 exclude (96.4%), 222 keep (3.6%)) |    -   |
| * Missing description with price > 0   |      0 |
|(the price filter already removes them) |    -   |
 -------------------------------------------------
*/
-- Count rows with a missing customerid
SELECT COUNT(*) AS "Missing customerid count"
FROM sales_data
WHERE customerid IS NULL;
-- Rows with missing CustomerID: 243007 (22.8% of total dataset)

-- Count rows with a missing description
SELECT COUNT(*) AS "Missing description count"
FROM sales_data
WHERE description IS NULL;
-- Rows with missing Description: 4382 (0.411% of total dataset)

-- Counts of Cancelled invoices
SELECT COUNT(*) AS "Cancelled invoices count"
FROM sales_data
WHERE invoice LIKE 'C%';
-- Count of cancelled invoices: 19494 (1.83%)
/*
Note:
- No invoice starts with a lowercase ‘c’.
*/

-- Count the number of Quantity values <= 0
SELECT COUNT(*) AS "Count of Quantity <= 0"
FROM sales_data
WHERE quantity <= 0;
-- Count of Quantity <= 0: 22950 (2.15% of total dataset)

-- Count the number of Price values <= 0
SELECT COUNT(*) AS "Count of Price <= 0"
FROM sales_data
WHERE price <= 0;
-- Count of Price <= 0: 6225 (0.58% of total dataset)

-- Count the duplicate groups
SELECT COUNT(*)
FROM (
	SELECT invoice, stockcode, quantity, invoicedate, price, customerid
	FROM sales_data
	GROUP BY 1, 2, 3, 4, 5, 6
	HAVING COUNT(*) > 1
) d;
-- Number of Duplicate groups: 32909

-- Non-product stock codes, List codes that don’t start with five digits:
SELECT stockcode, description, COUNT(*) AS "Rows Counts"
FROM sales_data
WHERE stockcode !~ '^[0-9]{5}'
GROUP BY 1, 2
ORDER BY 3 DESC;

-- Count of all codes that don’t start with five digits:
SELECT COUNT(*) AS "Rows Counts"
FROM sales_data
WHERE stockcode !~ '^[0-9]{5}';
-- Count of non-standard stock codes: 6093

/*
Show table of products that don’t have a standard stock code which include:
- stockcode of the product
- description of the product
- rows_count which shows number of repetition
- revenue (price * quantity) of the product
- suggested_decision: decision taken which to keep, exclude or decide
*/
SELECT stockcode, description,
       COUNT(*) AS rows_count,
       SUM(quantity * price) AS revenue,
       CASE
         WHEN COALESCE(description, '') = '' THEN 'Decide'
         WHEN description ILIKE ANY (ARRAY['%postage%','%carriage%','%bank charges%',
              '%manual%','%discount%','%adjust%','%fee%','%commission%','%test%',
              '%sample%','%damage%']) THEN 'Exclude?'
         WHEN description ILIKE '%voucher%' THEN 'Decide'
         ELSE 'Keep?'
       END AS suggested_decision
FROM sales_data
WHERE stockcode !~ '^[0-9]{5}'
GROUP BY 1, 2
ORDER BY suggested_decision, revenue DESC;

/*
Decisions for all 92 non-standard stock codes (keep / exclude and the reason
for each) are in docs/non_product_decisions.csv.
Notes:
- 19 stock codes are shared between real products and zero-price junk rows,
  so these are removed with a price > 0 filter, not by stock code.
- 'm' and 'M' are separate values (both are manual entries).
- Voucher descriptions contain an encoding glitch (Â£) that exists in the dataset.
*/

-- Check missing descriptions that still have a price above 0
SELECT COUNT(*)
FROM sales_data
WHERE description IS NULL AND price > 0;
-- Missing description with price > 0: 0, so the price filter already removes them

-- Checking quantity outliers
SELECT *
FROM sales_data
ORDER BY quantity DESC
LIMIT 10;
/*
the two largest quantities (80,995 and 74,215)
are far above the next one (19,152)
*/

-- Checking price outliers
SELECT *
FROM sales_data
ORDER BY price DESC
LIMIT 10;

-- Checking whether the two largest orders were cancelled by matching negative rows
SELECT invoice, stockcode, quantity, price, customerid, invoicedate
FROM sales_data
WHERE stockcode IN ('23843', '23166')
  AND ABS(quantity) IN (80995, 74215)
ORDER BY stockcode, invoicedate;

/*
Findings that affect cleaning:
- Highest prices are all non-products (M, BANK CHARGES, AMAZONFEE) which will be excluded.
- The two largest orders (80,995 units of 23843 and 74,215 units of 23166) were
  both cancelled minutes later (invoices C581484 and C541433), so each pair nets
  to zero. Together they would add about £245,653 of false revenue if the
  cancellations were removed but the original orders kept.
- Customer 13902 (Denmark) has several large wholesale orders at 0.10 each. Kept as real.
- customerid is stored as text with a trailing ".0" (e.g. "16446.0") and needs cleaning.
- Missing customerid rows (22.8%) are kept in the clean table and only filtered
  out in the customer (RFM) analysis.
- Decision: cancelled invoices (C%) are kept in the clean table, so revenue is
  calculated as net revenue (sales minus cancellations).
*/

/*
Open for the cleaning step:
- Duplicates (32,909 groups): decide whether to remove all or only exact repeats.
- About 3,456 rows have quantity <= 0 but are not cancellations (22,950 - 19,494);
  check what they are before deciding.
- Clean customerid (remove the trailing ".0").
- Final cleaning rules: price > 0, excluded stock codes (non-standard codes decided
  in docs/non_product_decisions.csv), keep cancellations (net revenue).
*/

