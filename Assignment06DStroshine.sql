--*************************************************************************--
-- Title: Assignment06
-- Author: Dayana Stroshine
-- Desc: This file demonstrates how to use Views
-- Change Log: August 29, 2021,Dayana Stroshine,Assignment 6
-- 2017-01-01,Dayana Stroshine,Created File
--**************************************************************************--
Begin Try
	Use Master;
	If Exists(Select Name From SysDatabases Where Name = 'Assignment06DB_DStroshine')
	 Begin 
	  Alter Database [Assignment06DB_DStroshine] set Single_user With Rollback Immediate;
	  Drop Database Assignment06DB_DStroshine;
	 End
	Create Database Assignment06DB_DStroshine;
End Try
Begin Catch
	Print Error_Number();
End Catch
go
Use Assignment06DB_DStroshine;

-- Create Tables (Module 01)-- 
Create Table Categories
([CategoryID] [int] IDENTITY(1,1) NOT NULL 
,[CategoryName] [nvarchar](100) NOT NULL
);
go

Create Table Products
([ProductID] [int] IDENTITY(1,1) NOT NULL 
,[ProductName] [nvarchar](100) NOT NULL 
,[CategoryID] [int] NULL  
,[UnitPrice] [mOney] NOT NULL
);
go

Create Table Employees -- New Table
([EmployeeID] [int] IDENTITY(1,1) NOT NULL 
,[EmployeeFirstName] [nvarchar](100) NOT NULL
,[EmployeeLastName] [nvarchar](100) NOT NULL 
,[ManagerID] [int] NULL  
);
go

Create Table Inventories
([InventoryID] [int] IDENTITY(1,1) NOT NULL
,[InventoryDate] [Date] NOT NULL
,[EmployeeID] [int] NOT NULL -- New Column
,[ProductID] [int] NOT NULL
,[Count] [int] NOT NULL
);
go

-- Add Constraints (Module 02) -- 
Begin  -- Categories
	Alter Table Categories 
	 Add Constraint pkCategories 
	  Primary Key (CategoryId);

	Alter Table Categories 
	 Add Constraint ukCategories 
	  Unique (CategoryName);
End
go 

Begin -- Products
	Alter Table Products 
	 Add Constraint pkProducts 
	  Primary Key (ProductId);

	Alter Table Products 
	 Add Constraint ukProducts 
	  Unique (ProductName);

	Alter Table Products 
	 Add Constraint fkProductsToCategories 
	  Foreign Key (CategoryId) References Categories(CategoryId);

	Alter Table Products 
	 Add Constraint ckProductUnitPriceZeroOrHigher 
	  Check (UnitPrice >= 0);
End
go

Begin -- Employees
	Alter Table Employees
	 Add Constraint pkEmployees 
	  Primary Key (EmployeeId);

	Alter Table Employees 
	 Add Constraint fkEmployeesToEmployeesManager 
	  Foreign Key (ManagerId) References Employees(EmployeeId);
End
go

Begin -- Inventories
	Alter Table Inventories 
	 Add Constraint pkInventories 
	  Primary Key (InventoryId);

	Alter Table Inventories
	 Add Constraint dfInventoryDate
	  Default GetDate() For InventoryDate;

	Alter Table Inventories
	 Add Constraint fkInventoriesToProducts
	  Foreign Key (ProductId) References Products(ProductId);

	Alter Table Inventories 
	 Add Constraint ckInventoryCountZeroOrHigher 
	  Check ([Count] >= 0);

	Alter Table Inventories
	 Add Constraint fkInventoriesToEmployees
	  Foreign Key (EmployeeId) References Employees(EmployeeId);
End 
go

-- Adding Data (Module 04) -- 
Insert Into Categories 
(CategoryName)
Select CategoryName 
 From Northwind.dbo.Categories
 Order By CategoryID;
go

Insert Into Products
(ProductName, CategoryID, UnitPrice)
Select ProductName,CategoryID, UnitPrice 
 From Northwind.dbo.Products
  Order By ProductID;
go

Insert Into Employees
(EmployeeFirstName, EmployeeLastName, ManagerID)
Select E.FirstName, E.LastName, IsNull(E.ReportsTo, E.EmployeeID) 
 From Northwind.dbo.Employees as E
  Order By E.EmployeeID;
go

