USE [CapstoneDB]
GO

/******************************************************************************
	
	CREATOR:	Collin Cunningham, Grant Tarver

	CREATED:	2024/03/22

	PURPOSE:	Ensures that 1 record is available from the previous day.

******************************************************************************/

CREATE OR ALTER PROCEDURE [dbo].[BI_Health_BI_BDA_ReportDates_ReportCount]
AS 
BEGIN
	SET NOCOUNT ON;

	-- create temp table 
	DECLARE @temp_BI_BDA_ReportDates AS [dbo].[TnTech_TableType];

	-- run normal query into temp table
	INSERT INTO 
		@temp_BI_BDA_ReportDates(
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
		'BI_BDA_ReportDates' AS TableName,
		 CAST(GETDATE() AS DATE) AS TestRunDate,
		'Report Count' AS TestName,
		COUNT(id) AS ActualResult,
		1 AS ExpectedResult,
		(COUNT(id) - 1) AS Deviation,
		dbo.CalculateRiskScore(COUNT(id), 1) AS RiskScore,
		CAST(GETDATE() AS DATE) AS CreatedOn,
		'[CapstoneDB].[dbo].[BI_Health_BI_BDA_ReportDates_ReportCount]' AS CreatedBy,
		NULL AS ModifiedOn,
		NULL AS ModifiedBy
	FROM 
		BI_Feed.dbo.BI_BDA_ReportDates with (nolock) --choose table from BI_feed
	WHERE
		reportDate = CAST(DATEADD(day, -1, GETDATE()) AS DATE);
	-- upload data into CapstoneDB.dbo.BI_HealthResults
	EXEC [dbo].[BI_InsertTestResult] @Table = @temp_BI_BDA_ReportDates;

	SET NOCOUNT OFF;
END;
GO