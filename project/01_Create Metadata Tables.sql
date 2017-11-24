-- ================================================================================
-- Script for creating metadata tables
-- ================================================================================
USE [BIHack9_DWH]
GO

--Creating [mtd] schema if doesn't exist
IF NOT EXISTS (
SELECT schema_name
FROM information_schema.schemata
WHERE schema_name = 'mtd')

EXEC sp_executesql N'CREATE SCHEMA [mtd] AUTHORIZATION [dbo]'


-----------------------------------Create tables-----------------------------------
--Create mtd.ETLPackage
EXEC dbo.DropObject N'mtd.ETLPackage', N'T'
GO
CREATE TABLE mtd.ETLPackage (
	ETLPackageID int IDENTITY(1,1) NOT NULL,
	ETLPackageName varchar(100) NOT NULL,
	[Description] varchar(250) NOT NULL,
	DWHLayer varchar(15) NOT NULL,
	[Type] varchar(50) NOT NULL,
	Location varchar(250) NOT NULL,
	Remark varchar(400) NULL,

 CONSTRAINT [PK_ETLPackage] PRIMARY KEY CLUSTERED (ETLPackageID ASC)
)
GO

DECLARE @v sql_variant 
SET @v = N'The ETL package identifier. It is unique, not null, identity and the primary key.'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=@v , @level0type=N'SCHEMA',@level0name=N'mtd', @level1type=N'TABLE',@level1name=N'ETLPackage', @level2type=N'COLUMN',@level2name=N'ETLPackageID'
GO
DECLARE @v sql_variant 
SET @v = N'The name of the ETL package.'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=@v , @level0type=N'SCHEMA',@level0name=N'mtd', @level1type=N'TABLE',@level1name=N'ETLPackage', @level2type=N'COLUMN',@level2name=N'ETLPackageName'
GO
DECLARE @v sql_variant 
SET @v = N'The description of the ETL package.'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=@v , @level0type=N'SCHEMA',@level0name=N'mtd', @level1type=N'TABLE',@level1name=N'ETLPackage', @level2type=N'COLUMN',@level2name=N'Description'
GO
DECLARE @v sql_variant 
SET @v = N'The ETL package layer. Can be PreProcess, Staging, DWH, DataMart, PostProcess'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=@v , @level0type=N'SCHEMA',@level0name=N'mtd', @level1type=N'TABLE',@level1name=N'ETLPackage', @level2type=N'COLUMN',@level2name=N'DWHLayer'
GO
DECLARE @v sql_variant 
SET @v = N'The ETL package technology type. Can have values like: Stored procedure, SSIS, SQL script, VB script, etc.'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=@v , @level0type=N'SCHEMA',@level0name=N'mtd', @level1type=N'TABLE',@level1name=N'ETLPackage', @level2type=N'COLUMN',@level2name=N'Type'
GO
DECLARE @v sql_variant 
SET @v = N'The location of the ETL package.'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=@v , @level0type=N'SCHEMA',@level0name=N'mtd', @level1type=N'TABLE',@level1name=N'ETLPackage', @level2type=N'COLUMN',@level2name=N'Location'
GO
DECLARE @v sql_variant 
SET @v = N'Any remarks or notes in relation to the ETL package.'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=@v , @level0type=N'SCHEMA',@level0name=N'mtd', @level1type=N'TABLE',@level1name=N'ETLPackage', @level2type=N'COLUMN',@level2name=N'Remark'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Table will contain the metadata of the ETL packages used to populate/integrate data from the sources into DWH.' , @level0type=N'SCHEMA',@level0name=N'mtd', @level1type=N'TABLE',@level1name=N'ETLPackage'
GO

-------------------------------------------------------------------------------
--Create mtd.DataSource
EXEC dbo.DropObject N'mtd.DataSource', N'T'
GO
CREATE TABLE mtd.DataSource (
	DataSourceID int IDENTITY(1,1) NOT NULL,
	DataSourceName varchar(100) NOT NULL,
	[Description] varchar(250) NOT NULL,
	DataSourceType varchar(50) NOT NULL,
	Location varchar(250) NOT NULL,
	Remark varchar(400) NULL,

 CONSTRAINT [PK_DataSource] PRIMARY KEY CLUSTERED (DataSourceID ASC)
)
GO

