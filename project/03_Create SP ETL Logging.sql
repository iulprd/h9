-- ================================================================================
-- Script for creating SP ETL logging
-- ================================================================================
USE [BIHack9_DWH]
GO

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

EXEC dbo.DropObject N'dbo.SP_ETL_Log_ETLProcessRunStart', N'P'
GO
-- ================================================
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Adalbert Songott@LeviNine>
-- Create date: <06-Nov-2016>
-- Description:	<ETL>
-- =============================================
CREATE PROCEDURE [dbo].[SP_ETL_Log_ETLProcessRunStart]
	-- The parameters for the stored procedure
	@ProcessRunID int = 0,
	@ETLPackageID int, --log.ETLProcessRun.ETLProcessRunID for current ETL Process
	@RunStatus varchar(11),
	@ETLProcessRunID int OUTPUT
AS

--Declaration
DECLARE @UserAccount nvarchar(128) = suser_sname()

BEGIN
	SET NOCOUNT ON;

    -- Insert new line with ETLProcessRun
	INSERT INTO FMO_DWH.log.ETLProcessRun WITH(TABLOCK)
		(ProcessRunID, 
		ETLPackageID, 
		StartDateTime, 
		EndDateTime, 
		RunStatus, 
		CreationDate, 
		UserAccount, 
		NrOfRec, 
		Remark)
	VALUES 
		(@ProcessRunID,
		@ETLPackageID,
		GETDATE(), 
		NULL, 
		@RunStatus, 
		GETDATE(), 
		@UserAccount, 
		NULL,
		NULL)	
	
	SET @ETLProcessRunID = SCOPE_IDENTITY()
			
END
GO

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

EXEC dbo.DropObject N'dbo.SP_ETL_Log_ETLProcessRunEnd', N'P'
GO
-- ================================================
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Adalbert Songott@LeviNine>
-- Create date: <06-Nov-2016>
-- Description:	<ETL>
-- =============================================
CREATE PROCEDURE [dbo].[SP_ETL_Log_ETLProcessRunEnd]
	-- The parameters for the stored procedure
	@ETLProcessRunID int,
	@RunStatus varchar(11),
	@NrOfRec int,
	@ErrorMessage varchar(250) = NULL
AS

--Declaration
DECLARE @UserAccount nvarchar(128) = suser_sname()

BEGIN
	SET NOCOUNT ON;

	--Update log ETLProcessRun
	UPDATE FMO_DWH.log.ETLProcessRun
	SET
		EndDateTime = GETDATE(),
		RunStatus = @RunStatus,
		NrOfRec = @NrOfRec,
		Remark = @ErrorMessage
	WHERE ETLProcessRunID = @ETLProcessRunID
			
END
GO
