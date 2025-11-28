-- Query B: Top 5 Best-Selling Products
SELECT 
    Description,
    SUM(quantity) AS TotalSold
FROM sales_data
GROUP BY Description
ORDER BY TotalSold DESC
LIMIT 5;