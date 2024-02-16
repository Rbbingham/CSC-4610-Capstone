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

	IF OBJECT_ID('tempdb.dbo.temp_BI_ProductInclusionTables') IS NOT NULL BEGIN
		DROP TABLE #temp_BI_ProductInclusionTables
	END;

	--Create temp table 
	CREATE TABLE #temp_BI_ProductInclusionTables(
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

	-- runs Merchant group test
	INSERT INTO 
		#temp_BI_ProductInclusionTables(
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
		'BI_ProductInclusionTables' AS TableName,
		 CAST(GETDATE() AS DATE) AS TestRunDate,
		'Check merchant groups' AS TestName,
		COUNT(DISTINCT MerchantGroup) AS ActualResult,
		60 AS ExpectedResult,
		(COUNT(DISTINCT MerchantGroup) - 60) AS Deviation,
		CAST(GETDATE() AS DATE) AS CreatedOn,
		'[CapstoneDB].[dbo].[BI_Health_BI_ProductInclusionTables]' AS CreatedBy,
		NULL AS ModifiedOn,
		NULL AS ModifiedBy
	FROM 
		BI_Feed.dbo.BI_ProductInclusionTables with (nolock); --choose table from BI_feed

	INSERT INTO
		#temp_BI_ProductInclusionTables--temp table name
	SELECT
		 'BI_ProductInclusionTables' AS TableName,
		 CAST(GETDATE() AS DATE) AS TestRunDate,
		'Count Product IDs' AS TestName,
		COUNT(DISTINCT ProductID) AS ActualResult,
		275 AS ExpectedResult,
		(COUNT(DISTINCT ProductID) - 275) AS Deviation,
		CAST(GETDATE() AS DATE) AS CreatedOn,
		'[CapstoneDB].[dbo].[BI_Health_BI_ProductInclusionTables]' AS CreatedBy,
		NULL AS ModifiedOn,
		NULL AS ModifiedBy
	FROM 
		BI_Feed.dbo.BI_ProductInclusionTables with (nolock); --choose table from BI_feed

	--Upload data into CapstoneDB.dbo.TnTech_TestResults
	INSERT INTO 
		CapstoneDB.dbo.TnTech_TestResults(
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
		#temp_BI_ProductInclusionTables;

	DROP TABLE #temp_BI_ProductInclusionTables;

	SET NOCOUNT OFF;
END;
GO