Insert Into Inventories
(InventoryDate, EmployeeID, ProductID, [Count])
Select '20170101' as InventoryDate, 5 as EmployeeID, ProductID, ABS(CHECKSUM(NewId())) % 100 as RandomValue
From Northwind.dbo.Products
Union
Select '20170201' as InventoryDate, 7 as EmployeeID, ProductID, ABS(CHECKSUM(NewId())) % 100 as RandomValue
From Northwind.dbo.Products
Union
Select '20170301' as InventoryDate, 9 as EmployeeID, ProductID, ABS(CHECKSUM(NewId())) % 100 as RandomValue
From Northwind.dbo.Products
Order By 1, 2
go

-- Show the Current data in the Categories, Products, and Inventories Tables
Select * From Categories;
go
Select * From Products;
go
Select * From Employees;
go
Select * From Inventories;
go

/********************************* Questions and Answers ********************************
'NOTES------------------------------------------------------------------------------------ 
 1) You can use any name you like for you views, but be descriptive and consistent
 2) You can use your working code from assignment 5 for much of this assignment
 3) You must use the BASIC views for each table after they are created in Question 1
------------------------------------------------------------------------------------------'
*****************************************************************************************/

-- Question 1 (5% pts): How can you create BACIC views to show data from each table in the database.
-- NOTES: 1) Do not use a *, list out each column!
--        2) Create one view per table!
--		  3) Use SchemaBinding to protect the views from being orphaned!

-- Create Categories View
CREATE -- Drop
VIEW vCategories
WITH SCHEMABINDING 
AS 
  SELECT 
    CategoryID
   ,CategoryName
   FROM dbo.Categories
GO
-- Create Employees View
CREATE -- Drop
VIEW vEmployees
WITH SCHEMABINDING
AS 
  SELECT 
    EmployeeID
   ,EmployeeFirstName
   ,EmployeeLastName
   ,ManagerID
   FROM dbo.Employees
GO
-- Create Inventories View
CREATE -- Drop
VIEW vInventories
WITH SCHEMABINDING
AS 
  SELECT 
    InventoryID
   ,InventoryDate
   ,EmployeeID
   ,ProductID
   ,Count
   FROM dbo.Inventories
GO
-- Create Products View
CREATE -- Drop
VIEW vProducts
WITH SCHEMABINDING
AS 
  SELECT 
    ProductID
   ,ProductName
   ,CategoryID
   ,UnitPrice
   FROM dbo.Products
GO
/*******************************************************************************************************************************/
-- Question 2 (5% pts): How can you set permissions, so that the public group CANNOT select data 
-- from each table, but can select data from each view?

-- Deny Public access to categories table. Allow public access to categories view 
USE Assignment06DB_DStroshine;
DENY SELECT ON Categories TO Public;
GRANT SELECT ON vCategories TO Public;
GO
-- Deny Public access to employees table. Allow public access to employees view 
USE Assignment06DB_DStroshine;
DENY Select ON Employees TO Public;
GRANT Select ON vEmployees TO Public;
GO 
-- Deny Public access to inventories table. Allow public access to inventories view 
USE Assignment06DB_DStroshine;
DENY Select ON Inventories TO Public;
GRANT Select ON vInventories TO Public;
GO 
-- Deny Public access to products table. Allow public access to products view 
USE Assignment06DB_DStroshine;
DENY Select ON Products TO Public;
GRANT Select ON vProducts TO Public;
GO
/*******************************************************************************************************************************/
-- Question 3 (10% pts): How can you create a view to show a list of Category and Product names, 
-- and the price of each product?
-- Order the result by the Category and Product!

-- Create view to show products by categories
CREATE -- Drop
VIEW vProductsByCategories
AS 
  SELECT TOP 1000000000  
    CategoryName
   ,ProductName
   ,CAST(UnitPrice AS DECIMAL (10,2)) AS UnitPrice
  FROM vCategories AS c
  JOIN vProducts AS p
    ON c.CategoryID = p.CategoryID
  ORDER BY CategoryName,ProductName
GO
/*******************************************************************************************************************************/
-- Question 4 (10% pts): How can you create a view to show a list of Product names 
-- and Inventory Counts on each Inventory Date?
-- Order the results by the Product, Date, and Count!

-- Create view to show inventory by products and date
CREATE -- Drop
VIEW vInventoriesByProductsByDates
AS 
  SELECT TOP 1000000000  
    ProductName
   ,InventoryDate
   ,Count
  FROM vProducts AS p
  JOIN vInventories AS i 
    ON p.ProductID = i.ProductID
  ORDER BY ProductName, InventoryDate, Count
