-- ================================================================================
-- Script for creating dbo.[DropObject] stored procedure, used to drop an object prior (re)creation.
-- ================================================================================

--Create [DropObject] sp on DWH
USE [BIHack9_DWH]
GO

CREATE PROCEDURE [dbo].[DropObject]
	@Name nvarchar(128), -- Object name
	@Type nchar(2) -- Object type: T=table, TT=temp table, V=view, P=procedure, F=function, I=index, O=user/schema
AS
	DECLARE
		@Ver int,
		@ExecString nvarchar(max),
		@NameObject nvarchar(256), -- For index purpose only
		@NameIndex nvarchar(256), -- For index purpose only
		@TmpDropFK nvarchar(256), -- For drop FK purpose only
		@ExecStringDropFK nvarchar(max) -- For drop FK purpose only
	
	IF CHARINDEX(' 9.', @@VERSION) > 0
		SET @Ver = '9'
	IF CHARINDEX(' 10.', @@VERSION) > 0
		SET @Ver = '10'
	IF CHARINDEX(' 11.', @@VERSION) > 0
		SET @Ver = '11'
	IF CHARINDEX(' 12.', @@VERSION) > 0
		SET @Ver = '12'		
	IF CHARINDEX(' 13.', @@VERSION) > 0
		SET @Ver = '13'	
	
	-- For index only; first part is table name, second part is index name, seperated by semicolon
	IF CHARINDEX(';', @Name) > 0
	BEGIN
		SET @NameObject = LEFT(@Name, CHARINDEX(';', @Name) - 1)
		SET @NameIndex = RIGHT(@Name, LEN(@Name) - CHARINDEX(';', @Name))
	END

	-- for dropping table constraints, generate list of foreign key constraints that need to be dropped
	IF @Type='T'
	BEGIN		
		SET @ExecStringDropFK = ''
		DECLARE fk_cursor CURSOR FOR
			SELECT
				'ALTER TABLE ' + OBJECT_SCHEMA_NAME(parent_object_id) + '.' + OBJECT_NAME(parent_object_id) + ' DROP CONSTRAINT ' + name
			FROM
				sys.foreign_keys
			WHERE
				OBJECT_ID(@Name) = referenced_object_id		
		OPEN fk_cursor   
		FETCH NEXT FROM fk_cursor INTO @TmpDropFK
		WHILE @@FETCH_STATUS = 0  
		BEGIN
			SET @ExecStringDropFK = @ExecStringDropFK + @TmpDropFK + ' '
			FETCH NEXT FROM fk_cursor INTO @TmpDropFK
		END
		CLOSE fk_cursor
		DEALLOCATE fk_cursor
	END
	
	IF @Ver = 9 -- Microsoft SQL Server 2005
		SET @ExecString =
			CASE
				WHEN @Type = 'T' THEN
					'IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N''' + @Name + ''') AND type in (N''U'')) ' +
					'BEGIN ' +
					'  ' + @ExecStringDropFK +
					'  DROP TABLE ' + @Name + ' ' +
					'END '
				WHEN @Type = 'TT' THEN
					'IF OBJECT_ID (''tempdb..' + @Name + ''', ''U'') IS NOT NULL ' +
					'DROP TABLE ' + @Name
				WHEN @Type = 'V' THEN
					'IF EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N''' + @Name + ''')) ' +
					'DROP VIEW ' + @Name
				WHEN @Type = 'P' THEN
					'IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N''' + @Name + ''') AND type in (N''P'', N''PC'')) ' +
					'DROP PROCEDURE ' + @Name
				WHEN @Type = 'F' THEN
					'IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N''' + @Name + ''') AND type in (N''FN'', N''IF'', N''TF'', N''FS'', N''FT'')) ' +
					'DROP FUNCTION ' + @Name
				WHEN @Type = 'I' THEN
					'IF EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N''' + @NameObject + ''') AND name = N''' + @NameIndex + ''') ' +
					'DROP INDEX ' + @NameIndex + ' ON ' + @NameObject
				WHEN @Type = 'O' THEN
					'IF EXISTS (SELECT * FROM sys.schemas WHERE name = N''' + @Name + ''') ' +
					'DROP SCHEMA ' + @Name
			END
	ELSE IF @Ver = 10 OR @Ver = 11 OR @Ver=12 OR @Ver=13  -- Microsoft SQL Server 2008, Microsoft SQL Server 2012, Microsoft SQL Server 2014, Microsoft SQL Server 2016
		SET @ExecString =
			CASE
				WHEN @Type = 'T' THEN
					'IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N''' + @Name + ''') AND type in (N''U'')) ' +
					'BEGIN ' +
					'  ' + @ExecStringDropFK +
					'  DROP TABLE ' + @Name + ' ' + 
					'END '
				WHEN @Type = 'TT' THEN
					'IF OBJECT_ID (''tempdb..' + @Name + ''', ''U'') IS NOT NULL ' +
					'DROP TABLE ' + @Name
				WHEN @Type = 'V' THEN
					'IF EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N''' + @Name + ''')) ' +
					'DROP VIEW ' + @Name
				WHEN @Type = 'P' THEN
					'IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N''' + @Name + ''') AND type in (N''P'', N''PC'')) ' +
					'DROP PROCEDURE ' + @Name
				WHEN @Type = 'F' THEN
					'IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N''' + @Name + ''') AND type in (N''FN'', N''IF'', N''TF'', N''FS'', N''FT'')) ' +
					'DROP FUNCTION ' + @Name
				WHEN @Type = 'I' THEN
					'IF EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N''' + @NameObject + ''') AND name = N''' + @NameIndex + ''') ' +
					'DROP INDEX ' + @NameIndex + ' ON ' + @NameObject
				WHEN @Type = 'O' THEN
					'IF EXISTS (SELECT * FROM sys.schemas WHERE name = N''' + @Name + ''') ' +
					'DROP SCHEMA ' + @Name
			END
	EXEC sp_executesql @ExecString
GO