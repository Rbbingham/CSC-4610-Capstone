/******************************************************************************
	
	CREATOR:	Lorenzo Abellanosa

	CREATED:	2024/02/12

	PURPOSE:	Created Test run procedure for CardCounts table.

******************************************************************************/

Use CapstoneDB
GO

CREATE OR ALTER PROCEDURE [dbo].[BI_Health_CardCount]
AS 
BEGIN
	SET NOCOUNT ON;

	IF OBJECT_ID('tempdb.dbo.temp_CardCount') IS NOT NULL
	BEGIN
		DROP TABLE #temp_CardCount
	END;

	--Create temp table 
	CREATE TABLE #temp_CardCount(
		[CreatedBy][varchar](256) NOT NULL,
		[TestRunDate][date]NOT NULL,
		[TableName][varchar](256) NOT NULL,
		[TestName][varchar](256) NOT NULL,
		[ActualResult] [bigint] NOT NULL,
		[ExpectedResult] [bigint] NULL,
	)
	-- run normal query into temp table
	INSERT INTO 
		#temp_CardCount(
		CreatedBy,
		TestRunDate,
		TableName,
		TestName,
		ActualResult,
		ExpectedResult)--temp table name
	SELECT
		 '[CapstoneDB].[dbo].[BI_Health_CardCount]', 
		 Cast(GETDATE() AS DATE),
		'CardCounts',--name of table
		'CountRecords',-- name of test
		count(distinct productId  ),--actual result
		3800 -- expected result

	FROM 
		BI_Feed.dbo.CardCounts with (nolock); --choose table from BI_feed
	ALTER TABLE #temp_CardCount ADD Deviation Int; -- Adding Deviation to the temporary table
	UPDATE #temp_CardCount
	SET Deviation = ActualResult - ExpectedResult; -- Updating Deviation to the deviation
	--Upload data into CapstoneDB.dbo.TnTech_TestResults
	INSERT INTO 
		CapstoneDB.dbo.TnTech_TestResults(
		CreatedBy,
		TestRunDate,
		TableName,
		TestName,
		ActualResult,
		ExpectedResult)
	SELECT
		CreatedBy,
		TestRunDate,
		TestName,
		TableName, 
		ActualResult,
		ExpectedResult
	FROM 
		#temp_CardCount;--temp table 

	DROP TABLE #temp_CardCount;

	SET NOCOUNT OFF;
END;
GO