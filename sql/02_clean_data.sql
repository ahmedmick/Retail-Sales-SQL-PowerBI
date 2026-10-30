/*
 --------------------------------------------------------------------------------
|             Rule	                       |                  Reason             |
 --------------------------------------------------------------------------------
| Keep sales_data untouched, and create    |    The raw data stays safe          |
| a new table sales_clean	               |                                     |
 --------------------------------------------------------------------------------
|     									   | Removes zero-price junk, including  |
|		Keep only rows with price > 0	   |   the junk rows that share a code   |
|										   |        with real products           |
 --------------------------------------------------------------------------------
|    Exclude the non-product codes:        |    These never share a code with    |
|   POST, DOT, C2, C3, ADJUST, ADJUST2,    |    a real product, so excluding     |
|    TEST001, TEST002, M, m, S, D, B,      |          by code is safe            |
|     BANK CHARGES, CRUK, AMAZONFEE        |	 								 |		
 --------------------------------------------------------------------------------
|    Keep cancellations (C% invoices)	   | 		Revenue is calculated net    |
|                            			   |		    of cancellations    	 |
 --------------------------------------------------------------------------------
|   Keep rows with a missing customerid    |		Filtered out later,          | 
|										   |	  only in the RFM analysis       |
 --------------------------------------------------------------------------------
| Remove the trailing .0 from customerid  |       Turns 16446.0 into 16446       |
 --------------------------------------------------------------------------------
| Add a revenue column (quantity * price) |			 Revenue per row        	 |
 --------------------------------------------------------------------------------
|      Add an is_cancelled flag           |  Makes the Orders KPI easier later   | 
 --------------------------------------------------------------------------------
|       Remove exact duplicates           |    Identical rows are most likely    |
|          (SELECT DISTINCT)              |         data-entry duplicates        |
 --------------------------------------------------------------------------------

 --------------------------------------
|     Process     |    Number of rows  |
 --------------------------------------
| Before cleaning |    1,067,371 rows  |
 --------------------------------------
|  After cleaning |    1,021,333 rows  |
 --------------------------------------
|    Removed      | 46,038 rows (4.3%) |	
 --------------------------------------
*/

-- Drop sales_clean if it already exists
DROP TABLE IF EXISTS sales_clean;

-- Create the clean table
CREATE TABLE sales_clean AS
SELECT DISTINCT
    invoice,
    stockcode,
    description,
    quantity,
    invoicedate,
    price,
    NULLIF(SPLIT_PART(customerid, '.', 1), '') AS customerid,
    country,
    quantity * price AS revenue,
    (invoice LIKE 'C%') AS is_cancelled
FROM sales_data
WHERE price > 0
  AND stockcode NOT IN ('POST', 'DOT', 'C2', 'C3', 'ADJUST', 'ADJUST2',
                        'TEST001', 'TEST002', 'M', 'm', 'S', 'D', 'B',
                        'BANK CHARGES', 'CRUK', 'AMAZONFEE');

-- Validate the result
SELECT COUNT(*) AS "Count of the rows"
FROM sales_clean; 
-- Count of the rows: 1,021,333 rows

SELECT COUNT(*) AS "Count of the non-positive prices"
FROM sales_clean 
WHERE price <= 0;                     
-- Count of the non-positive prices: 0 rows

SELECT COUNT(*) AS "Count of null descriptions"
FROM sales_clean 
WHERE description IS NULL;            
-- Count of null descriptions: 0 rows

SELECT COUNT(*) AS "Count of invalid customerid"
FROM sales_clean 
WHERE customerid LIKE '%.%';          
-- Count of invalid customerid: 0 rows

SELECT COUNT(*) AS "Count of non-standard stockcode"
FROM sales_clean
WHERE stockcode IN ('POST','DOT','C2','C3','ADJUST','ADJUST2','TEST001','TEST002',
                    'M','m','S','D','B','BANK CHARGES','CRUK','AMAZONFEE');  
-- Count of non-standard stockcode: 0 rows

SELECT COUNT(DISTINCT customerid) AS "Count of unique customerid"
FROM sales_clean;                    
-- Count of unique customerid: 5875 customers

SELECT COUNT(*) AS "Count of non-positive and non-cancelled values"
FROM sales_clean
WHERE quantity <= 0 AND is_cancelled = false;                          
-- Count of non-positive and non-cancelled values: 0 rows

SELECT COUNT(*) AS "Customers lost in cleaning"
FROM (
    SELECT DISTINCT SPLIT_PART(customerid, '.', 1) AS customerid
    FROM sales_data
    WHERE customerid IS NOT NULL
    EXCEPT
    SELECT DISTINCT customerid
    FROM sales_clean
    WHERE customerid IS NOT NULL
) t;
/*
Count of Customers lost in cleaning: 67

Note:
5,942 − 5,875 = 67 customers appeared only in removed rows.
*/

-- Counts of removed_non_positive_price and removed_excluded_codes
SELECT
  COUNT(*) FILTER (WHERE price <= 0) AS removed_non_positive_price,
  COUNT(*) FILTER (WHERE price > 0 AND stockcode IN ('POST','DOT','C2','C3','ADJUST',
      'ADJUST2','TEST001','TEST002','M','m','S','D','B','BANK CHARGES','CRUK','AMAZONFEE'))
      AS removed_excluded_codes
FROM sales_data;
/*
Count of removed_non_positive_price: 6225
Count of removed_excluded_codes: 5778

 --------------------------------------------------------------------------------------
|                      The 46,038 removed rows split like this:                        |
 --------------------------------------------------------------------------------------
|                 Reason	                   :     Rows    : Share of the raw data   |
 --------------------------------------------------------------------------------------
|                Price ≤ 0                     :	 6,225  :         0.58%            |
 --------------------------------------------------------------------------------------
| Excluded non-product stock codes (price > 0) :	 5,778	:         0.54%            |
 --------------------------------------------------------------------------------------
|             Exact duplicates                 :	34,035	:         3.19%            |
 --------------------------------------------------------------------------------------
|              Total removed                   :	46,038	:         4.31%            |
 --------------------------------------------------------------------------------------

 Note:
 1,055,368 rows pass the two filters (removed_non_positive_price, removed_excluded_codes)
 1,021,333 rows remain after DISTINCT (1,067,371 - 46,038 = 1,021,333) 
 34,035 rows are duplicates (46,038 - (6,225 + 5,778) = 34,035)
*/
