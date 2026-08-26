
-- Sales Order Management & Customer Analytics System
--  SQL Validation & Analysis Queries
-- Run after schema + sample data scripts are loaded.


USE sales_order_management;

-- ===================================================================
-- SECTION A: DATA VALIDATION QUERIES
-- (confirm data quality before trusting it for analysis/reporting)

--  Duplicate customer emails (should be 0 — Email is UNIQUE)
SELECT email, COUNT(*)
FROM Customers
GROUP BY email
HAVING COUNT(*) > 1;

--  Orphan orders — CustomerID not present in Customers (should be 0 — FK enforced)
SELECT * FROM Orders
WHERE CustomerID NOT IN (SELECT CustomerID FROM Customers);

--  Orders with no matching line items in OrderDetails (data-entry gap check)
SELECT o.OrderID, o.Status, o.TotalAmount
FROM Orders o
WHERE o.OrderID NOT IN (SELECT DISTINCT OrderID FROM OrderDetails);

--  Cancelled orders missing a CancellationReason (should be 0 — BR-02 trigger enforced)
SELECT OrderID, Status, CancellationReason
FROM Orders
WHERE Status = 'Cancelled' AND (CancellationReason IS NULL OR TRIM(CancellationReason) = '');

--  Orders where TotalAmount doesn't match the sum of its line items (reconciliation check)
SELECT o.OrderID, o.TotalAmount AS OrderTotal, od_sum.LineItemTotal
FROM Orders o
JOIN (
    SELECT OrderID, SUM(LineTotal) AS LineItemTotal
    FROM OrderDetails
    GROUP BY OrderID
) od_sum ON o.OrderID = od_sum.OrderID
WHERE o.TotalAmount <> od_sum.LineItemTotal;

--  VIP flag consistency check — OrderPriority should always match the BR-01 rule
SELECT OrderID, TotalAmount, OrderPriority
FROM Orders
WHERE (TotalAmount > 1000 AND OrderPriority <> 'VIP')
   OR (TotalAmount <= 1000 AND OrderPriority <> 'Standard');



-- SECTION B: CUSTOMER ANALYSIS (JOIN + GROUP BY)


--  Total revenue and order count per customer
SELECT
    c.CustomerID,
    c.FirstName,
    c.LastName,
    COUNT(o.OrderID) AS TotalOrders,
    SUM(o.TotalAmount) AS TotalRevenue
FROM Customers c
JOIN Orders o ON c.CustomerID = o.CustomerID
GROUP BY c.CustomerID, c.FirstName, c.LastName
ORDER BY TotalRevenue DESC;

-- Customers grouped by order status (purchasing behavior view)
SELECT
    c.CustomerID,
    c.FirstName,
    c.LastName,
    o.Status,
    COUNT(*) AS OrderCount
FROM Customers c
JOIN Orders o ON c.CustomerID = o.CustomerID
GROUP BY c.CustomerID, c.FirstName, c.LastName, o.Status
ORDER BY c.CustomerID, o.Status;

--  Customers with more than one cancelled order (churn-risk candidates)
SELECT
    c.CustomerID,
    c.FirstName,
    c.LastName,
    COUNT(*) AS CancelledOrders
FROM Customers c
JOIN Orders o ON c.CustomerID = o.CustomerID
WHERE o.Status = 'Cancelled'
GROUP BY c.CustomerID, c.FirstName, c.LastName
HAVING COUNT(*) > 1;

--  Customers who have never placed an order (subquery — NOT IN)
SELECT CustomerID, FirstName, LastName
FROM Customers
WHERE CustomerID NOT IN (SELECT DISTINCT CustomerID FROM Orders);

-- Customers whose total spend is above the average customer spend (subquery — aggregate comparison)
SELECT
    c.CustomerID,
    c.FirstName,
    c.LastName,
    SUM(o.TotalAmount) AS TotalSpend
FROM Customers c
JOIN Orders o ON c.CustomerID = o.CustomerID
GROUP BY c.CustomerID, c.FirstName, c.LastName
HAVING SUM(o.TotalAmount) > (
    SELECT AVG(CustomerTotal)
    FROM (
        SELECT SUM(TotalAmount) AS CustomerTotal
        FROM Orders
        GROUP BY CustomerID
    ) AS customer_totals
);

-- SECTION C: ORDER & PRODUCT ANALYSIS (JOIN + GROUP BY + Subqueries)


--  Order counts and revenue by status (lifecycle snapshot)
SELECT
    Status,
    COUNT(*) AS OrderCount,
    SUM(TotalAmount) AS TotalValue
FROM Orders
GROUP BY Status
ORDER BY TotalValue DESC;

--VIP vs Standard order breakdown
SELECT
    OrderPriority,
    COUNT(*) AS OrderCount,
    SUM(TotalAmount) AS TotalValue,
    ROUND(AVG(TotalAmount), 2) AS AvgOrderValue
FROM Orders
GROUP BY OrderPriority;

--Best-selling products by quantity and revenue (JOIN across Products/OrderDetails)
SELECT
    p.ProductID,
    p.ProductName,
    SUM(od.Quantity) AS UnitsSold,
    SUM(od.LineTotal) AS Revenue
FROM Products p
JOIN OrderDetails od ON p.ProductID = od.ProductID
GROUP BY p.ProductID, p.ProductName
ORDER BY Revenue DESC;

-- Products that have never been ordered (subquery — candidates for promotion or delisting)
SELECT ProductID, ProductName
FROM Products
WHERE ProductID NOT IN (SELECT DISTINCT ProductID FROM OrderDetails);

--  Products priced above the category average (correlated subquery)
SELECT
    p.ProductName,
    p.CategoryID,
    p.UnitPrice
FROM Products p
WHERE p.UnitPrice > (
    SELECT AVG(p2.UnitPrice)
    FROM Products p2
    WHERE p2.CategoryID = p.CategoryID
);

-- Orders placed by each sales rep, with revenue generated (JOIN with Employees)
SELECT
    e.EmployeeID,
    e.FirstName,
    e.LastName,
    COUNT(o.OrderID) AS OrdersHandled,
    SUM(o.TotalAmount) AS RevenueGenerated
FROM Employees e
JOIN Orders o ON e.EmployeeID = o.EmployeeID
GROUP BY e.EmployeeID, e.FirstName, e.LastName
ORDER BY RevenueGenerated DESC;



--  TRANSACTION / PAYMENT ANALYSIS


-- Orders with a payment status mismatch — order says paid, but no successful transaction exists
SELECT o.OrderID, o.Status, o.TotalAmount
FROM Orders o
WHERE o.Status IN ('Shipped', 'Delivered')
  AND o.OrderID NOT IN (
      SELECT OrderID FROM Transactions WHERE PaymentStatus = 'Success'
  );

--  Revenue collected by payment method
SELECT
    PaymentMethod,
    COUNT(*) AS TransactionCount,
    SUM(Amount) AS TotalCollected
FROM Transactions
WHERE PaymentStatus = 'Success'
GROUP BY PaymentMethod
ORDER BY TotalCollected DESC;

--  Failed or pending payments needing follow-up (JOIN for customer contact info)
SELECT
    t.TransactionID,
    o.OrderID,
    c.FirstName,
    c.LastName,
    c.Email,
    t.PaymentStatus,
    t.Amount
FROM Transactions t
JOIN Orders o ON t.OrderID = o.OrderID
JOIN Customers c ON o.CustomerID = c.CustomerID
WHERE t.PaymentStatus IN ('Failed', 'Pending');