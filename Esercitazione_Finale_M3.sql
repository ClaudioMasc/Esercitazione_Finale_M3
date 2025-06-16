#Task 2

CREATE DATABASE ToysGroup;

USE ToysGroup;

CREATE TABLE Category (
    CategoryID INT PRIMARY KEY AUTO_INCREMENT,
    CategoryName VARCHAR(100) NOT NULL
);

CREATE TABLE Product (
    ProductID INT PRIMARY KEY AUTO_INCREMENT,
    ProductName VARCHAR(100) NOT NULL,
    Model VARCHAR(50),
    LaunchYear YEAR,
    CategoryID INT NOT NULL,
    FOREIGN KEY (CategoryID) REFERENCES Category(CategoryID)
);

CREATE TABLE Region (
    RegionID INT PRIMARY KEY AUTO_INCREMENT,
    RegionName VARCHAR(100) NOT NULL
);

CREATE TABLE Country (
    CountryID INT PRIMARY KEY AUTO_INCREMENT,
    CountryName VARCHAR(100) NOT NULL,
    ISOCode CHAR(3),
    RegionID INT NOT NULL,
    FOREIGN KEY (RegionID) REFERENCES Region(RegionID)
);

CREATE TABLE Sales (
    SaleID INT PRIMARY KEY AUTO_INCREMENT,
    SaleDate DATE NOT NULL,
    Quantity INT NOT NULL,
    UnitPrice DECIMAL(10,2) NOT NULL,
    ProductID INT NOT NULL,
    CountryID INT NOT NULL,
    FOREIGN KEY (ProductID) REFERENCES Product(ProductID),
    FOREIGN KEY (CountryID) REFERENCES Country(CountryID)
);

#Task 3 - popolo le tabelle all'interno del database

INSERT INTO Category (CategoryID, CategoryName) VALUES
(1, 'Bikes'),
(2, 'Clothing'),
(3, 'Accessories');

INSERT INTO Product (ProductID, ProductName, Model, LaunchYear, CategoryID) VALUES
(1, 'Bike-100', 'B100-X', 2021, 1),
(2, 'Bike-200', 'B200-Z', 2022, 1),
(3, 'Bike Glove M', 'GL-M',   2023, 2),
(4, 'Bike Glove L', 'GL-L',   2023, 2),
(5, 'Helmet Pro', 'HP-1',   2020, 3),
(6, 'Water Bottle', 'WB-700', 2021, 3);

INSERT INTO Region (RegionID, RegionName) VALUES
(1, 'WestEurope'),
(2, 'SouthEurope'),
(3, 'NorthAmerica');

INSERT INTO Country (CountryID, CountryName, ISOCode, RegionID) VALUES
(1, 'France', 'FRA', 1),
(2, 'Germany', 'DEU', 1),
(3, 'Italy', 'ITA', 2),
(4, 'Greece', 'GRC', 2),
(5, 'USA', 'USA', 3),
(6, 'Canada', 'CAN', 3),
(7, 'Spain', 'ESP', 2),
(8, 'Netherlands', 'NLD', 1);

INSERT INTO Sales (SaleID, ProductID, CountryID, SaleDate, Quantity, UnitPrice) VALUES
(1 , 1, 1, '2024-01-10',  5, 250.00),
(2 , 2, 2, '2024-01-15',  3, 450.00),
(3 , 3, 3, '2024-01-20', 10,  20.00),
(4 , 4, 4, '2024-02-01',  8,  25.00),
(5 , 5, 5, '2024-02-10',  2,  60.00),
(6 , 6, 6, '2024-02-18',  6,  10.00),
(7 , 3, 1, '2024-03-05',  4,  20.00),
(8 , 4, 7, '2024-03-10',  9,  25.00),
(9 , 5, 8, '2024-03-15',  1,  65.00),
(10, 6, 5, '2024-04-01', 10,   9.50),
(11, 2, 2, '2024-04-15',  2, 450.00),
(12, 1, 3, '2024-04-20',  1, 250.00);

#controllo le tabelle

SELECT * FROM Category;
SELECT * FROM Product;
SELECT * FROM Region;
SELECT * FROM Country;
SELECT * FROM Sales;

