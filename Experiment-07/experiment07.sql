-- =====================================================================
-- EXPERIMENT 07
-- Title: Database Normalization: UNF to 1NF, 2NF, 3NF, and BCNF
-- Aim: To normalize a denormalized Sales/Order dataset from Unnormalized Form
--      (UNF) through First Normal Form (1NF), Second Normal Form (2NF),
--      Third Normal Form (3NF), and Boyce-Codd Normal Form (BCNF),
--      eliminating insertion, update, and deletion anomalies while ensuring
--      lossless join and functional dependency preservation.
-- Student: Sayna Bhramer | UID: 25LBCS3252
-- DBMS: MySQL Server 8.0 / 9.x (Community Edition)
-- =====================================================================

-- Create and select the database
CREATE DATABASE IF NOT EXISTS sales_normalization_db;
USE sales_normalization_db;

-- =====================================================================
-- STEP 1: UNNORMALIZED FORM (UNF)
-- Contains non-atomic values (repeating item list in single cell)
-- =====================================================================

DROP TABLE IF EXISTS Sales_UNF;

CREATE TABLE Sales_UNF (
    OrderID INT,
    OrderDate DATE,
    CustomerID VARCHAR(10),
    CustomerName VARCHAR(60),
    CustomerCity VARCHAR(50),
    Items TEXT,  -- Multi-valued attribute: 'P01:Laptop:1:65000.00, P02:Mouse:2:650.00'
    SalesRep VARCHAR(60),
    StoreBranch VARCHAR(60)
);

INSERT INTO Sales_UNF VALUES
(1001, '2024-03-01', 'C01', 'Aarav Sharma', 'Delhi', 'P01:Laptop:1:65000.00, P02:Mouse:2:650.00', 'Vikram Sen', 'North Delhi'),
(1002, '2024-03-02', 'C02', 'Priya Patel', 'Mumbai', 'P01:Laptop:1:65000.00, P03:Keyboard:1:1200.00', 'Vikram Sen', 'North Delhi'),
(1003, '2024-03-02', 'C03', 'Rahul Verma', 'Delhi', 'P02:Mouse:1:650.00', 'Neha Mehta', 'South Extension'),
(1004, '2024-03-03', 'C01', 'Aarav Sharma', 'Delhi', 'P04:Headphones:2:2500.00, P05:Monitor:1:18000.00', 'Vikram Sen', 'North Delhi'),
(1005, '2024-03-04', 'C04', 'Sneha Nair', 'Bengaluru', 'P03:Keyboard:2:1200.00, P02:Mouse:1:650.00', 'Rohan Das', 'Connaught Place');

-- Display UNF Table
SELECT * FROM Sales_UNF;

-- =====================================================================
-- STEP 2: FIRST NORMAL FORM (1NF)
-- Rule: Atomic values per cell, no repeating groups, composite primary key.
-- Composite Primary Key: (OrderID, ProductID)
-- FDs present:
--   (OrderID, ProductID) -> Quantity
--   ProductID -> ProductName, UnitPrice               [PARTIAL DEPENDENCY]
--   OrderID -> OrderDate, CustomerID, SalesRep, StoreBranch [PARTIAL DEPENDENCY]
--   CustomerID -> CustomerName, CustomerCity           [TRANSITIVE DEPENDENCY]
--   SalesRep -> StoreBranch                            [TRANSITIVE DEPENDENCY]
-- =====================================================================

DROP TABLE IF EXISTS Sales_1NF;

CREATE TABLE Sales_1NF (
    OrderID INT,
    OrderDate DATE NOT NULL,
    CustomerID VARCHAR(10) NOT NULL,
    CustomerName VARCHAR(60) NOT NULL,
    CustomerCity VARCHAR(50) NOT NULL,
    ProductID VARCHAR(10) NOT NULL,
    ProductName VARCHAR(60) NOT NULL,
    Quantity INT NOT NULL CHECK (Quantity > 0),
    UnitPrice DECIMAL(10,2) NOT NULL CHECK (UnitPrice > 0),
    SalesRep VARCHAR(60) NOT NULL,
    StoreBranch VARCHAR(60) NOT NULL,
    PRIMARY KEY (OrderID, ProductID)
);

