-- Goal: Creates the Los_Santos_Custum DB
--       If the DB already exists, it is destroyed and recreated
--       The data directory C:\DATA\MSSQL is created if it doesn't exist

USE master
GO

-- First delete the database if it exists
IF (EXISTS (SELECT name FROM master.dbo.sysdatabases WHERE name = 'LosSantosCustum'))
BEGIN
	USE master
	ALTER DATABASE LosSantosCustum SET SINGLE_USER WITH ROLLBACK IMMEDIATE; -- Disconnect users the hard way (we cannot drop the db if someone's connected)
	DROP DATABASE LosSantosCustum -- Destroy it
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
CREATE DATABASE LosSantosCustum ON  PRIMARY 
( NAME = 'LosSantosCustum_data', FILENAME = 'C:\DATA\MSSQL\LosSantosCustum.mdf' , SIZE = 20480KB , MAXSIZE = 51200KB , FILEGROWTH = 1024KB )
 LOG ON 
( NAME = 'LosSantosCustum_log', FILENAME = 'C:\DATA\MSSQL\LosSantosCustum.ldf' , SIZE = 10240KB , MAXSIZE = 20480KB , FILEGROWTH = 1024KB )

GO

-- CreaTables.SQL
-- Date: 11.9.2012
-- Author: MonteiroRui
-- Goal: Create all tables of the Los_Santos_Custum database

USE LosSantosCustum
GO

-- -----------------------------------------------------
-- Création des tables
-- -----------------------------------------------------

-- -----------------------------------------------------
-- Table Customers
-- -----------------------------------------------------
CREATE TABLE Customers (
	id int IDENTITY(1,1) NOT NULL PRIMARY KEY,
	Name VARCHAR(45) NOT NULL,
	LastName VARCHAR(45) NOT NULL,
	BirthDate DATE NULL,
	PhoneNumber INT NULL)

-- -----------------------------------------------------
-- Table Locations
-- -----------------------------------------------------
CREATE TABLE Locations (
	id int IDENTITY(1,1) NOT NULL PRIMARY KEY,
	ZipCode INT NOT NULL,
	City VARCHAR(45) NOT NULL,
	Customers_id INT NOT NULL)

-- -----------------------------------------------------
-- Table Brands
-- -----------------------------------------------------
CREATE TABLE Brands (
  id int IDENTITY(1,1) NOT NULL PRIMARY KEY,
  Name VARCHAR(45) NOT NULL,
  CreationDate DATE NOT NULL,
  img varbinary(1024) NULL)

-- -----------------------------------------------------
-- Table Promotions
-- -----------------------------------------------------
CREATE TABLE Promotions (
  id int IDENTITY(1,1) NOT NULL PRIMARY KEY,
  Percentage INT NULL,
  ExpirationDate DATE NULL)

-- -----------------------------------------------------
-- Table Chassis
-- -----------------------------------------------------
CREATE TABLE Chassis (
  id int IDENTITY(1,1) NOT NULL PRIMARY KEY,
  SerieNumber VARCHAR(45) NOT NULL,
  Type VARCHAR(45) NULL)

-- -----------------------------------------------------
-- Table Cars
-- -----------------------------------------------------
CREATE TABLE Cars (
  id int IDENTITY(1,1) NOT NULL PRIMARY KEY,
  Transmission VARCHAR(45) NULL,
  SpeedAcceleration FLOAT NULL,
  MaxSpeed INT NULL,
  Brands_id INT NOT NULL,
  Customers_id INT NOT NULL,
  Promotions_id INT NULL,
  Chassis_id INT NOT NULL)

-- -----------------------------------------------------
-- Table Sellers
-- -----------------------------------------------------
CREATE TABLE Sellers (
  id int IDENTITY(1,1) NOT NULL PRIMARY KEY,
  Name VARCHAR(45) NOT NULL,
  LastName VARCHAR(45) NOT NULL,
  BirthDate VARCHAR(45) NULL,
  PhoneNumber VARCHAR(45) NULL)

-- -----------------------------------------------------
-- Table Categories
-- -----------------------------------------------------
CREATE TABLE Categories (
  id int IDENTITY(1,1) NOT NULL PRIMARY KEY,
  Name VARCHAR(45) NULL)

-- -----------------------------------------------------
-- Table Models
-- -----------------------------------------------------
CREATE TABLE Models (
  id int IDENTITY(1,1) NOT NULL PRIMARY KEY,
  Name VARCHAR(45) NULL)

-- -----------------------------------------------------
-- Table Cars_has_Sellers
-- -----------------------------------------------------
CREATE TABLE Cars_has_Sellers (
  Cars_id int IDENTITY(1,1) NOT NULL PRIMARY KEY,
  Sellers_id INT NOT NULL)

-- -----------------------------------------------------
-- Table Categories_has_Cars
-- -----------------------------------------------------
CREATE TABLE Categories_has_Cars (
  Categories_id int IDENTITY(1,1) NOT NULL PRIMARY KEY,
  Cars_id INT NOT NULL,
  Cars_Brands_id INT NOT NULL,
  Cars_Customers_id INT NOT NULL)

-- -----------------------------------------------------
-- Table Cars_has_Models
-- -----------------------------------------------------
CREATE TABLE Cars_has_Models (
  Cars_id int IDENTITY(1,1) NOT NULL PRIMARY KEY,
  Cars_Brands_id INT NOT NULL,
  Cars_Customers_id INT NOT NULL,
  Cars_Promotions_id INT NOT NULL,
  Models_id INT NOT NULL)



-- -----------------------------------------------------
-- Contraintes référentielles
-- -----------------------------------------------------
ALTER TABLE Cars WITH CHECK ADD CONSTRAINT FK_Cars_Brands FOREIGN KEY(Brands_id)
REFERENCES Brands(id)

ALTER TABLE Cars WITH CHECK ADD CONSTRAINT FK_Cars_Customers FOREIGN KEY(Customers_id)
REFERENCES Customers(id)

ALTER TABLE Cars WITH CHECK ADD CONSTRAINT FK_Cars_Promotions FOREIGN KEY(Promotions_id)
REFERENCES Promotions(id)

ALTER TABLE Cars WITH CHECK ADD CONSTRAINT FK_Cars_Chassis FOREIGN KEY(Chassis_id)
REFERENCES Chassis(id)

-- Table Cars_has_Sellers
ALTER TABLE Cars_has_Sellers WITH CHECK ADD CONSTRAINT FK_Cars_Sellers FOREIGN KEY(Sellers_id)
REFERENCES Sellers(id)

-- Table Categories_has_Cars
ALTER TABLE Categories_has_Cars WITH CHECK ADD CONSTRAINT FK_Cars_Categories FOREIGN KEY(Cars_id)
REFERENCES Cars(id)

ALTER TABLE Categories_has_Cars WITH CHECK ADD CONSTRAINT FK_Brands_Categories FOREIGN KEY(Cars_Brands_id)
REFERENCES Brands(id)

ALTER TABLE Categories_has_Cars WITH CHECK ADD CONSTRAINT FK_Customers_Categories FOREIGN KEY(Cars_Customers_id)
REFERENCES Customers(id)

-- Table Cars_has_Models
ALTER TABLE Cars_has_Models WITH CHECK ADD CONSTRAINT FK_Brands_Cars FOREIGN KEY(Cars_Brands_id)
REFERENCES Brands(id)

ALTER TABLE Cars_has_Models WITH CHECK ADD CONSTRAINT FK_Customers_Cars FOREIGN KEY(Cars_Customers_id)
REFERENCES Customers(id)

ALTER TABLE Cars_has_Models WITH CHECK ADD CONSTRAINT FK_Promotions_Cars FOREIGN KEY(Cars_Promotions_id)
REFERENCES Promotions(id)

ALTER TABLE Cars_has_Models WITH CHECK ADD CONSTRAINT FK_Models_Cars FOREIGN KEY(Models_id)
REFERENCES Models(id)