/******************************************************************************
	
	CREATOR:	Carlos Escudero

	CREATED:	2024/02/02

	PURPOSE:	Merchant Group & ProductID Count Test.

******************************************************************************/

USE [CapstoneDB]
GO

CREATE OR ALTER PROCEDURE [dbo].[BI_Health_BI_ProductInclusionTables]
AS 
BEGIN
	SET NOCOUNT ON;

	--drop the table 
	IF OBJECT_ID('tempdb.dbo.temp_BI_ProductInclusionTables') IS NOT NULL BEGIN
		DROP TABLE #temp_BI_ProductInclusionTables
	END;
	--Create temp table 
	CREATE TABLE #temp_BI_ProductInclusionTables(
		[CreatedBy][varchar](256)NOT NULL,
		[TestRunDate][date]NOT NULL,
		[TableName][varchar](256) NOT NULL,
		[TestName][varchar](256) NOT NULL,
		[ActualResult] [bigint] NOT NULL,
		[ExpectedResult] [bigint] NULL,
	)
	-- runs Merhcant group test
	INSERT INTO 
		#temp_BI_ProductInclusionTables(
		CreatedBy,
		TestRunDate, 
		TableName,
		TestName,
		ActualResult,
		ExpectedResult)--temp table name
	SELECT
		'[CapstoneDB].[dbo].[BI_Health_BI_ProductInclusionTables]',
		 Cast(GETDATE() AS DATE),
		'BI_ProductInclusionTables',--name of table
		'Check merchant groups',-- name of test
		count(DISTINCT MerchantGroup),--actual result
		60 -- expected result 
	FROM 
		BI_Feed.dbo.BI_ProductInclusionTables with (nolock); --choose table from BI_feed

	-- runs
	INSERT INTO 
		#temp_BI_ProductInclusionTables--temp table name
	SELECT
		'[CapstoneDB].[dbo].[BI_Health_BI_ProductInclusionTables]',
		 Cast(GETDATE() AS DATE),
		'BI_ProductInclusionTables',--name of table
		'Count Product IDs',-- name of test
		count(DISTINCT ProductID ),--actual result
		 275-- expected result 
	FROM 
		BI_Feed.dbo.BI_ProductInclusionTables with (nolock); --choose table from BI_feed

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
		#temp_BI_ProductInclusionTables;

	DROP TABLE #temp_BI_ProductInclusionTables;

	SET NOCOUNT OFF;
END;
GO