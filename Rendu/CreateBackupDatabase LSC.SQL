-- -----------------------------------------------------
-- Crete a Database Backup
-- -----------------------------------------------------
BACKUP DATABASE [LosSantosCustum] 
TO DISK = N'C:\Backups\EcommerceBackup-Script.bak' 
WITH NOFORMAT, NOINIT,  
NAME = N'ECommerce Database Backup', SKIP, NOREWIND, NOUNLOAD,  STATS = 10
GO

-- -----------------------------------------------------
-- Delete Database
-- -----------------------------------------------------
USE master ;  
DROP DATABASE LosSantosCustum ;  
GO

-- -----------------------------------------------------
-- Restore Database from Backup
-- -----------------------------------------------------
USE [master]
RESTORE DATABASE [LosSantosCustum] 
FROM DISK = N'C:\Backups\EcommerceBackup-Script.bak' WITH  FILE = 1,  NOUNLOAD,  STATS = 5
GO