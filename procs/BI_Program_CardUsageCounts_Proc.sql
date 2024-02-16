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

	IF OBJECT_ID('tempdb.dbo.#temp_BI_Program_CardUsageCounts') IS NOT NULL
	BEGIN
		DROP TABLE #temp_BI_Program_CardUsageCounts
	END;

	--Create temp table 
	CREATE TABLE #temp_BI_Program_CardUsageCounts(
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
		#temp_BI_Program_CardUsageCounts(
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
		'BI_Program_CardUsageCounts' AS TableName,
		 CAST(GETDATE() AS DATE) AS TestRunDate,
		'Program ID Count' AS TestName,
		COUNT(DISTINCT ProgramId) AS ActualResult,
		3200 AS ExpectedResult,
		(COUNT(DISTINCT ProgramId) - 3200) AS Deviation,
		CAST(GETDATE() AS DATE) AS CreatedOn,
		'[CapstoneDB].[dbo].[BI_Health_BI_Program_CardUsageCounts]' AS CreatedBy,
		NULL AS ModifiedOn,
		NULL AS ModifiedBy
	FROM 
		BI_Feed.dbo.BI_Program_CardUsageCounts with (nolock); -- choose table from BI_feed

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
		#temp_BI_Program_CardUsageCounts;

	DROP TABLE #temp_BI_Program_CardUsageCounts;

	SET NOCOUNT OFF;
END;
GO
