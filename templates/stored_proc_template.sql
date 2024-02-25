/******************************************************************************
	
	CREATOR:

	CREATED:

	PURPOSE:

******************************************************************************/

Use [CapstoneDB]
GO

CREATE OR ALTER PROCEDURE [dbo].[BI_Health_] --name of procedure
AS 
BEGIN
	SET NOCOUNT ON;

	IF OBJECT_ID('tempdb.dbo.TEMP_TABLE_NAME') IS NOT NULL
	BEGIN
		DROP TABLE -- temp table 
	END;

	--Create temp table 
	CREATE TABLE #temp_(
		[TableName] varchar(256) NOT NULL,
		[TestRunDate] date NOT NULL,
		[TestName] varchar(256) NOT NULL,
		[ActualResult] bigint NOT NULL,
		[ExpectedResult] bigint NOT NULL,
		[Deviation] bigint NOT NULL,
		[CreatedOn] date NOT NULL,
		[CreatedBy] varchar(256) NOT NULL,
		[ModifiedOn] date NULL,
		[ModifiedBy] varchar(256) NULL
	);

	-- run normal query into temp table
	INSERT INTO 
		#temp_( --temp table name
			TableName,
			TestRunDate, 
			TestName,
			ActualResult,
			ExpectedResult,
			Deviation,
			CreatedOn,
			CreatedBy,
			ModifiedOn,
			ModifiedBy)
	SELECT
		'TABLENAME' AS TableName,
		 CAST(GETDATE() AS DATE) AS TestRunDate,
		'TESTNAME' AS TestName,
		COUNT(DISTINCT </*INSERT COLUMN*/>) AS ActualResult,
		</*INSERT DEVIATION*/> AS ExpectedResult,
		(COUNT(DISTINCT </*INSERT COLUMN*/>) - </*INSERT DEVIATION*/>) AS Deviation,
		CAST(GETDATE() AS DATE) AS CreatedOn,
		'[CapstoneDB].[dbo].[BI_Health_PROCEDURE_NAME]' AS CreatedBy,
		NULL AS ModifiedOn,
		NULL AS ModifiedBy
	FROM 
		BI_Feed.dbo. with (nolock); -- choose table from BI_feed

	--Upload data into CapstoneDB.dbo.BI_HealthResults
	INSERT INTO 
		CapstoneDB.dbo.BI_HealthResults(
			TableName,
			TestRunDate, 
			TestName,
			ActualResult,
			ExpectedResult,
			Deviation,
			CreatedOn,
			CreatedBy,
			ModifiedOn,
			ModifiedBy)
	SELECT
		TableName,
		TestRunDate, 
		TestName,
		ActualResult,
		ExpectedResult,
		Deviation,
		CreatedOn,
		CreatedBy,
		ModifiedOn,
		ModifiedBy
	FROM 
		</*INSERT TEMP TABLE NAME*/>;--temp table 

	DROP TABLE </*INSERT TEMP TABLE NAME*/>;

	SET NOCOUNT OFF;
END