INSERT INTO Sales_1NF VALUES
(1001, '2024-03-01', 'C01', 'Aarav Sharma', 'Delhi', 'P01', 'Laptop', 1, 65000.00, 'Vikram Sen', 'North Delhi'),
(1001, '2024-03-01', 'C01', 'Aarav Sharma', 'Delhi', 'P02', 'Mouse', 2, 650.00, 'Vikram Sen', 'North Delhi'),
(1002, '2024-03-02', 'C02', 'Priya Patel', 'Mumbai', 'P01', 'Laptop', 1, 65000.00, 'Vikram Sen', 'North Delhi'),
(1002, '2024-03-02', 'C02', 'Priya Patel', 'Mumbai', 'P03', 'Keyboard', 1, 1200.00, 'Vikram Sen', 'North Delhi'),
(1003, '2024-03-02', 'C03', 'Rahul Verma', 'Delhi', 'P02', 'Mouse', 1, 650.00, 'Neha Mehta', 'South Extension'),
(1004, '2024-03-03', 'C01', 'Aarav Sharma', 'Delhi', 'P04', 'Headphones', 2, 2500.00, 'Vikram Sen', 'North Delhi'),
(1004, '2024-03-03', 'C01', 'Aarav Sharma', 'Delhi', 'P05', 'Monitor', 1, 18000.00, 'Vikram Sen', 'North Delhi'),
(1005, '2024-03-04', 'C04', 'Sneha Nair', 'Bengaluru', 'P03', 'Keyboard', 2, 1200.00, 'Rohan Das', 'Connaught Place'),
(1005, '2024-03-04', 'C04', 'Sneha Nair', 'Bengaluru', 'P02', 'Mouse', 1, 650.00, 'Rohan Das', 'Connaught Place');

-- Display 1NF Table
SELECT * FROM Sales_1NF;

-- =====================================================================
-- STEP 3: SECOND NORMAL FORM (2NF)
-- Rule: Must be in 1NF and have NO partial dependencies.
-- Decompose into:
--   1. Product_2NF (ProductID -> ProductName, UnitPrice)
--   2. Orders_2NF (OrderID -> OrderDate, CustomerID, CustomerName, CustomerCity, SalesRep, StoreBranch)
--   3. OrderItem_2NF ((OrderID, ProductID) -> Quantity)
-- =====================================================================

DROP TABLE IF EXISTS OrderItem_2NF;
DROP TABLE IF EXISTS Orders_2NF;
DROP TABLE IF EXISTS Product_2NF;

CREATE TABLE Product_2NF (
    ProductID VARCHAR(10) PRIMARY KEY,
    ProductName VARCHAR(60) NOT NULL,
    UnitPrice DECIMAL(10,2) NOT NULL CHECK (UnitPrice > 0)
);

CREATE TABLE Orders_2NF (
    OrderID INT PRIMARY KEY,
    OrderDate DATE NOT NULL,
    CustomerID VARCHAR(10) NOT NULL,
    CustomerName VARCHAR(60) NOT NULL,
    CustomerCity VARCHAR(50) NOT NULL,
    SalesRep VARCHAR(60) NOT NULL,
    StoreBranch VARCHAR(60) NOT NULL
);

CREATE TABLE OrderItem_2NF (
    OrderID INT NOT NULL,
    ProductID VARCHAR(10) NOT NULL,
    Quantity INT NOT NULL CHECK (Quantity > 0),
    PRIMARY KEY (OrderID, ProductID),
    FOREIGN KEY (OrderID) REFERENCES Orders_2NF(OrderID) ON DELETE CASCADE,
    FOREIGN KEY (ProductID) REFERENCES Product_2NF(ProductID) ON DELETE RESTRICT
);

-- Populate 2NF Tables
INSERT INTO Product_2NF (ProductID, ProductName, UnitPrice)
SELECT DISTINCT ProductID, ProductName, UnitPrice FROM Sales_1NF;

