/******************************************************************************
	
	CREATOR:	Robert Bingham

	CREATED:	2024/01/25

	PURPOSE:	Counts the number of records in the table.

******************************************************************************/

USE [CapstoneDB]
GO

-- TODO: convert datetime to date
-- TODO: convert @Expected to bigint
CREATE OR ALTER PROCEDURE [dbo].[TnTech_CountRecords] (
	@TableName varchar(256),
	@Column varchar(256),
	@Date datetime,
	@Expected varchar(256)
)
AS
BEGIN
	SET NOCOUNT ON;

	IF OBJECT_ID('#TCR') IS NOT NULL BEGIN
		DROP TABLE #TCR
	END;

	CREATE TABLE #TCR (
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
			+ ''', COUNT(DISTINCT ' + @Column + '), ' 
			+ @Expected 
			+ ', GETDATE() AS CreatedOn
			, ''[CapstoneDB].[dbo].[TnTech_CountRecords]''
			, NULL AS ModifiedOn
			, NULL AS ModifiedBy
		FROM ' 
			+ @TableName 
		+ ' WHERE ''' + CONVERT(varchar(10), @Date, 101) + ''' = CAST(GETDATE() AS DATE)';

	INSERT INTO 
		#TCR(TableName, ActualResult, ExpectedResult, CreatedOn, CreatedBy, ModifiedOn, ModifiedBy)
	EXEC(@Command);

	INSERT INTO
		[dbo].[TnTech_TestResults](TableName, ActualResult, ExpectedResult, CreatedOn, CreatedBy, ModifiedOn, ModifiedBy)
	SELECT 
		TableName,
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

DECLARE @TodaysDate datetime;
SET @TodaysDate = GETDATE();
EXEC [dbo].[TnTech_CountRecords] @TableName = '[BI_Feed].[dbo].[Toyota_Inventory]', 
								 @Column = '[VIN]', 
								 @Date = @TodaysDate,
								 @Expected = '1000';

-- SELECT * FROM [dbo].TnTech_TestResults ORDER BY CreatedOn DESC;