GO
/*******************************************************************************************************************************/
-- Question 5 (10% pts): How can you create a view to show a list of Inventory Dates 
-- and the Employee that took the count?
-- Order the results by the Date and return only one row per date!

-- Create view to show inventories by employee by date
-- Query reused from Assignment 5, Question 3
CREATE -- Drop
VIEW vInventoriesByEmployeesByDates
AS 
  SELECT TOP 1000000000  
    InventoryDate
    ,EmployeeName
  FROM
    (SELECT 
       InventoryDate
      ,EmployeeID
      ,SUM(Count) AS CountTotal
    FROM vInventories
    GROUP BY InventoryDate, EmployeeID
    ) AS i 
  JOIN 
    (SELECT 
       CONCAT(EmployeeFirstName,' ',EmployeeLastName) AS EmployeeName
      ,EmployeeID 
    FROM vEmployees
    ) AS e 
  ON i.EmployeeID = e.EmployeeID
ORDER BY InventoryDate;
GO
/*******************************************************************************************************************************/
-- Question 6 (10% pts): How can you create a view show a list of Categories, Products, 
-- and the Inventory Date and Count of each product?
-- Order the results by the Category, Product, Date, and Count!

-- Create view to show inventories by products by categories
-- Query reused from Assignment 5, Question 4
CREATE -- Drop
VIEW vInventoriesByProductsByCategories
AS 
  SELECT TOP 1000000000  
     CategoryName 
    ,ProductName
    ,InventoryDate
    ,Count
  FROM vCategories AS c 
  JOIN vProducts AS p 
    ON c.CategoryID = p.CategoryID
  JOIN vInventories AS i 
    ON p.ProductID = i.ProductID
