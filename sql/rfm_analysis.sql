-- Query C: RFM Analysis ->a customer segmentation method 
--          that uses a customer's past behavior to rank 
--          and group them based on Recency (how recently they purchased), 
--          Frequency (how often they purchase), 
--          and Monetary value (how much they spend).

SELECT
    customerid,
    MAX(invoicedate) AS Last_Purchase_Date,
    COUNT(DISTINCT invoice) AS Frequency,
    SUM(quantity * price) AS Monetary_Value
FROM sales_data
WHERE invoice NOT LIKE 'C%'
GROUP BY customerid;