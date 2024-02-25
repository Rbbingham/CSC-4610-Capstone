/******************************************************************************
	
	CREATOR: Harrison Peloquin

	CREATED: February 24, 2024

	PURPOSE: For each day (using ConnectTimeStamp), calculate the count of calls
	(use count distinct CallID) and compare against and expected value. About 
	4k-8k calls a day

******************************************************************************/

Use [CapstoneDB]
GO

CREATE OR ALTER PROCEDURE [dbo].[BI_Health_BI_Call_Detail] --name of procedure
AS 
BEGIN
	SET NOCOUNT ON;

	IF OBJECT_ID('tempdb.dbo.temp_BI_Call_Detail') IS NOT NULL
	BEGIN
		DROP TABLE #temp_BI_Call_Detail -- temp table
	END;

	--Create temp table 
	CREATE TABLE #temp_BI_Call_Detail(
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
		#temp_BI_Call_Detail( --temp table name
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
		'BI_Call_Detail' AS TableName,
		 CAST(GETDATE() AS DATE) AS TestRunDate,
		'Expected Call Count' AS TestName,
		COUNT(DISTINCT </*INSERT COLUMN*/>) AS ActualResult,
		</*INSERT DEVIATION*/> AS ExpectedResult,
		(COUNT(DISTINCT </*INSERT COLUMN*/>) - </*INSERT DEVIATION*/>) AS Deviation,
		CAST(GETDATE() AS DATE) AS CreatedOn,
		'[CapstoneDB].[dbo].[BI_Health_PROCEDURE_NAME]' AS CreatedBy,
		NULL AS ModifiedOn,
		NULL AS ModifiedBy
	FROM 
		BI_Feed.dbo. with (nolock); -- choose table from 




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
		#temp_BI_Call_Detail; --temp table 

	DROP TABLE #temp_BI_Call_Detail;

	SET NOCOUNT OFF;
END
