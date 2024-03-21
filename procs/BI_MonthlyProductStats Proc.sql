USE [CapstoneDB]
GO

/******************************************************************************
	
	CREATOR:	Collin Cunningham

	CREATED:	2/12/2024

	PURPOSE:	ID Count test for BI_MonthlyProductStats table.

	MODIFICATIONS:		
	2/19/2024	Collin Cunningham	Updated result table to BI_HealthResults

******************************************************************************/

CREATE OR ALTER PROCEDURE [dbo].[BI_Health_BI_MonthlyProductStats]
AS 
BEGIN
	SET NOCOUNT ON;

	-- create temp table 
	DECLARE @temp_BI_MonthlyProductStats AS [dbo].[TnTech_TableType];

	-- run normal query into temp table
	INSERT INTO 
		@temp_BI_MonthlyProductStats(
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
		'BI_MonthlyProductStats' AS TableName,
		CAST(GETDATE() AS DATE) AS TestRunDate,
		'ProductId Count' AS TestName,
		COUNT(DISTINCT [ProductId]) AS ActualResult,
		2000 AS ExpectedResult,
		(COUNT(DISTINCT [ProductId]) - 2000) AS Deviation,
		CAST(GETDATE() AS DATE) AS CreatedOn,
		'[CapstoneDB].[dbo].[BI_Health_BI_MonthlyProductStats]' AS CreatedBy,
		NULL AS ModifiedOn,
		NULL AS ModifiedBy
	FROM 
		BI_Feed.dbo.BI_MonthlyProductStats with(nolock);

	-- upload data into CapstoneDB.dbo.BI_HealthResults
	EXEC [dbo].[BI_InsertTestResult] @Table = @temp_BI_MonthlyProductStats;

	SET NOCOUNT OFF;
END;
GO