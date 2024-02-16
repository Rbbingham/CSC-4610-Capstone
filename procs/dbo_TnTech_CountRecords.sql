/******************************************************************************
	
	CREATOR:	Robert Bingham

	CREATED:	2024/01/25

	PURPOSE:	Counts the number of records in the table.

******************************************************************************/

USE [CapstoneDB]
GO

CREATE OR ALTER PROCEDURE [dbo].[TnTech_CountRecords] (
	@TableName nvarchar(256),
	@Column nvarchar(256),
	@Date datetime,
	@Expected int
)
AS
BEGIN
	SET NOCOUNT ON;

	IF OBJECT_ID('tempdb.dbo.TCR') IS NOT NULL BEGIN
		DROP TABLE #TCR
	END;

	CREATE TABLE #TCR(
		[TableName] varchar(256) NOT NULL,
		[TestName] varchar(256) NOT NULL,
		[ActualResult] bigint NULL,
		[ExpectedResult] bigint NULL,
		[CreatedOn] date NOT NULL, -- 
		[CreatedBy] varchar(256) NULL,
		[ModifiedOn] datetime NULL,
		[ModifiedBy] varchar(256) NULL,
	);
	
	DECLARE @Command nvarchar(max);
	SET @Command = 
		'SELECT ''' 
			+ @TableName 
			+ ''', ''CountRecords''
			, COUNT(DISTINCT ' + @Column + '), ' 
			+ CAST(@Expected AS nvarchar(265))
			+ ', GETDATE() AS CreatedOn
			, ''[CapstoneDB].[dbo].[TnTech_CountRecords]''
			, NULL AS ModifiedOn
			, NULL AS ModifiedBy
		FROM ' 
			+ @TableName + ' with (nolock)
		WHERE ''' + CONVERT(varchar(10), @Date, 101) + ''' = CAST(GETDATE() AS DATE)';

	INSERT INTO 
		#TCR(
			TableName, 
			TestName, 
			ActualResult, 
			ExpectedResult, 
			CreatedOn, 
			CreatedBy, 
			ModifiedOn, 
			ModifiedBy)
	EXEC(@Command);

	INSERT INTO
		[dbo].[TnTech_TestResults](
			TableName, 
			TestName, 
			ActualResult, 
			ExpectedResult, 
			CreatedOn, 
			CreatedBy, 
			ModifiedOn, 
			ModifiedBy)
	SELECT 
		TableName,
		TestName,
		ActualResult,
		ExpectedResult,
		CreatedOn,
		CreatedBy,
		ModifiedOn,
		ModifiedBy
	FROM
		#TCR;

	DROP TABLE #TCR;

	SET NOCOUNT OFF;
END;
GO