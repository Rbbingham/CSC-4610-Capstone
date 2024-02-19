-- =============================================
-- Author:      Collin Cunningham
-- Create Date: 2/12/2024
-- Description: ID Count test for BI_MonthlyProductStats table

--Update 2/19/2024:Updated result table to BI_HealthResults
-- =============================================
Use CapstoneDB
GO

CREATE OR ALTER Procedure[dbo].[BI_Health_BI_MonthlyProductStats]
AS 

BEGIN
	SET NOCOUNT ON;

	DROP TABLE IF EXISTS #temp_BI_MonthlyProductStats;

	--Create temp table 
	CREATE TABLE #temp_BI_MonthlyProductStats(
		[CreatedBy][varchar](256) NOT NULL,
		[TestRunDate][date]NOT NULL,
		[TableName][varchar](256) NOT NULL,
		[TestName][varchar](256) NOT NULL,
		[ActualResult] [bigint] NOT NULL,
		[ExpectedResult] [bigint] NULL,
	)
	-- run normal query into temp table
	INSERT INTO 
		#temp_BI_MonthlyProductStats --temp table name
		(CreatedBy,
		TestRunDate, 
		TableName,
		TestName,
		ActualResult,
		ExpectedResult)
	SELECT
		 '[CapstoneDB].[dbo].[BI_Health_BI_MonthlyProductStats]', -- CreatedBy
		 Cast(GETDATE() AS DATE), -- TestRunDate
		'BI_MonthlyProductStats',--name of table
		'ID Count',-- name of test
		count(distinct ID),--actual result
		 2000 -- expected result 
	FROM 
		BI_Feed.dbo.BI_MonthlyProductStats with(nolock); --choose table from BI_feed

	--Upload data into CapstoneDB.dbo.BI_HealthResults
	INSERT INTO 
		CapstoneDB.dbo.BI_HealthResults
		(Createdby,
		TestRunDate,
		TestName,
		TableName,
		ActualResult, 
		ExpectedResult)
	SELECT
		CreatedBy,
		TestRunDate,
		TestName,
		TableName, 
		ActualResult,
		ExpectedResult
	FROM 
		#temp_BI_MonthlyProductStats;--temp table 

	-- Final, drop the temporary table
	DROP TABLE #temp_BI_MonthlyProductStats; -- Final, drop the temporary table

	SET NOCOUNT OFF;
END
