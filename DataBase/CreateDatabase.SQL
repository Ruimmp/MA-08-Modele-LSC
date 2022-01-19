-- CreaDb.SQL
-- Date: Aug 2017
-- Author: X. Carrel
-- Goal: Creates the ECommerce DB
--       If the DB already exists, it is destroyed and recreated
--       The data directory C:\DATA\MSSQL is created if it doesn't exist

USE master
GO

-- First delete the database if it exists
IF (EXISTS (SELECT name FROM master.dbo.sysdatabases WHERE name = 'ECommerce'))
BEGIN
	USE master
	ALTER DATABASE ECommerce SET SINGLE_USER WITH ROLLBACK IMMEDIATE; -- Disconnect users the hard way (we cannot drop the db if someone's connected)
	DROP DATABASE ECommerce -- Destroy it
END
GO

-- Second ensure we have the proper directory structure
CREATE TABLE #ResultSet (Directory varchar(200)) -- Temporary table (name starts with #) -> will be automatically destroyed at the end of the session

INSERT INTO #ResultSet EXEC master.sys.xp_subdirs 'c:\' -- Stored procedure that lists subdirectories

IF NOT EXISTS (Select * FROM #ResultSet where Directory = 'DATA')
	EXEC master.sys.xp_create_subdir 'C:\DATA\' -- create DATA

DELETE FROM #ResultSet -- start over for MSSQL subdir
INSERT INTO #ResultSet EXEC master.sys.xp_subdirs 'c:\DATA'

IF NOT EXISTS (Select * FROM #ResultSet where Directory = 'MSSQL')
	EXEC master.sys.xp_create_subdir 'C:\DATA\MSSQL'

DROP TABLE #ResultSet -- Explicitely delete it because the script may be executed multiple times during the same session
GO

-- Everything is ready, we can create the db
CREATE DATABASE ECommerce ON  PRIMARY 
( NAME = 'ECommerce_data', FILENAME = 'C:\DATA\MSSQL\ECommerce.mdf' , SIZE = 20480KB , MAXSIZE = 51200KB , FILEGROWTH = 1024KB )
 LOG ON 
( NAME = 'ECommerce_log', FILENAME = 'C:\DATA\MSSQL\ECommerce.ldf' , SIZE = 10240KB , MAXSIZE = 20480KB , FILEGROWTH = 1024KB )

GO

-- CreaTables.SQL
-- Date: 11.9.2012
-- Author: X. Carrel
-- Goal: Create all tables of the ECommerce database

USE ECommerce
GO

-- Tables

CREATE TABLE Categories(
	id int IDENTITY(1,1) NOT NULL PRIMARY KEY,
	CategoryName varchar(15) UNIQUE NOT NULL)

CREATE TABLE Customers(
	id int IDENTITY(1,1) NOT NULL PRIMARY KEY,
	Number int UNIQUE,
	FirstName varchar(50) NOT NULL,
	LastName varchar(50) NOT NULL,
	EnrolmentDate date NOT NULL,
	Category_id int NOT NULL)

CREATE TABLE Products(
	id int IDENTITY(1,1) NOT NULL PRIMARY KEY,
	Number int UNIQUE,
	Brand varchar(50) NOT NULL,
	Model varchar(50) NOT NULL,
	ProductDescription text,
	Price int NOT NULL,
	Stock int NOT NULL)

CREATE TABLE OrderStates(
	id int IDENTITY(1,1) NOT NULL PRIMARY KEY,
	Name varchar(15) UNIQUE NOT NULL)

CREATE TABLE Orders(
	id int IDENTITY(1,1) NOT NULL PRIMARY KEY,
	Number int UNIQUE,
	Customer_id int NOT NULL,
	OrderDate date NOT NULL,
	OrderState_id int NOT NULL)

CREATE TABLE Reference(
	id int IDENTITY(1,1) NOT NULL PRIMARY KEY,
	Order_id int NOT NULL,
	Product_id int NOT NULL,
	Quantity int NOT NULL)

CREATE TABLE Offers(
	id int IDENTITY(1,1) NOT NULL PRIMARY KEY,
	OfferTitle varchar(50) NOT NULL,
	OfferYear int,
	Discount int NOT NULL)

CREATE TABLE Benefit(
	id int IDENTITY(1,1) NOT NULL PRIMARY KEY,
	Customer_id int NOT NULL,
	Offer_id int NOT NULL)
	
-- Contraintes référentielles

ALTER TABLE Customers WITH CHECK ADD  CONSTRAINT FK_Customer_Category FOREIGN KEY(Category_id)
REFERENCES Categories(id)

ALTER TABLE Orders WITH CHECK ADD  CONSTRAINT FK_CustomerOrder_Customer FOREIGN KEY(Customer_id)
REFERENCES Customers(id)

ALTER TABLE Orders WITH CHECK ADD  CONSTRAINT FK_OrderState FOREIGN KEY(OrderState_id)
REFERENCES OrderStates(id)

ALTER TABLE Reference WITH CHECK ADD  CONSTRAINT FK_OrderLine_Order FOREIGN KEY(Order_id)
REFERENCES Orders(id)

ALTER TABLE Reference WITH CHECK ADD  CONSTRAINT FK_Order_Product FOREIGN KEY(Product_id)
REFERENCES Products(id)

ALTER TABLE Benefit WITH CHECK ADD  CONSTRAINT FK_CustomerOffer_Customer FOREIGN KEY(Customer_id)
REFERENCES Customers(id)

ALTER TABLE Benefit WITH CHECK ADD  CONSTRAINT FK_CustomerOffer_Offer FOREIGN KEY(Offer_id)
REFERENCES Offers(id)

-- Natural identifiers

CREATE UNIQUE NONCLUSTERED INDEX UniqueOffer ON Offers (OfferTitle,OfferYear)

GO


-- CreaData.SQL
-- Date: Aug 2017
-- Author: X. Carrel
-- Goal: Insert data in ECommerce db

INSERT INTO Categories(CategoryName) VALUES ('Standard'),('Gold'),('Platine')

INSERT INTO OrderStates (Name) VALUES ('Nouvelle'),('En préparation'),('Expédiée'),('Terminée')

INSERT INTO Offers (OfferTitle,OfferYear, Discount) VALUES ('Bienvenue',2018,5),('Passage Gold',2018,10),('Passage Platine',2018,20),('Special été',2018,5)

-- 21 products
INSERT INTO Products (Number,Brand,Model,ProductDescription,Price,Stock) VALUES
	(10111,'Nuke','X12','Jersey',25.5,4),
	(12334,'Nuke','X18','Chaussure course',22,2),
	(43233,'Nuke','X22','Chaussure indoor',133.3,4),
	(44233,'Nuke','MU-21','Jersey',79,10),
	(34533,'Nuke','MU-22','Short',45,5),
	(54345,'Pluma','Top','Survet',111,22),
	(34555,'Pluma','Middle','',222,11),
	(45645,'Pluma','Bottom','Jersey',33,3),
	(65546,'Pluma','Mezzo','Chaussure course',44,4),
	(45664,'Pluma','Maxiplus','Chaussure indoor',55,5),
	(56756,'Pluma','Minimoins','Short',76,6),
	(55677,'Pluma','Zero','Survet',132,1),
	(55555,'Asisdas','Air-V','Chaussure course',45,5),
	(66777,'Asisdas','Air-Heure','Short',34,3),
	(56655,'Asisdas','Air-Ytem','Jersey',553,3),
	(75677,'Asisdas','Air-DNuss','',32,2),
	(55566,'Replonk','RP123','Survet',65,12),
	(33344,'Replonk','PR321','Chaussure indoor',211,11),
	(44455,'Replonk','ZoneX','Jersey',322,22),
	(22234,'Replonk','K8','Chaussure course',14,4),
	(23444,'Replonk','R77','',112,3)

-- 10 Customers
INSERT INTO Customers (Number,FirstName, LastName, EnrolmentDate, Category_id) VALUES
	(1001,'Cameron','Diaz','2003-1-1',2),
	(1010,'John','Malkovitch','2002-2-1',2),
	(2112,'George','Clooney','2005-3-1',1),
	(1221,'Pénélope','Cruz','2001-4-1',2),
	(2332,'Nicolas','Cage','2002-5-1',2),
	(3323,'Scarlett','Johannsson','2001-6-1',2),
	(3434,'Anthony','Hopkins','2003-7-1',2),
	(4344,'Julie','Andrews','2001-8-1',3),
	(5454,'Nestor','Burma','2009-9-1',3),
	(4455,'Alice','Sapritch','2001-10-1',1)	

INSERT INTO Benefit (Customer_id, Offer_id) VALUES
	(1,1),
	(1,2),
	(1,3),
	(1,4),
	(2,1),
	(2,2),
	(2,3),
	(3,2),
	(3,3),
	(3,4),
	(4,1),
	(4,4),
	(4,3),
	(5,2),
	(5,1),
	(6,2),
	(6,1),
	(7,2),
	(8,3)
	
-- 25 orders
INSERT INTO Orders (Number,Customer_id, OrderDate, OrderState_id) VALUES
	(12333,1,GETDATE(),1),
	(42342,1,GETDATE(),2),
	(22333,2,GETDATE(),3),
	(44333,2,GETDATE(),4),
	(44223,3,GETDATE(),1),
	(55533,4,GETDATE(),2),
	(53555,5,GETDATE(),3),
	(53553,6,GETDATE(),4),
	(34555,7,GETDATE(),1),
	(54333,7,GETDATE(),2),
	(55443,7,GETDATE(),3),
	(44556,7,GETDATE(),4),
	(66554,8,GETDATE(),1),
	(45645,8,GETDATE(),2),
	(65465,8,GETDATE(),3),
	(44444,8,GETDATE(),4),
	(55555,8,GETDATE(),1),
	(66666,8,GETDATE(),2),
	(55667,8,GETDATE(),3),
	(77665,8,GETDATE(),4),
	(55566,8,GETDATE(),1),
	(77766,8,GETDATE(),2),
	(77777,9,GETDATE(),3),
	(67864,10,GETDATE(),2),
	(96696,10,GETDATE(),4)

INSERT INTO Reference (Order_id,Product_id,Quantity) VALUES
	(1,10,1),
	(2,9,1),
	(3,8,2),
	(4,7,2),
	(5,6,1),
	(6,5,1),
	(7,4,2),
	(8,3,2),
	(9,2,1),
	(10,1,1),
	(11,1,3),
	(11,2,3),
	(12,3,1),
	(12,4,1),
	(13,5,2),
	(13,6,3),
	(14,7,1),
	(14,8,6),
	(15,9,2),
	(15,10,3),
	(16,9,1),
	(16,8,2),
	(17,6,3),
	(17,8,4),
	(18,7,1),
	(18,9,1),
	(19,6,1),
	(19,2,1),
	(20,4,2),
	(20,5,2),
	(20,7,2),
	(21,9,2),
	(21,1,1),
	(21,2,2),
	(21,3,3),
	(21,4,4),
	(22,5,3),
	(22,6,2),
	(22,7,1),
	(22,8,1),
	(22,9,2),
	(23,10,3),
	(23,1,1),
	(23,2,1),
	(23,3,1),
	(24,4,2),
	(24,5,2),
	(25,6,1),
	(25,7,1),
	(25,8,12)
