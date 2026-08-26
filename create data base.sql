-- ===================================================================
-- Sales Order Management & Customer Analytics System
-- MySQL Schema Creation Script
-- ===================================================================

CREATE DATABASE IF NOT EXISTS sales_order_management;
USE sales_order_management;

-- -------------------------------------------------------------------
-- 0. Clean slate: drop tables in reverse dependency order so re-running
--    this script never fails with "table already exists" or FK errors
-- -------------------------------------------------------------------
DROP TABLE IF EXISTS Transactions;
DROP TABLE IF EXISTS OrderDetails;
DROP TABLE IF EXISTS Orders;
DROP TABLE IF EXISTS Employees;
DROP TABLE IF EXISTS Products;
DROP TABLE IF EXISTS Categories;
DROP TABLE IF EXISTS Customers;

-- -------------------------------------------------------------------
-- 1. Customers
-- -------------------------------------------------------------------
CREATE TABLE Customers (
    CustomerID      INT AUTO_INCREMENT PRIMARY KEY,
    FirstName       VARCHAR(50)  NOT NULL,
    LastName        VARCHAR(50)  NOT NULL,
    Email           VARCHAR(100) UNIQUE NOT NULL,
    Phone           VARCHAR(20),
    Address         VARCHAR(150),
    City            VARCHAR(50),
    State           VARCHAR(50),
    Country         VARCHAR(50),
    JoinDate        DATE NOT NULL DEFAULT (CURRENT_DATE),
    CustomerSegment VARCHAR(30)  -- e.g. Retail, Wholesale, VIP
);

-- -------------------------------------------------------------------
-- 2. Product Categories
-- -------------------------------------------------------------------
CREATE TABLE Categories (
    CategoryID      INT AUTO_INCREMENT PRIMARY KEY,
    CategoryName    VARCHAR(50) NOT NULL UNIQUE
);

-- -------------------------------------------------------------------
-- 3. Products
-- -------------------------------------------------------------------
CREATE TABLE Products (
    ProductID       INT AUTO_INCREMENT PRIMARY KEY,
    ProductName     VARCHAR(100) NOT NULL,
    CategoryID      INT,
    UnitPrice       DECIMAL(10,2) NOT NULL,
    StockQuantity   INT NOT NULL DEFAULT 0,
    ReorderLevel    INT DEFAULT 10,
    IsActive        TINYINT(1) DEFAULT 1,
    FOREIGN KEY (CategoryID) REFERENCES Categories(CategoryID)
);

-- -------------------------------------------------------------------
-- 4. Employees / Sales Reps (who processed the order)
-- -------------------------------------------------------------------
CREATE TABLE Employees (
    EmployeeID      INT AUTO_INCREMENT PRIMARY KEY,
    FirstName       VARCHAR(50) NOT NULL,
    LastName        VARCHAR(50) NOT NULL,
    Role            VARCHAR(50),
    Email           VARCHAR(100) UNIQUE
);

-- -------------------------------------------------------------------
-- 5. Orders (Sales Order header)
-- -------------------------------------------------------------------
CREATE TABLE Orders (
    OrderID             INT AUTO_INCREMENT PRIMARY KEY,
    CustomerID          INT NOT NULL,
    EmployeeID          INT,
    OrderDate           DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    ShipDate            DATETIME,
    Status              ENUM('Pending','Processing','Shipped','Delivered','Cancelled') DEFAULT 'Pending',
    TotalAmount         DECIMAL(12,2) DEFAULT 0.00,
    -- BR-01: orders over 1000 automatically qualify for VIP processing
    OrderPriority       ENUM('Standard','VIP') GENERATED ALWAYS AS
                            (CASE WHEN TotalAmount > 1000 THEN 'VIP' ELSE 'Standard' END) STORED,
    -- BR-02: required whenever Status = 'Cancelled' (enforced by triggers below)
    CancellationReason  VARCHAR(255) NULL,
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID),
    FOREIGN KEY (EmployeeID) REFERENCES Employees(EmployeeID)
);

-- -------------------------------------------------------------------
-- 6. Order Details (line items — enables JOIN/GROUP BY analysis)
-- -------------------------------------------------------------------
CREATE TABLE OrderDetails (
    OrderDetailID   INT AUTO_INCREMENT PRIMARY KEY,
    OrderID         INT NOT NULL,
    ProductID       INT NOT NULL,
    Quantity        INT NOT NULL,
    UnitPrice       DECIMAL(10,2) NOT NULL,
    Discount        DECIMAL(5,2) DEFAULT 0.00,
    LineTotal       DECIMAL(12,2) GENERATED ALWAYS AS
                        (Quantity * UnitPrice * (1 - Discount/100)) STORED,
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID) ON DELETE CASCADE,
    FOREIGN KEY (ProductID) REFERENCES Products(ProductID)
);

-- -------------------------------------------------------------------
-- 7. Transactions / Payments (for defect/reconciliation testing)
-- -------------------------------------------------------------------
CREATE TABLE Transactions (
    TransactionID   INT AUTO_INCREMENT PRIMARY KEY,
    OrderID         INT NOT NULL,
    PaymentMethod   ENUM('Credit Card','Debit Card','Net Banking','UPI','Cash') NOT NULL,
    PaymentDate     DATETIME DEFAULT CURRENT_TIMESTAMP,
    Amount          DECIMAL(12,2) NOT NULL,
    PaymentStatus   ENUM('Success','Failed','Refunded','Pending') DEFAULT 'Pending',
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID)
);

-- -------------------------------------------------------------------
-- Helpful indexes for the JOIN / GROUP BY / Subquery analysis
-- mentioned in the project (customer, order, and transaction validation)
-- -------------------------------------------------------------------
CREATE INDEX idx_orders_customer ON Orders(CustomerID);
CREATE INDEX idx_orderdetails_order ON OrderDetails(OrderID);
CREATE INDEX idx_orderdetails_product ON OrderDetails(ProductID);
CREATE INDEX idx_transactions_order ON Transactions(OrderID);
CREATE INDEX idx_orders_date ON Orders(OrderDate);

-- -------------------------------------------------------------------
-- BR-02 enforcement: a cancelled order must have a CancellationReason
-- (OrderPriority for BR-01 is handled above as a generated column, so
-- it never needs a trigger — it's always in sync with TotalAmount)
-- -------------------------------------------------------------------
DROP TRIGGER IF EXISTS trg_orders_cancel_reason_insert;
DROP TRIGGER IF EXISTS trg_orders_cancel_reason_update;

DELIMITER $$

CREATE TRIGGER trg_orders_cancel_reason_insert
BEFORE INSERT ON Orders
FOR EACH ROW
BEGIN
    IF NEW.Status = 'Cancelled'
       AND (NEW.CancellationReason IS NULL OR TRIM(NEW.CancellationReason) = '') THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'BR-02 violation: CancellationReason is required when Status is Cancelled';
    END IF;
END$$

CREATE TRIGGER trg_orders_cancel_reason_update
BEFORE UPDATE ON Orders
FOR EACH ROW
BEGIN
    IF NEW.Status = 'Cancelled'
       AND (NEW.CancellationReason IS NULL OR TRIM(NEW.CancellationReason) = '') THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'BR-02 violation: CancellationReason is required when Status is Cancelled';
    END IF;
END$$

DELIMITER ;