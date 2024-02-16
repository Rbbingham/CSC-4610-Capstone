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

	IF OBJECT_ID('tempdb.dbo.#temp_BI_BDA_UniqueProducts') IS NOT NULL 
	BEGIN
		DROP TABLE #temp_BI_BDA_UniqueProducts
	END;

	--Create temp table 
	CREATE TABLE #temp_BI_BDA_UniqueProducts(
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
		#temp_BI_BDA_UniqueProducts(
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
		'BI_BDA_UniqueProducts' AS TableName,
		 CAST(GETDATE() AS DATE) AS TestRunDate,
		'ID Count' AS TestName,
		COUNT(DISTINCT ID) AS ActualResult,
		3850 AS ExpectedResult,
		(COUNT(DISTINCT ID) - 3850) AS Deviation,
		CAST(GETDATE() AS DATE) AS CreatedOn,
		'[CapstoneDB].[dbo].[BI_Health_BI_BDA_UniqueProducts]' AS CreatedBy,
		NULL AS ModifiedOn,
		NULL AS ModifiedBy
	FROM 
		BI_Feed.dbo.BI_BDA_UniqueProducts with (nolock); -- choose table from BI_feed

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
		#temp_BI_BDA_UniqueProducts;

	DROP TABLE #temp_BI_BDA_UniqueProducts;

	SET NOCOUNT OFF;
END;
GO