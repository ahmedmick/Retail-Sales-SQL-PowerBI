/*
Original Database URL: https://archive.ics.uci.edu/dataset/502/online+retail+ii 
# I used a version of this dataset from kaggle and the URL is below:
Kaggle Database URL: https://www.kaggle.com/datasets/mashlyn/online-retail-ii-uci
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
|    "UnitPrice"     :      "price"		:          "numeric"             |
|    "Quantity"      :     "quantity"	    :          "integer"             |
|   "InvoiceDate"    :    "invoicedate"    :  "timestamp without time zone" |
|    "CustomerID"    :    "customerid"     :       "character varying"      |
|    "InvoiceNo"     :     "invoice"	    :       "character varying"      |
|     "Country"      :     "country"       :       "character varying"      |
|    "StockCode"     :    "stockcode"      :       "character varying"      |
|   "Description"    :   "description"     :       "character varying"      |
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

-- Count rows with a missing CustomerID
SELECT COUNT(*)
FROM sales_data
WHERE customerid IS NULL;
-- Rows with missing CustomerID: 243007 (22.8% of total dataset)