ORDER BY 1,2,3,4;
GO
/*******************************************************************************************************************************/
-- Question 7 (10% pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the EMPLOYEE who took the count?
-- Order the results by the Inventory Date, Category, Product and Employee!

-- Create view to show inventories by products by employees
-- Query reused from Assignment 5, Question 5
CREATE -- Drop
VIEW vInventoriesByProductsByEmployees
AS 
  SELECT TOP 1000000000 
    CategoryName
    ,ProductName
    ,InventoryDate
    ,Count 
    ,CONCAT(EmployeeFirstName,' ',EmployeeLastName) AS EmployeeName
  FROM vCategories AS c 
  JOIN vProducts AS p 
    ON c.CategoryID = p.CategoryID
  JOIN vInventories AS i 
    ON p.ProductID = i.ProductID
  JOIN vEmployees AS e 
    ON i.EmployeeID = e.EmployeeID
  ORDER BY 3,1,2,5
GO
/*******************************************************************************************************************************/
-- Question 8 (10% pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the Employee who took the count
-- for the Products 'Chai' and 'Chang'? 

-- Create view to show inventories by products Chai and Chang by employees
-- Query reused from Assignment 5, Question 6
CREATE -- Drop
VIEW vInventoriesForChaiAndChangByEmployees
AS 
  SELECT TOP 1000000000
     CategoryName
    ,ProductName
    ,InventoryDate
    ,Count 
    ,CONCAT(EmployeeFirstName,' ',EmployeeLastName) AS EmployeeName
  FROM vCategories AS c 
  JOIN 
    (SELECT 
       ProductID
      ,ProductName
      ,CategoryID 
    FROM vProducts 
    WHERE ProductName IN ('Chai','Chang')
    ) AS p 
      ON c.CategoryID = p.CategoryID
  JOIN vInventories AS i 
    ON p.ProductID = i.ProductID
  JOIN vEmployees AS e 
    ON i.EmployeeID = e.EmployeeID
  ORDER BY 3,1,2
GO
/*******************************************************************************************************************************/
-- Question 9 (10% pts): How can you create a view to show a list of Employees and the Manager who manages them?
-- Order the results by the Manager's name!

/*
-- SHOW WORK
SELECT * FROM vEmployees;
GO
-- create a reports to column using managerID and self-joining that field to employeeID
SELECT 
   e.ManagerID as ReportsTo
  ,CONCAT(m.EmployeeFirstName,' ',m.EmployeeLastName) AS Manager
  ,CONCAT(e.EmployeeFirstName,' ',e.EmployeeLastName) AS Employee
FROM vEmployees AS e 
JOIN vEmployees AS m 
  ON e.managerID = m.employeeID 
GO
 -- select only needed fields and order by manager
SELECT 
   CONCAT(m.EmployeeFirstName,' ',m.EmployeeLastName) AS Manager
  ,CONCAT(e.EmployeeFirstName,' ',e.EmployeeLastName) AS Employee
FROM vEmployees AS e 
JOIN vEmployees AS m 
  ON e.managerID = m.employeeID
ORDER BY 1,2 
GO
*/

-- Create view to show employees by manager
CREATE -- Drop
VIEW vEmployeesByManager
AS 
  SELECT TOP 1000000000
     CONCAT(m.EmployeeFirstName,' ',m.EmployeeLastName) AS Manager
    ,CONCAT(e.EmployeeFirstName,' ',e.EmployeeLastName) AS Employee
  FROM vEmployees AS e 
  JOIN vEmployees AS m 
    ON e.managerID = m.employeeID
  ORDER BY 1,2 
GO
/*******************************************************************************************************************************/
-- Question 10 (20% pts): How can you create one view to show all the data from all four 
-- BASIC Views? Also show the Employee's Manager Name and order the data by 
-- Category, Product, InventoryID, and Employee.

/*
-- SHOW WORK
-- create employee qubquery to get employeeID and manager
SELECT 
   e.EmployeeID
  ,CONCAT(e.EmployeeFirstName,' ',e.EmployeeLastName) AS Employee
  ,CONCAT(m.EmployeeFirstName,' ',m.EmployeeLastName) AS Manager
FROM vEmployees AS e 
JOIN vEmployees AS m 
  ON e.managerID = m.employeeID
GO
-- bring all views and subqueries together
-- order by category, product, inventoryID, and employee
SELECT
   c.CategoryID
  ,CategoryName
  ,p.ProductID
  ,ProductName
  ,UnitPrice
  ,InventoryID
  ,InventoryDate
  ,Count
  ,e.EmployeeID
  ,Employee
  ,Manager
FROM vCategories AS c 
JOIN vProducts AS p 
  ON c.CategoryID = p.CategoryID
JOIN vInventories AS i 
  ON p.ProductID = i.ProductID
JOIN 
   (SELECT 
     e.EmployeeID
    ,CONCAT(e.EmployeeFirstName,' ',e.EmployeeLastName) AS Employee
    ,CONCAT(m.EmployeeFirstName,' ',m.EmployeeLastName) AS Manager
    FROM vEmployees AS e 
    JOIN vEmployees AS m 
    ON e.managerID = m.employeeID) e 
  ON i.EmployeeID = e.EmployeeID
ORDER BY CategoryID, ProductID, InventoryID, EmployeeID
GO
*/

-- Create view to show inventories by products by categories by employees
CREATE -- Drop
VIEW vInventoriesByProductsByCategoriesByEmployees
AS 
  SELECT TOP 1000000000
    c.CategoryID
    ,CategoryName
    ,p.ProductID
    ,ProductName
    ,CAST(UnitPrice AS DECIMAL(10,2)) AS UnitPrice
    ,InventoryID
    ,InventoryDate
    ,Count
    ,e.EmployeeID
    ,Employee
    ,Manager
  FROM vCategories AS c 
  JOIN vProducts AS p 
    ON c.CategoryID = p.CategoryID
  JOIN vInventories AS i 
    ON p.ProductID = i.ProductID
  JOIN 
   (SELECT 
      e.EmployeeID
      ,CONCAT(e.EmployeeFirstName,' ',e.EmployeeLastName) AS Employee
      ,CONCAT(m.EmployeeFirstName,' ',m.EmployeeLastName) AS Manager
    FROM vEmployees AS e 
    JOIN vEmployees AS m 
      ON e.managerID = m.employeeID
    ) AS e 
    ON i.EmployeeID = e.EmployeeID
  ORDER BY CategoryID, ProductID, InventoryID, EmployeeID
  GO
/*******************************************************************************************************************************/
-- Test your Views (NOTE: You must change the names to match yours as needed!)
Select * From [dbo].[vCategories]
Select * From [dbo].[vProducts]
Select * From [dbo].[vInventories]
Select * From [dbo].[vEmployees]

Select * From [dbo].[vProductsByCategories]
-- Here is an example of some rows selected from the view:
-- CategoryName,ProductName,UnitPrice
-- Beverages,Chai,18.00
-- Beverages,Chang,19.00
-- Beverages,Chartreuse verte,18.00

Select * From [dbo].[vInventoriesByProductsByDates]
-- Here is an example of some rows selected from the view:
--ProductName,InventoryDate,Count
--Alice Mutton,2017-01-01,15
--Alice Mutton,2017-02-01,78
--Alice Mutton,2017-03-01,83

Select * From [dbo].[vInventoriesByEmployeesByDates]
-- Here is an example of some rows selected from the view:
-- InventoryDate,EmployeeName
-- 2017-01-01,Steven Buchanan
-- 2017-02-01,Robert King
-- 2017-03-01,Anne Dodsworth

Select * From [dbo].[vInventoriesByProductsByCategories]
-- Here is an example of some rows selected from the view:
-- CategoryName,ProductName,InventoryDate,Count
-- Beverages,Chai,2017-01-01,72
-- Beverages,Chai,2017-02-01,52
-- Beverages,Chai,2017-03-01,54

Select * From [dbo].[vInventoriesByProductsByEmployees]
-- Here is an example of some rows selected from the view:
-- CategoryName,ProductName,InventoryDate,Count,EmployeeName
-- Beverages,Chai,2017-01-01,72,Steven Buchanan
-- Beverages,Chang,2017-01-01,46,Steven Buchanan
-- Beverages,Chartreuse verte,2017-01-01,61,Steven Buchanan

Select * From [dbo].[vInventoriesForChaiAndChangByEmployees]
-- Here is an example of some rows selected from the view:
-- CategoryName,ProductName,InventoryDate,Count,EmployeeName
-- Beverages,Chai,2017-01-01,72,Steven Buchanan
-- Beverages,Chang,2017-01-01,46,Steven Buchanan
-- Beverages,Chai,2017-02-01,52,Robert King

Select * From [dbo].[vEmployeesByManager]
-- Here is an example of some rows selected from the view:
-- Manager,Employee
-- Andrew Fuller,Andrew Fuller
-- Andrew Fuller,Janet Leverling
-- Andrew Fuller,Laura Callahan

Select * From [dbo].[vInventoriesByProductsByCategoriesByEmployees]
-- Here is an example of some rows selected from the view:
-- CategoryID,CategoryName,ProductID,ProductName,UnitPrice,InventoryID,InventoryDate,Count,EmployeeID,Employee,Manager
--1	Beverages	1	Chai	18.00	1	2017-01-01	19	5	Steven Buchanan	Andrew Fuller
--1	Beverages	1	Chai	18.00	78	2017-02-01	1	7	Robert King	Steven Buchanan
--1	Beverages	1	Chai	18.00	155	2017-03-01	94	9	Anne Dodsworth	Steven Buchanan
--1	Beverages	2	Chang	19.00	2	2017-01-01	17	5	Steven Buchanan	Andrew Fuller
--1	Beverages	2	Chang	19.00	79	2017-02-01	79	7	Robert King	Steven Buchanan
--1	Beverages	2	Chang	19.00	156	2017-03-01	37	9	Anne Dodsworth	Steven Buchanan
--1	Beverages	24	Guaran� Fant�stica	4.50	24	2017-01-01	0	5	Steven Buchanan	Andrew Fuller
--1	Beverages	24	Guaran� Fant�stica	4.50	101	2017-02-01	79	7	Robert King	Steven Buchanan
--1	Beverages	24	Guaran� Fant�stica	4.50	178	2017-03-01	28	9	Anne Dodsworth	Steven Buchanan
--1	Beverages	34	Sasquatch Ale	14.00	34	2017-01-01	5	5	Steven Buchanan	Andrew Fuller
--1	Beverages	34	Sasquatch Ale	14.00	111	2017-02-01	64	7	Robert King	Steven Buchanan
--1	Beverages	34	Sasquatch Ale	14.00	188	2017-03-01	86	9	Anne Dodsworth	Steven Buchanan
--1	Beverages	35	Steeleye Stout	18.00	35	2017-01-01	81	5	Steven Buchanan	Andrew Fuller
--1	Beverages	35	Steeleye Stout	18.00	112	2017-02-01	41	7	Robert King	Steven Buchanan
--1	Beverages	35	Steeleye Stout	18.00	189	2017-03-01	3	9	Anne Dodsworth	Steven Buchanan
--1	Beverages	38	C�te de Blaye	263.50	38	2017-01-01	49	5	Steven Buchanan	Andrew Fuller
--1	Beverages	38	C�te de Blaye	263.50	115	2017-02-01	62	7	Robert King	Steven Buchanan
--1	Beverages	38	C�te de Blaye	263.50	192	2017-03-01	92	9	Anne Dodsworth	Steven Buchanan
--1	Beverages	39	Chartreuse verte	18.00	39	2017-01-01	11	5	Steven Buchanan	Andrew Fuller
/*******************************************************************************************************************************/