DECLARE @v sql_variant 
SET @v = N'The identifier of the data source, the primary key.'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=@v , @level0type=N'SCHEMA',@level0name=N'mtd', @level1type=N'TABLE',@level1name=N'DataSource', @level2type=N'COLUMN',@level2name=N'DataSourceID'
GO
DECLARE @v sql_variant 
SET @v = N'The name of the data source.'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=@v , @level0type=N'SCHEMA',@level0name=N'mtd', @level1type=N'TABLE',@level1name=N'DataSource', @level2type=N'COLUMN',@level2name=N'DataSourceName'
GO
DECLARE @v sql_variant 
SET @v = N'The detailed description of the data source.'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=@v , @level0type=N'SCHEMA',@level0name=N'mtd', @level1type=N'TABLE',@level1name=N'DataSource', @level2type=N'COLUMN',@level2name=N'Description'
GO
DECLARE @v sql_variant 
SET @v = N'The type of the data source (i.e. SQL Server, Oracle, MySQL, PostgreSQL, Excel, flat file).'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=@v , @level0type=N'SCHEMA',@level0name=N'mtd', @level1type=N'TABLE',@level1name=N'DataSource', @level2type=N'COLUMN',@level2name=N'DataSourceType'
GO
DECLARE @v sql_variant 
SET @v = N'The location of the data source (server name and database, FTP location, file share location).'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=@v , @level0type=N'SCHEMA',@level0name=N'mtd', @level1type=N'TABLE',@level1name=N'DataSource', @level2type=N'COLUMN',@level2name=N'Location'
GO
DECLARE @v sql_variant 
SET @v = N'Any remarks or notes in relation to the data source.'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=@v , @level0type=N'SCHEMA',@level0name=N'mtd', @level1type=N'TABLE',@level1name=N'DataSource', @level2type=N'COLUMN',@level2name=N'Remark'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Table will contain the metadata for the data source(s)' , @level0type=N'SCHEMA',@level0name=N'mtd', @level1type=N'TABLE',@level1name=N'DataSource'
GO

-------------------------------------------------------------------------------
--Create mtd.ETLPackage_DataSource
EXEC dbo.DropObject N'mtd.ETLPackageDataSource', N'T'
GO
CREATE TABLE mtd.ETLPackageDataSource (
	ETLPackageID int NOT NULL,
	DataSourceID int NOT NULL,

 CONSTRAINT [PK_ETLPackageDataSource] PRIMARY KEY CLUSTERED (ETLPackageID ASC, DataSourceID ASC)
)
GO

ALTER TABLE [mtd].[ETLPackageDataSource]  WITH CHECK ADD  CONSTRAINT [FK_ETLPackageDataSource_ETLPackage] FOREIGN KEY(ETLPackageID)
REFERENCES [mtd].[ETLPackage] (ETLPackageID)
	ON UPDATE CASCADE
	ON DELETE NO ACTION
GO
ALTER TABLE [mtd].[ETLPackageDataSource] CHECK CONSTRAINT [FK_ETLPackageDataSource_ETLPackage]
GO
ALTER TABLE [mtd].[ETLPackageDataSource]  WITH CHECK ADD  CONSTRAINT [FK_ETLPackageDataSource_DataSource] FOREIGN KEY(DataSourceID)
REFERENCES [mtd].[DataSource] (DataSourceID)
	ON UPDATE CASCADE
	ON DELETE NO ACTION
GO
ALTER TABLE [mtd].[ETLPackageDataSource] CHECK CONSTRAINT [FK_ETLPackageDataSource_DataSource]
GO

DECLARE @v sql_variant 
SET @v = N'Any remarks or notes in relation to the ETL package.'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=@v , @level0type=N'SCHEMA',@level0name=N'mtd', @level1type=N'TABLE',@level1name=N'ETLPackageDataSource', @level2type=N'COLUMN',@level2name=N'ETLPackageID'
GO
DECLARE @v sql_variant 
SET @v = N'Any remarks or notes in relation to the ETL package.'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=@v , @level0type=N'SCHEMA',@level0name=N'mtd', @level1type=N'TABLE',@level1name=N'ETLPackageDataSource', @level2type=N'COLUMN',@level2name=N'DataSourceID'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Table will contain the metadata ...' , @level0type=N'SCHEMA',@level0name=N'mtd', @level1type=N'TABLE',@level1name=N'ETLPackageDataSource'
GO
