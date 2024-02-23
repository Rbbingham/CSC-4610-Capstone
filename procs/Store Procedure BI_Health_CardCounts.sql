/******************************************************************************
	
	CREATOR:	Lorenzo Abellanosa

	CREATED:	2024/02/12

	PURPOSE:	Created Test run procedure for CardCounts table.

******************************************************************************/

USE [CapstoneDB]
GO

CREATE OR ALTER PROCEDURE [dbo].[BI_Health_CardCounts]
AS 
BEGIN
	SET NOCOUNT ON;

	IF OBJECT_ID('tempdb.dbo.#temp_CardCounts') IS NOT NULL
	BEGIN
		DROP TABLE #temp_CardCounts
	END;

	-- Create temp table 
	CREATE TABLE #temp_CardCounts(
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
		#temp_CardCounts(
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
		'BI_CardCounts' AS TableName,
		 CAST(GETDATE() AS DATE) AS TestRunDate,
		'Count of ProductID' AS TestName,
		COUNT(DISTINCT productId) AS ActualResult,
		3800 AS ExpectedResult,
		(COUNT(DISTINCT productId) - 3800) AS Deviation,
		CAST(GETDATE() AS DATE) AS CreatedOn,
		'[CapstoneDB].[dbo].[BI_Health_CardCounts]' AS CreatedBy,
		NULL AS ModifiedOn,
		NULL AS ModifiedBy
	FROM 
		BI_Feed.dbo.CardCounts with (nolock); --choose table from BI_feed

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
		#temp_CardCounts;

	DROP TABLE #temp_CardCounts;

	SET NOCOUNT OFF;
END;
GO