#Task 4

#Es. 1

SELECT CategoryID, 
COUNT(*) AS Duplicati
FROM Category
GROUP BY CategoryID
HAVING COUNT(*) > 1;

SELECT ProductID, 
COUNT(*) AS Duplicati
FROM Product
GROUP BY ProductID
HAVING COUNT(*) > 1;

SELECT RegionID, 
COUNT(*) AS Duplicati
FROM Region
GROUP BY RegionID
HAVING COUNT(*) > 1;

SELECT CountryID, 
COUNT(*) AS Duplicati
FROM Country
GROUP BY CountryID
HAVING COUNT(*) > 1;

SELECT SaleID, 
COUNT(*) AS Duplicati
FROM Sales
GROUP BY SaleID
HAVING COUNT(*) > 1;

#Es. 2

SELECT 
s.SaleID,
s.SaleDate,
p.ProductName,
c.CategoryName,
co.CountryName,
r.RegionName,
DATEDIFF(CURDATE(), s.SaleDate) > 180 AS Oltre180Giorni
FROM Sales s
JOIN Product p
ON s.ProductID = p.ProductID
JOIN Category c
ON p.CategoryID = c.CategoryID
JOIN Country co
ON s.CountryID = co.CountryID
JOIN Region r
ON co.RegionID = r.RegionID
ORDER BY s.SaleDate
;

#Es. 3

SELECT 
ProductID, 
SUM(Quantity) AS TotaleVenduto
FROM Sales
WHERE YEAR(SaleDate) = (
    SELECT 
    MAX(YEAR(SaleDate)) FROM Sales
)
GROUP BY ProductID
HAVING SUM(Quantity) > (
    SELECT AVG(SommaQuantita)
    FROM (
        SELECT SUM(Quantity) AS SommaQuantita
        FROM Sales
        WHERE YEAR(SaleDate) = (
            SELECT MAX(YEAR(SaleDate)) FROM Sales
        )
        GROUP BY ProductID
    ) AS MediaPerProdotto
);

#Es. 4

SELECT 
p.ProductID,
p.ProductName,
YEAR(s.SaleDate) AS Anno,
SUM(s.Quantity * s.UnitPrice) AS FatturatoTotale
FROM Sales s
JOIN Product p
ON s.ProductID = p.ProductID
GROUP BY ProductID, YEAR(s.SaleDate)
ORDER BY ProductID, Anno
;

#Es. 5

SELECT 
c.CountryName,
YEAR(s.SaleDate) AS Anno,
SUM(s.Quantity * s.UnitPrice) AS FatturatoTotale
FROM Sales s
JOIN Country c 
ON s.CountryID = c.CountryID
GROUP BY c.CountryName, YEAR(s.SaleDate)
ORDER BY Anno, FatturatoTotale DESC
;

#Es. 6

SELECT 
cat.CategoryName,
SUM(s.Quantity) AS TotaleVenduto
FROM Sales s
JOIN Product p 
ON s.ProductID = p.ProductID
JOIN Category cat 
ON p.CategoryID = cat.CategoryID
GROUP BY cat.CategoryName
ORDER BY TotaleVenduto DESC
;

#Es. 7

#variante 1
SELECT 
p.ProductID, 
p.ProductName
FROM Product p
LEFT JOIN Sales s 
ON p.ProductID = s.ProductID
WHERE s.SaleID IS NULL
;

#variante 2
SELECT 
ProductID, 
ProductName
FROM Product
WHERE ProductID NOT IN (
SELECT DISTINCT ProductID
FROM Sales
);

#Es. 8

CREATE VIEW v_ProductsInfo AS
SELECT 
p.ProductID,
p.ProductName,
c.CategoryName
FROM Product p
JOIN Category c 
ON p.CategoryID = c.CategoryID
;

SELECT * FROM v_ProductsInfo;

#Es. 9

CREATE VIEW vista_geografica AS
SELECT 
c.CountryID,
c.CountryName,
c.ISOCode,
r.RegionID,
r.RegionName
FROM Country c
JOIN Region r 
ON c.RegionID = r.RegionID
;

SELECT * FROM vista_geografica;
