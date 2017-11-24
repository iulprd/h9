-- ================================================================================
-- Script for creating log tables for audit purposes
-- ================================================================================
USE [BIHack9_DWH]
GO

--Creating [log] schema if doesn't exist
IF NOT EXISTS (
SELECT schema_name
FROM information_schema.schemata
WHERE schema_name = 'log')

EXEC sp_executesql N'CREATE SCHEMA [log] AUTHORIZATION [dbo]'


-----------------------------------Create tables-----------------------------------

--Create log.ProcessRun table, which records the history process run 
EXEC dbo.DropObject N'log.ProcessRun', N'T'
GO
CREATE TABLE log.ProcessRun (
	ProcessRunID int IDENTITY(1,1) NOT NULL,
	StartDateTime datetime NOT NULL,
	EndDateTime datetime NULL,
	RunStatus varchar(11) NOT NULL, --(In progress, Failed, Success)
	CreationDate datetime NOT NULL DEFAULT GETDATE(),
	OnSchedule bit NOT NULL, --1 if triggered by schedule, 0 if triggered on demand or other cases
	UserAccount nvarchar(128) NOT NULL,
	Remark varchar(500) NULL,
	
 CONSTRAINT [PK_ProcessRun] PRIMARY KEY CLUSTERED (ProcessRunID ASC)
)
GO

DECLARE @v sql_variant 
SET @v = N'The process run identifier. It is unique, not null, identity and the primary key. This info will be stored in all lines of the log.ETLProcessRun table for tracking back to the process run.'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=@v , @level0type=N'SCHEMA',@level0name=N'log', @level1type=N'TABLE',@level1name=N'ProcessRun', @level2type=N'COLUMN',@level2name=N'ProcessRunID'
GO
DECLARE @v sql_variant 
SET @v = N'The process run start date and time.'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=@v , @level0type=N'SCHEMA',@level0name=N'log', @level1type=N'TABLE',@level1name=N'ProcessRun', @level2type=N'COLUMN',@level2name=N'StartDateTime'
GO
DECLARE @v sql_variant 
SET @v = N'The process run end date and time.'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=@v , @level0type=N'SCHEMA',@level0name=N'log', @level1type=N'TABLE',@level1name=N'ProcessRun', @level2type=N'COLUMN',@level2name=N'EndDateTime'
GO
DECLARE @v sql_variant 
SET @v = N'The process run status. Can take values: In progress, Failed, Success and None (for ID 0 - idependent runs of ETL processes)'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=@v , @level0type=N'SCHEMA',@level0name=N'log', @level1type=N'TABLE',@level1name=N'ProcessRun', @level2type=N'COLUMN',@level2name=N'RunStatus'
GO
DECLARE @v sql_variant 
SET @v = N'The creation date of the process run. Defaults to current datetime.'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=@v , @level0type=N'SCHEMA',@level0name=N'log', @level1type=N'TABLE',@level1name=N'ProcessRun', @level2type=N'COLUMN',@level2name=N'CreationDate'
GO
DECLARE @v sql_variant 
SET @v = N'1 if triggered by schedule, 0 if triggered on demand as a result of an user action or other cases.'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=@v , @level0type=N'SCHEMA',@level0name=N'log', @level1type=N'TABLE',@level1name=N'ProcessRun', @level2type=N'COLUMN',@level2name=N'OnSchedule'
GO
DECLARE @v sql_variant 
SET @v = N'The useraccount which activated the process run.'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=@v , @level0type=N'SCHEMA',@level0name=N'log', @level1type=N'TABLE',@level1name=N'ProcessRun', @level2type=N'COLUMN',@level2name=N'UserAccount'
GO
DECLARE @v sql_variant 
SET @v = N'Any remarks or notes in relation to the ETL process run. Can also be added manually to make the audit more complete.'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=@v , @level0type=N'SCHEMA',@level0name=N'log', @level1type=N'TABLE',@level1name=N'ProcessRun', @level2type=N'COLUMN',@level2name=N'Remark'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Table will contain the workload history.' , @level0type=N'SCHEMA',@level0name=N'log', @level1type=N'TABLE',@level1name=N'ProcessRun'
GO

--insert line with ProcessRunID=0
SET IDENTITY_INSERT log.ProcessRun ON
INSERT INTO log.ProcessRun 
	(ProcessRunID, 
	StartDateTime, 
	EndDateTime, 
	RunStatus, 
	CreationDate, 
	OnSchedule, 
	UserAccount, 
	Remark)
VALUES 
	(0,
	CAST(0 as datetime), 
	CAST(2958463 as datetime), 
	'None', 
	GETDATE(), 
	0, 
	'Unknown', 
	'0 means the ETL package was run independently from the main ETL. See log.ETLProcessRun.RunStatus for the ETL status.')
SET IDENTITY_INSERT log.ProcessRun OFF
GO
--make sure identity column starts from 1
DBCC CHECKIDENT ('log.ProcessRun', RESEED, 0);  
GO

