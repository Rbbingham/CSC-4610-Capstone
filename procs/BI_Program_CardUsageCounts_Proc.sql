/******************************************************************************
	
	CREATOR:	Carlos Escudero

	CREATED:	2024/02/08

	PURPOSE:	Program ID Count Procedure.

******************************************************************************/

USE [CapstoneDB]
GO

CREATE OR ALTER PROCEDURE [dbo].[BI_Health_BI_Program_CardUsageCounts]
AS 
BEGIN
	SET NOCOUNT ON;

	IF OBJECT_ID('tempdb.dbo.temp_BI_Program_CardUsageCounts') IS NOT NULL
	BEGIN
		DROP TABLE #temp_BI_Program_CardUsageCounts
	END;

	--Create temp table 
	CREATE TABLE #temp_BI_Program_CardUsageCounts(
		[CreatedBy][varchar](256) NOT NULL,
		[TestRunDate][date]NOT NULL,
		[TableName][varchar](256) NOT NULL,
		[TestName][varchar](256) NOT NULL,
		[ActualResult] [bigint] NOT NULL,
		[ExpectedResult] [bigint] NULL,
	)
	-- run normal query into temp table
	INSERT INTO 
	#temp_BI_Program_CardUsageCounts(
		CreatedBy,
		TestRunDate,
		TableName,
		TestName,
		ActualResult,
		ExpectedResult)
	SELECT
		'[CapstoneDB].[dbo].[BI_Health_BI_Program_CardUsageCounts]',
		 Cast(GETDATE() AS DATE),
		'BI_Program_CardUsageCounts',--name of table
		'Program ID Count',-- name of test
		count(distinct ProgramId),--actual result
		 3200-- expected result 
	FROM 
		BI_Feed.dbo.BI_Program_CardUsageCounts with(nolock); --choose table from BI_feed
	--Upload data into CapstoneDB.dbo.TnTech_TestResults
	INSERT INTO 
		CapstoneDB.dbo.TnTech_TestResults(
		CreatedBy,
		TestRunDate,
		TestName,
		TableName,
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
		#temp_BI_Program_CardUsageCounts;--temp table 

	DROP TABLE #temp_BI_Program_CardUsageCounts;

	SET NOCOUNT OFF;
END;
GO
