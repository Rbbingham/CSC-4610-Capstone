/******************************************************************************
	
	CREATOR: Lorenzo Abellanosa

	CREATED: 3/19/24

	PURPOSE: Ensures that there is apporximately 1500 products Id(s) in the table

******************************************************************************/

Use [CapstoneDB]
GO

CREATE OR ALTER PROCEDURE [dbo].[BI_Health_BalancesSummary] --name of procedure
AS 
BEGIN
	SET NOCOUNT ON;

	IF OBJECT_ID('tempdb.dbo.temp_BalancesSummary') IS NOT NULL
	BEGIN
		DROP TABLE #temp_BalancesSummary-- temp table 
	END;

	--Create temp table 
	CREATE TABLE #temp_BalancesSummary(
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
		#temp_BalancesSummary( --temp table name
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
		'BalancesSummary' AS TableName,
		 CAST(GETDATE() AS DATE) AS TestRunDate,
		'Product Id Number Count' AS TestName,
		COUNT(DISTINCT productId) AS ActualResult,
		1500 AS ExpectedResult,
		(COUNT(DISTINCT productId) - 1500) AS Deviation,
		CAST(GETDATE() AS DATE) AS CreatedOn,
		'[CapstoneDB].[dbo].[BI_Health_BalancesSummary]' AS CreatedBy,
		NULL AS ModifiedOn,
		NULL AS ModifiedBy
	FROM 
		BI_Feed.dbo.BI_BDA_BalancesSummary with (nolock); -- choose table from BI_feed

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
		#temp_BalancesSummary; --temp table 

	DROP TABLE #temp_BalancesSummary;

	SET NOCOUNT OFF;
END