INSERT INTO Orders_2NF (OrderID, OrderDate, CustomerID, CustomerName, CustomerCity, SalesRep, StoreBranch)
SELECT DISTINCT OrderID, OrderDate, CustomerID, CustomerName, CustomerCity, SalesRep, StoreBranch FROM Sales_1NF;

INSERT INTO OrderItem_2NF (OrderID, ProductID, Quantity)
SELECT OrderID, ProductID, Quantity FROM Sales_1NF;

-- Display 2NF Tables
SELECT * FROM Product_2NF;
SELECT * FROM Orders_2NF;
SELECT * FROM OrderItem_2NF;

-- =====================================================================
-- STEP 4: THIRD NORMAL FORM (3NF)
-- Rule: Must be in 2NF and have NO transitive dependencies.
-- In Orders_2NF:
--   OrderID -> CustomerID
--   CustomerID -> CustomerName, CustomerCity  [TRANSITIVE]
-- Decompose Orders_2NF into:
--   1. Customer_3NF (CustomerID -> CustomerName, CustomerCity)
--   2. Orders_3NF (OrderID -> OrderDate, CustomerID, SalesRep, StoreBranch)
-- =====================================================================

DROP TABLE IF EXISTS OrderItem_3NF;
DROP TABLE IF EXISTS Orders_3NF;
DROP TABLE IF EXISTS Customer_3NF;
DROP TABLE IF EXISTS Product_3NF;

CREATE TABLE Customer_3NF (
    CustomerID VARCHAR(10) PRIMARY KEY,
    CustomerName VARCHAR(60) NOT NULL,
    CustomerCity VARCHAR(50) NOT NULL
);

CREATE TABLE Product_3NF (
    ProductID VARCHAR(10) PRIMARY KEY,
    ProductName VARCHAR(60) NOT NULL,
    UnitPrice DECIMAL(10,2) NOT NULL CHECK (UnitPrice > 0)
);

CREATE TABLE Orders_3NF (
    OrderID INT PRIMARY KEY,
    OrderDate DATE NOT NULL,
    CustomerID VARCHAR(10) NOT NULL,
    SalesRep VARCHAR(60) NOT NULL,
    StoreBranch VARCHAR(60) NOT NULL,
    FOREIGN KEY (CustomerID) REFERENCES Customer_3NF(CustomerID) ON DELETE RESTRICT
);

CREATE TABLE OrderItem_3NF (
    OrderID INT NOT NULL,
    ProductID VARCHAR(10) NOT NULL,
    Quantity INT NOT NULL CHECK (Quantity > 0),
    PRIMARY KEY (OrderID, ProductID),
    FOREIGN KEY (OrderID) REFERENCES Orders_3NF(OrderID) ON DELETE CASCADE,
    FOREIGN KEY (ProductID) REFERENCES Product_3NF(ProductID) ON DELETE RESTRICT
);

-- Populate 3NF Tables
INSERT INTO Customer_3NF (CustomerID, CustomerName, CustomerCity)
SELECT DISTINCT CustomerID, CustomerName, CustomerCity FROM Orders_2NF;

INSERT INTO Product_3NF (ProductID, ProductName, UnitPrice)
SELECT * FROM Product_2NF;

INSERT INTO Orders_3NF (OrderID, OrderDate, CustomerID, SalesRep, StoreBranch)
SELECT OrderID, OrderDate, CustomerID, SalesRep, StoreBranch FROM Orders_2NF;

INSERT INTO OrderItem_3NF (OrderID, ProductID, Quantity)
SELECT * FROM OrderItem_2NF;

-- Display 3NF Tables
SELECT * FROM Customer_3NF;
SELECT * FROM Orders_3NF;

-- =====================================================================
-- STEP 5: BOYCE-CODD NORMAL FORM (BCNF)
-- Rule: For every non-trivial functional dependency X -> Y, X must be a superkey.
-- In Orders_3NF, each sales representative is assigned to one unique branch:
--   SalesRep -> StoreBranch
-- But SalesRep is NOT a candidate key for Orders_3NF (OrderID is the PK).
-- Decompose Orders_3NF into:
--   1. SalesRepresentative_BCNF (SalesRep -> StoreBranch) [SalesRep is PK]
--   2. Orders_BCNF (OrderID -> OrderDate, CustomerID, SalesRep) [OrderID is PK]
-- =====================================================================

