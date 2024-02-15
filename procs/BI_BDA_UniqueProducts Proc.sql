/******************************************************************************
	
	CREATOR:	Carlos Escudero

	CREATED:	2024/02/02

	PURPOSE:	ID Count for BI_BDA_UniqueProducts.

******************************************************************************/

USE [CapstoneDB]
GO

CREATE OR ALTER PROCEDURE [dbo].[BI_Health_BI_BDA_UniqueProducts]
AS 
BEGIN
	SET NOCOUNT ON;

	IF OBJECT_ID('tempdb.dbo.temp_BI_BDA_UniqueProducts') IS NOT NULL 
	BEGIN
		DROP TABLE #temp_BI_BDA_UniqueProducts
	END;

	--Create temp table 
	CREATE TABLE #temp_BI_BDA_UniqueProducts(
		[CreatedBy][varchar](256) NOT NULL,
		[TestRunDate][date]NOT NULL,
		[TableName][varchar](256) NOT NULL,
		[TestName][varchar](256) NOT NULL,
		[ActualResult] [bigint] NOT NULL,
		[ExpectedResult] [bigint] NULL,
	)
	-- run normal query into temp table
	INSERT INTO 
		#temp_BI_BDA_UniqueProducts(
		CreatedBy,
		TestRunDate, 
		TableName,
		TestName,
		ActualResult,
		ExpectedResult)--temp table name
	SELECT
		'[CapstoneDB].[dbo].[BI_Health_BI_BDA_UniqueProducts]',
		 Cast(GETDATE() AS DATE),
		'BI_BDA_UniqueProducts',--name of table
		'ID Count',-- name of test
		count(distinct ID),--actual result
		3850 -- expected result 
	FROM 
		BI_Feed.dbo.BI_BDA_UniqueProducts with(nolock); --choose table from BI_feed
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
		#temp_BI_BDA_UniqueProducts;

	DROP TABLE #temp_BI_BDA_UniqueProducts;

	SET NOCOUNT OFF;
END;
GO