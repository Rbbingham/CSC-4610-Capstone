/******************************************************************************
	
	CREATOR:	Robert Bingham

	CREATED:	02/15/2024

	PURPOSE:	

******************************************************************************/

Use [CapstoneDB]
GO

CREATE OR ALTER PROCEDURE [dbo].[BI_Health_VincentSLAAAgregate]
AS 
BEGIN
	SET NOCOUNT ON;

	IF OBJECT_ID('tempdb.dbo.#temp_BI_VincentSLAAAgregate') IS NOT NULL
	BEGIN
		DROP TABLE #temp_BI_VincentSLAAAgregate
	END;

	--Create temp table 
	CREATE TABLE #temp_BI_VincentSLAAAgregate(
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
		#temp_BI_VincentSLAAAgregate( --temp table name
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
		'BI_VincentSLAAAgregate' AS TableName,
		 CAST(GETDATE() AS DATE) AS TestRunDate,
		'Get Record per Month' AS TestName,
		COUNT(DISTINCT [Month]) AS ActualResult,
		1 AS ExpectedResult,
		(COUNT(DISTINCT [Month]) - 1) AS Deviation,
		CAST(GETDATE() AS DATE) AS CreatedOn,
		'[CapstoneDB].[dbo].[BI_Health_VincentSLAAAgregate]' AS CreatedBy,
		NULL AS ModifiedOn,
		NULL AS ModifiedBy
	FROM 
		[BI_Feed].[dbo].[BI_VincentSLAAggregate] with (nolock)
	WHERE
		YEAR([Month]) = YEAR(GETDATE()) AND
		MONTH([Month]) = MONTH(GETDATE()) AND
		DAY([Month]) = '1';

	--Upload data into CapstoneDB.dbo.TnTech_TestResults
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
		#temp_BI_VincentSLAAAgregate;

	DROP TABLE #temp_BI_VincentSLAAAgregate;

	SET NOCOUNT OFF;
END
