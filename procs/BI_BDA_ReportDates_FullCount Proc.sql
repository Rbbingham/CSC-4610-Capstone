USE [CapstoneDB]
GO

/******************************************************************************
	
	CREATOR:	Collin Cunningham, Grant Tarver

	CREATED:	2024/03/22

	PURPOSE:	Ensures that every record is available.

******************************************************************************/

CREATE OR ALTER PROCEDURE [dbo].[BI_Health_BI_BDA_ReportDates_FullCount]
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
			CreatedOn,
			CreatedBy,
			ModifiedOn,
			ModifiedBy)
	SELECT
		'BI_BDA_ReportDates' AS TableName,
		 CAST(GETDATE() AS DATE) AS TestRunDate,
		'Full Count' AS TestName,
		COUNT(id) AS ActualResult,
		DATEDIFF(DAY, CONVERT(DATE, '2016-12-31'), CAST(GETDATE() AS DATE)) AS ExpectedResult,
		(COUNT(id) - DATEDIFF(DAY, CONVERT(DATE, '2016-12-31'), CAST(GETDATE() AS DATE))) AS Deviation,
		CAST(GETDATE() AS DATE) AS CreatedOn,
		'[CapstoneDB].[dbo].[BI_Health_BI_BDA_ReportDates_FullCount]' AS CreatedBy,
		NULL AS ModifiedOn,
		NULL AS ModifiedBy
	FROM 
		BI_Feed.dbo.BI_BDA_ReportDates with (nolock) --choose table from BI_feed
	-- upload data into CapstoneDB.dbo.BI_HealthResults
	EXEC [dbo].[BI_InsertTestResult] @Table = @temp_BI_BDA_ReportDates;

	SET NOCOUNT OFF;
END;
GO