DROP TABLE IF EXISTS OrderItem_BCNF;
DROP TABLE IF EXISTS Orders_BCNF;
DROP TABLE IF EXISTS SalesRepresentative_BCNF;
DROP TABLE IF EXISTS Customer_BCNF;
DROP TABLE IF EXISTS Product_BCNF;

CREATE TABLE Customer_BCNF (
    CustomerID VARCHAR(10) PRIMARY KEY,
    CustomerName VARCHAR(60) NOT NULL,
    CustomerCity VARCHAR(50) NOT NULL
);

CREATE TABLE Product_BCNF (
    ProductID VARCHAR(10) PRIMARY KEY,
    ProductName VARCHAR(60) NOT NULL,
    UnitPrice DECIMAL(10,2) NOT NULL CHECK (UnitPrice > 0)
);

CREATE TABLE SalesRepresentative_BCNF (
    SalesRep VARCHAR(60) PRIMARY KEY,
    StoreBranch VARCHAR(60) NOT NULL
);

CREATE TABLE Orders_BCNF (
    OrderID INT PRIMARY KEY,
    OrderDate DATE NOT NULL,
    CustomerID VARCHAR(10) NOT NULL,
    SalesRep VARCHAR(60) NOT NULL,
    FOREIGN KEY (CustomerID) REFERENCES Customer_BCNF(CustomerID) ON DELETE RESTRICT,
    FOREIGN KEY (SalesRep) REFERENCES SalesRepresentative_BCNF(SalesRep) ON DELETE RESTRICT
);

CREATE TABLE OrderItem_BCNF (
    OrderID INT NOT NULL,
    ProductID VARCHAR(10) NOT NULL,
    Quantity INT NOT NULL CHECK (Quantity > 0),
    PRIMARY KEY (OrderID, ProductID),
    FOREIGN KEY (OrderID) REFERENCES Orders_BCNF(OrderID) ON DELETE CASCADE,
    FOREIGN KEY (ProductID) REFERENCES Product_BCNF(ProductID) ON DELETE RESTRICT
);

-- Populate BCNF Tables
INSERT INTO Customer_BCNF SELECT * FROM Customer_3NF;
INSERT INTO Product_BCNF SELECT * FROM Product_3NF;

INSERT INTO SalesRepresentative_BCNF (SalesRep, StoreBranch)
SELECT DISTINCT SalesRep, StoreBranch FROM Orders_3NF;

INSERT INTO Orders_BCNF (OrderID, OrderDate, CustomerID, SalesRep)
SELECT OrderID, OrderDate, CustomerID, SalesRep FROM Orders_3NF;

INSERT INTO OrderItem_BCNF SELECT * FROM OrderItem_3NF;

-- Display BCNF Tables
SELECT * FROM SalesRepresentative_BCNF;
SELECT * FROM Orders_BCNF;

-- =====================================================================
-- STEP 6: VERIFICATION OF LOSSLESS JOIN
-- Reconstructing the complete normalized database back to the original 1NF view
-- =====================================================================

SELECT 
    o.OrderID,
    o.OrderDate,
    c.CustomerID,
    c.CustomerName,
    c.CustomerCity,
    p.ProductID,
    p.ProductName,
    oi.Quantity,
    p.UnitPrice,
    (oi.Quantity * p.UnitPrice) AS LineTotal,
    sr.SalesRep,
    sr.StoreBranch
FROM Orders_BCNF o
JOIN Customer_BCNF c ON o.CustomerID = c.CustomerID
JOIN SalesRepresentative_BCNF sr ON o.SalesRep = sr.SalesRep
JOIN OrderItem_BCNF oi ON o.OrderID = oi.OrderID
JOIN Product_BCNF p ON oi.ProductID = p.ProductID
ORDER BY o.OrderID, p.ProductID;
