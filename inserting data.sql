-- ===================================================================
-- Sample Data for sales_order_management
-- Run sales_order_management_schema.sql FIRST, then run this file.
-- Insert order follows FK dependencies: parents before children.
-- ===================================================================

USE sales_order_management;

-- -------------------------------------------------------------------
-- 1. Customers
-- -------------------------------------------------------------------
INSERT INTO Customers (FirstName, LastName, Email, Phone, Address, City, State, Country, JoinDate, CustomerSegment) VALUES
('Rohan', 'Sharma', 'rohan.sharma@example.com', '9876543210', '12 MG Road', 'Pune', 'Maharashtra', 'India', '2023-01-15', 'Retail'),
('Priya', 'Verma', 'priya.verma@example.com', '9876543211', '45 FC Road', 'Pune', 'Maharashtra', 'India', '2023-02-20', 'VIP'),
('Amit', 'Deshmukh', 'amit.deshmukh@example.com', '9876543212', '7 Baner Road', 'Pune', 'Maharashtra', 'India', '2023-03-05', 'Wholesale'),
('Sneha', 'Kulkarni', 'sneha.kulkarni@example.com', '9876543213', '22 Kothrud', 'Pune', 'Maharashtra', 'India', '2023-04-11', 'Retail'),
('Vikram', 'Joshi', 'vikram.joshi@example.com', '9876543214', '3 Aundh Road', 'Pune', 'Maharashtra', 'India', '2023-05-30', 'Retail'),
('Neha', 'Patil', 'neha.patil@example.com', '9876543215', '18 Wakad', 'Pune', 'Maharashtra', 'India', '2023-06-18', 'VIP'),
('Karan', 'Mehta', 'karan.mehta@example.com', '9876543216', '9 Hinjewadi', 'Pune', 'Maharashtra', 'India', '2023-07-22', 'Wholesale'),
('Anjali', 'Gupta', 'anjali.gupta@example.com', '9876543217', '30 Viman Nagar', 'Pune', 'Maharashtra', 'India', '2023-08-09', 'Retail');

-- -------------------------------------------------------------------
-- 2. Categories
-- -------------------------------------------------------------------
INSERT INTO Categories (CategoryName) VALUES
('Electronics'),
('Home Appliances'),
('Stationery'),
('Furniture');

-- -------------------------------------------------------------------
-- 3. Products
-- -------------------------------------------------------------------
INSERT INTO Products (ProductName, CategoryID, UnitPrice, StockQuantity, ReorderLevel, IsActive) VALUES
('Wireless Mouse', 1, 599.00, 150, 20, 1),
('Bluetooth Keyboard', 1, 1299.00, 80, 15, 1),
('LED Desk Lamp', 2, 899.00, 60, 10, 1),
('Electric Kettle', 2, 1499.00, 40, 10, 1),
('Notebook Pack (5pcs)', 3, 249.00, 300, 50, 1),
('Gel Pen Box (10pcs)', 3, 149.00, 400, 60, 1),
('Office Chair', 4, 5999.00, 25, 5, 1),
('Study Table', 4, 7499.00, 15, 5, 1);

-- -------------------------------------------------------------------
-- 4. Employees
-- -------------------------------------------------------------------
INSERT INTO Employees (FirstName, LastName, Role, Email) VALUES
('Rahul', 'Kadam', 'Sales Executive', 'rahul.kadam@company.com'),
('Pooja', 'Nair', 'Sales Executive', 'pooja.nair@company.com'),
('Sanjay', 'Rao', 'Sales Manager', 'sanjay.rao@company.com');

-- -------------------------------------------------------------------
-- 5. Orders
-- Note: OrderPriority is a generated column (auto-computed from
-- TotalAmount per BR-01) — do not insert a value for it.
-- CancellationReason is required whenever Status = 'Cancelled' (BR-02).
-- -------------------------------------------------------------------
INSERT INTO Orders (CustomerID, EmployeeID, OrderDate, ShipDate, Status, TotalAmount, CancellationReason) VALUES
(1, 1, '2024-01-05 10:15:00', '2024-01-07 12:00:00', 'Delivered', 1898.00, NULL),
(2, 2, '2024-01-10 11:30:00', '2024-01-12 09:00:00', 'Delivered', 6898.00, NULL),
(3, 1, '2024-01-18 14:45:00', NULL, 'Processing', 2998.00, NULL),
(4, 3, '2024-02-02 09:00:00', '2024-02-04 10:30:00', 'Delivered', 748.00, NULL),
(5, 2, '2024-02-14 16:20:00', NULL, 'Cancelled', 1499.00, 'Customer found a better price elsewhere'),
(1, 1, '2024-02-25 13:10:00', '2024-02-27 11:00:00', 'Delivered', 899.00, NULL),
(6, 3, '2024-03-03 10:00:00', NULL, 'Pending', 7499.00, NULL),
(7, 2, '2024-03-15 15:30:00', '2024-03-18 10:00:00', 'Delivered', 11998.00, NULL),
(8, 1, '2024-03-21 12:00:00', NULL, 'Shipped', 398.00, NULL);

-- -------------------------------------------------------------------
-- 6. OrderDetails
-- (LineTotal is a generated column — do not insert it directly)
-- -------------------------------------------------------------------
INSERT INTO OrderDetails (OrderID, ProductID, Quantity, UnitPrice, Discount) VALUES
(1, 1, 1, 599.00, 0),
(1, 5, 1, 249.00, 0),
(1, 6, 1, 149.00, 0),

(2, 2, 1, 1299.00, 0),
(2, 7, 1, 5999.00, 0),

(3, 3, 1, 899.00, 0),
(3, 4, 1, 1499.00, 0),
(3, 6, 4, 149.00, 5),

(4, 5, 2, 249.00, 0),
(4, 6, 1, 149.00, 0),

(5, 4, 1, 1499.00, 0),

(6, 3, 1, 899.00, 0),

(7, 8, 1, 7499.00, 0),

(8, 7, 2, 5999.00, 0),

(9, 5, 1, 249.00, 0),
(9, 6, 1, 149.00, 0);

-- -------------------------------------------------------------------
-- 7. Transactions
-- -------------------------------------------------------------------
INSERT INTO Transactions (OrderID, PaymentMethod, PaymentDate, Amount, PaymentStatus) VALUES
(1, 'UPI', '2024-01-05 10:20:00', 1898.00, 'Success'),
(2, 'Credit Card', '2024-01-10 11:35:00', 6898.00, 'Success'),
(3, 'Net Banking', '2024-01-18 14:50:00', 2998.00, 'Pending'),
(4, 'Debit Card', '2024-02-02 09:05:00', 748.00, 'Success'),
(5, 'UPI', '2024-02-14 16:25:00', 1499.00, 'Refunded'),
(6, 'Cash', '2024-02-25 13:15:00', 899.00, 'Success'),
(7, 'Credit Card', '2024-03-03 10:05:00', 7499.00, 'Pending'),
(8, 'UPI', '2024-03-15 15:35:00', 11998.00, 'Success'),
(9, 'Debit Card', '2024-03-21 12:05:00', 398.00, 'Failed');




-- Should FAIL with the BR-02 error message
INSERT INTO Orders (CustomerID, Status, TotalAmount)
VALUES (1, 'Cancelled', 500.00);

-- Should succeed, and OrderPriority will show 'VIP' automatically
INSERT INTO Orders (CustomerID, Status, TotalAmount)
VALUES (1, 'Pending', 1500.00);
SELECT OrderID, TotalAmount, OrderPriority FROM Orders ORDER BY OrderID DESC LIMIT 1;