-------------------------------------------------------------------------------
--Create log.ETLProcessRun table, which records the history of the ETL process run 
EXEC dbo.DropObject N'log.ETLProcessRun', N'T'
GO
CREATE TABLE log.ETLProcessRun (
	ETLProcessRunID int IDENTITY(1,1) NOT NULL,
	ProcessRunID int NOT NULL,
	ETLPackageID int NOT NULL,
	StartDateTime datetime NOT NULL,
	EndDateTime datetime NULL,
	RunStatus varchar(11) NOT NULL, --(In progress, Failed, Success)
	CreationDate datetime NOT NULL DEFAULT GETDATE(),
	--OnSchedule bit NOT NULL, --1 if triggered by schedule, 0 if triggered on demand or other cases
	UserAccount nvarchar(128) NOT NULL,
	NrOfRec int NULL,
	Remark varchar(500) NULL,
	
 CONSTRAINT [PK_ETLProcessRun] PRIMARY KEY CLUSTERED (ETLProcessRunID ASC)
)
GO

ALTER TABLE [log].[ETLProcessRun]  WITH CHECK ADD  CONSTRAINT [FK_ETLProcessRun_ProcessRun] FOREIGN KEY(ProcessRunID)
REFERENCES [log].[ProcessRun] (ProcessRunID)
	ON UPDATE NO ACTION
	ON DELETE NO ACTION
	NOT FOR REPLICATION
GO
ALTER TABLE [log].[ETLProcessRun] CHECK CONSTRAINT [FK_ETLProcessRun_ProcessRun]
GO
ALTER TABLE [log].[ETLProcessRun]  WITH CHECK ADD  CONSTRAINT [FK_ETLProcessRun_ETLPackage] FOREIGN KEY(ETLPackageID)
REFERENCES [mtd].[ETLPackage] (ETLPackageID)
	ON UPDATE CASCADE
	ON DELETE NO ACTION
GO
ALTER TABLE [log].[ETLProcessRun] CHECK CONSTRAINT [FK_ETLProcessRun_ETLPackage]
GO

DECLARE @v sql_variant 
SET @v = N'The ETL process run identifier. It is unique, not null, identity and the primary key. This info will be stored in all the dimension and fact tables for tracking back to the ETL process run which affected a row.'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=@v , @level0type=N'SCHEMA',@level0name=N'log', @level1type=N'TABLE',@level1name=N'ETLProcessRun', @level2type=N'COLUMN',@level2name=N'ETLProcessRunID'
GO
DECLARE @v sql_variant 
SET @v = N'The process run identifier under which the ETL is run. 0 means the ETL package was run independently from the main ETL.'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=@v , @level0type=N'SCHEMA',@level0name=N'log', @level1type=N'TABLE',@level1name=N'ETLProcessRun', @level2type=N'COLUMN',@level2name=N'ProcessRunID'
GO
DECLARE @v sql_variant 
SET @v = N'The ETL package identifier.'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=@v , @level0type=N'SCHEMA',@level0name=N'log', @level1type=N'TABLE',@level1name=N'ETLProcessRun', @level2type=N'COLUMN',@level2name=N'ETLPackageID'
GO
DECLARE @v sql_variant 
SET @v = N'The ETL process run start date and time.'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=@v , @level0type=N'SCHEMA',@level0name=N'log', @level1type=N'TABLE',@level1name=N'ETLProcessRun', @level2type=N'COLUMN',@level2name=N'StartDateTime'
GO
DECLARE @v sql_variant 
SET @v = N'The ETL process run end date and time.'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=@v , @level0type=N'SCHEMA',@level0name=N'log', @level1type=N'TABLE',@level1name=N'ETLProcessRun', @level2type=N'COLUMN',@level2name=N'EndDateTime'
GO
DECLARE @v sql_variant 
SET @v = N'The ETL process run status. Can take values: In progress, Failed, Success.'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=@v , @level0type=N'SCHEMA',@level0name=N'log', @level1type=N'TABLE',@level1name=N'ETLProcessRun', @level2type=N'COLUMN',@level2name=N'RunStatus'
GO
DECLARE @v sql_variant 
SET @v = N'The creation date of the ETL process run. Defaults to current datetime.'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=@v , @level0type=N'SCHEMA',@level0name=N'log', @level1type=N'TABLE',@level1name=N'ETLProcessRun', @level2type=N'COLUMN',@level2name=N'CreationDate'
GO
DECLARE @v sql_variant 
SET @v = N'The useraccount which activated the ETL process run.'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=@v , @level0type=N'SCHEMA',@level0name=N'log', @level1type=N'TABLE',@level1name=N'ETLProcessRun', @level2type=N'COLUMN',@level2name=N'UserAccount'
GO
DECLARE @v sql_variant 
SET @v = N'The number of records processed.'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=@v , @level0type=N'SCHEMA',@level0name=N'log', @level1type=N'TABLE',@level1name=N'ETLProcessRun', @level2type=N'COLUMN',@level2name=N'NrOfRec'
GO
DECLARE @v sql_variant 
SET @v = N'Any remarks or notes in relation to the ETL process run. Can also be added manually to make the audit more complete.'
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=@v , @level0type=N'SCHEMA',@level0name=N'log', @level1type=N'TABLE',@level1name=N'ETLProcessRun', @level2type=N'COLUMN',@level2name=N'Remark'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Table will contain the workload history of extracting, transforming and loading the sourcedata into the Data Warehouse.' , @level0type=N'SCHEMA',@level0name=N'log', @level1type=N'TABLE',@level1name=N'ETLProcessRun'
GO

-------------------------------------------------------------------------------