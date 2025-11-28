-- Query A: Total Revenue by Month (Trend Analysis)
SELECT 
    TO_CHAR(InvoiceDate, 'YYYY-MM') AS Month, 
    SUM(Quantity * price) AS TotalRevenue
FROM sales_data
GROUP BY Month
ORDER BY Month;