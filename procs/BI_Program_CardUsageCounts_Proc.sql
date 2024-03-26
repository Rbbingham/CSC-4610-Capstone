USE [CapstoneDB]
GO

/******************************************************************************
	
	CREATOR:	Carlos Escudero

	CREATED:	2024/02/08

	PURPOSE:	Program ID Count Procedure.

******************************************************************************/

CREATE OR ALTER PROCEDURE [dbo].[BI_Health_BI_Program_CardUsageCounts]
AS 
BEGIN
	SET NOCOUNT ON;

	DECLARE @temp_BI_Program_CardUsageCounts AS [dbo].[TnTech_TableType];

	-- run normal query into temp table
	INSERT INTO 
		@temp_BI_Program_CardUsageCounts(
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
		'BI_Program_CardUsageCounts' AS TableName,
		 CAST(GETDATE() AS DATE) AS TestRunDate,
		'Program ID Count' AS TestName,
		COUNT(DISTINCT ProgramId) AS ActualResult,
		3200 AS ExpectedResult,
		(COUNT(DISTINCT ProgramId) - 3200) AS Deviation,
		NULL AS RiskScore,
		GETDATE() AS CreatedOn,
		'[CapstoneDB].[dbo].[BI_Health_BI_Program_CardUsageCounts]' AS CreatedBy,
		NULL AS ModifiedOn,
		NULL AS ModifiedBy
	FROM 
		BI_Feed.dbo.BI_Program_CardUsageCounts with (nolock); -- choose table from BI_feed

	--Upload data into CapstoneDB.dbo.BI_HealthResults
	EXEC [dbo].[BI_InsertTestResult] @Table = @temp_BI_Program_CardUsageCounts;

	SET NOCOUNT OFF;
END;
GO