USE [CapstoneDB]
GO

/******************************************************************************
	
	CREATOR:	Robert Bingham

	CREATED:	02/15/2024

	PURPOSE:	Ensures that one record is insert at the 1st of the month.

******************************************************************************/

CREATE OR ALTER PROCEDURE [dbo].[BI_Health_VincentSLAAAgregate]
AS 
BEGIN
	SET NOCOUNT ON;

	-- create temp table
	DECLARE @temp_BI_VincentSLAAAgregate AS [dbo].[TnTech_TableType];

	-- run normal query into temp table
	INSERT INTO 
		@temp_BI_VincentSLAAAgregate(
			TableName,
			TestRunDate, 
			TestName,
			ActualResult,
			ExpectedResult,
			Deviation,
			RiskScore,
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
		[dbo].[CalculateRiskScore](COUNT(DISTINCT [Month]), 1) AS RiskScore,
		GETDATE() AS CreatedOn,
		'[CapstoneDB].[dbo].[BI_Health_VincentSLAAAgregate]' AS CreatedBy,
		NULL AS ModifiedOn,
		NULL AS ModifiedBy
	FROM 
		[BI_Feed].[dbo].[BI_VincentSLAAggregate] with (nolock)
	WHERE
		YEAR([Month]) = YEAR(GETDATE()) AND
		MONTH([Month]) = MONTH(GETDATE()) AND
		DAY([Month]) = '1';

	-- upload data into CapstoneDB.dbo.BI_HealthResults
	EXEC [dbo].[BI_InsertTestResult] @Table = @temp_BI_VincentSLAAAgregate;

	SET NOCOUNT OFF;
END;
GO