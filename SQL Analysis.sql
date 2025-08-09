--1) List all sales with product names and sale amounts.
SELECT p.Product AS ProductName, s.Amount
FROM sales_table s
JOIN products p ON s.ProductID = p.ProductID
where status = 'Sold';  

--2) Show all unique customers who made purchases in January 2019.
SELECT DISTINCT Id
FROM Sales_table
WHERE Date >= '2019-01-01' AND Date < '2019-02-01';

--3) Get the number of products sold per store.
SELECT StoreID, SUM(Unit) AS TotalProductsSold
FROM Sales_table
GROUP BY StoreID;

--4) Retrieve a list of products with prices greater than $70.
select product, Price
from Products
where Price > 70;

--5) Count how many customers belong to each age group.
SELECT Age, COUNT(*) AS CustomerCount
FROM customers
GROUP BY Age
order by CustomerCount desc;

--6) Calculate the total revenue per product category.
SELECT p.Category AS CategoryName, sum(s.Amount)
FROM sales_table s
JOIN products p ON s.ProductID = p.ProductID
where status = 'Sold' 
group by p.Category

--7) Find the top 5 products by number of units sold.
SELECT TOP 5  p.Product AS ProductName, SUM(s.Unit) AS Units_Sold
FROM sales_table s
JOIN products p ON s.ProductID = p.ProductID
WHERE s.Status = 'Sold'
group by p.Product
ORDER BY Units_Sold DESC;

--8) Show the average sales amount per store.
select s.StoreID, AvG(Amount) AS AverageSalesAmount
FROM sales_table s
WHERE s.Status = 'Sold'
group by s.StoreID
order by AverageSalesAmount;

--9) Identify which stores have sold more than 500 units in total.
select st.storeID,s.Store,sum(st.Unit) AS Units_Sold
FROM sales_table st
JOIN Stores s ON st.storeID = s.storeID
WHERE Status = 'Sold'
GROUP BY st.StoreID,s.Store
having sum(st.Unit) > 500
order by Units_Sold desc

--10) List customers who made more than one purchase.
SELECT ID, COUNT(*) AS PurchaseCount
FROM Sales_table
GROUP BY ID
HAVING COUNT(*) > 1;

--11) Find stores that failed to meet their net sales goals.
SELECT st.StoreID, Net_Sales_Goal AS SalesGoal, SUM(Amount) AS NetSales
FROM Sales_table st
JOIN storegoals g ON st.StoreID = g.StoreID
WHERE st.Status = 'Sold'
GROUP BY st.StoreID, g.Net_Sales_Goal
HAVING SUM(st.Amount) < g.Net_Sales_Goal;

--12) Identify the age groups that generated the highest total revenue.
SELECT c.Age, SUM(s.Amount) AS TotalRevenue
FROM sales_table s
JOIN Customers c ON s.ID = c.ID
WHERE s.Status = 'Sold'
GROUP BY c.Age
ORDER BY TotalRevenue DESC;

--13) Show product segments with average prices above the overall average.
SELECT Segment, AVG(Price) AS AverageSegmentPrice
FROM products
GROUP BY Segment
HAVING AVG(Price) > (SELECT AVG(Price) FROM products);

--14) Find customers who bought products from at least 3 different categories.
SELECT s.ID, COUNT(DISTINCT p.Category) AS CategoryCount
FROM Sales_table s
JOIN products p ON s.ProductID = p.ProductID
WHERE s.Status = 'Sold'
GROUP BY s.ID
HAVING COUNT(DISTINCT p.Category) >= 3;

--15) Calculate the sales achievement % per store region.
SELECT sg.Store_Region AS StoreRegion, SUM(s.Amount) AS TotalSales,
    SUM(sg.Net_Sales_Goal) AS TotalGoal,
    ROUND(SUM(s.Amount) * 100.0 / NULLIF(SUM(sg.Net_Sales_Goal), 0), 2) AS SalesAchievementPercent
FROM Sales_table s
JOIN storegoals sg ON s.StoreID = sg.StoreID
WHERE s.Status = 'Sold'
GROUP BY sg.Store_Region;

--16) . Identify stores with declining weekly sales trends. 
WITH WeeklySales AS (
    SELECT 
        StoreID,
        DATEPART(YEAR, Date) AS SalesYear,
        DATEPART(WEEK, Date) AS SalesWeek,
        SUM(Amount) AS WeeklyAmount
    FROM 
        Sales_table
    WHERE 
        Status = 'Sold'
    GROUP BY 
        StoreID, DATEPART(YEAR, Date), DATEPART(WEEK, Date)
)
, Trend AS (
    SELECT 
        StoreID,
        SalesYear,
        SalesWeek,
        WeeklyAmount,
        LAG(WeeklyAmount) OVER (PARTITION BY StoreID ORDER BY SalesYear, SalesWeek) AS PrevWeekAmount
    FROM 
        WeeklySales
)
SELECT 
    StoreID,
    COUNT(*) AS DeclineWeeks
FROM 
    Trend
WHERE 
    PrevWeekAmount IS NOT NULL AND WeeklyAmount < PrevWeekAmount
GROUP BY 
    StoreID
HAVING 
    COUNT(*) >= 2; 

--17) Determine which product segment contributes the most to total sales revenue.
SELECT p.Segment, SUM(s.Amount) AS TotalRevenue
FROM Sales_table s
JOIN products p ON s.ProductID = p.ProductID
WHERE s.Status = 'Sold'
GROUP BY p.Segment
ORDER BY TotalRevenue DESC;

--18) List the top 3 performing stores in each region based on revenue.
SELECT s.StoreID,
       sg.Store_Region,
       SUM(s.Amount) AS TotalRevenue
FROM   Sales_table s
JOIN   storegoals sg ON s.StoreID = sg.StoreID
WHERE  s.Status = 'Sold'
GROUP BY s.StoreID, sg.Store_Region
order by sg.Store_Region,TotalRevenue desc

--19) Find the number of unique customers served per store.
SELECT StoreID,
       COUNT(DISTINCT ID) AS UniqueCustomers
FROM   Sales_table
WHERE  Status = 'Sold'
GROUP BY StoreID
ORDER BY UniqueCustomers DESC;

--20) Retrieve sales data where the product belongs to a category starting with 'Office'.
SELECT 
    s.*
FROM 
    Sales_table s
JOIN 
    products p ON s.ProductID = p.ProductID
WHERE 
    p.Category LIKE 'Office%' 
    AND s.Status = 'Sold';


