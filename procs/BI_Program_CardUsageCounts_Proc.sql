Use CapstoneDB
-- =============================================
-- Author:Carlos Escudero   
-- Create Date: 2/8/24
-- Description: Program ID Count Procedure 
-- =============================================

GO

CREATE OR ALTER Procedure[dbo].[BI_Health_BI_Program_CardUsageCounts] --name of procedure
AS 

BEGIN

SET NOCOUNT ON;

IF OBJECT_ID('tempdb.dbo.temp_BI_Program_CardUsageCounts') IS NOT NULL BEGIN
	DROP TABLE #temp_BI_Program_CardUsageCounts
END;

--Create temp table 
CREATE TABLE #temp_BI_Program_CardUsageCounts(
	[CreatedBy][varchar](256) NOT NULL,
	[TestRunDate][date]NOT NULL,
	[TableName][varchar](256) NOT NULL,
	[TestName][varchar](256) NOT NULL,
	[ActualResult] [bigint] NOT NULL,
	[ExpectedResult] [bigint] NULL,
)
-- run normal query into temp table
INSERT INTO 
--temp table name
#temp_BI_Program_CardUsageCounts(
	CreatedBy,
	TestRunDate,
	TableName,
	TestName,
	ActualResult,
	ExpectedResult)
SELECT
	'[CapstoneDB].[dbo].[BI_Health_BI_Program_CardUsageCounts]',
	 Cast(GETDATE() AS DATE),
	'BI_Program_CardUsageCounts',--name of table
	'Program ID Count',-- name of test
	count(distinct ProgramId),--actual result
	 3200-- expected result 
FROM 
	BI_Feed.dbo.BI_Program_CardUsageCounts with(nolock); --choose table from BI_feed

--Altering temp table to add deviation column
	ALTER TABLE #temp_BI_Program_CardUsageCounts ADD Deviation INT;

--Updates the Deviation column with Actual-Expected
	UPDATE #temp_BI_Program_CardUsageCounts
	SET Deviation = ActualResult - ExpectedResult;

--Upload data into CapstoneDB.dbo.TnTech_TestResults
INSERT INTO 
	CapstoneDB.dbo.BI_HealthResults(
	CreatedBy,
	TestRunDate,
	TestName,
	TableName,
	ActualResult, 
	ExpectedResult,
	Deviation)
SELECT
	CreatedBy,
	TestRunDate,
	TestName,
	TableName, 
	ActualResult,
	ExpectedResult,
	Deviation
FROM 
	#temp_BI_Program_CardUsageCounts;--temp table 

-- Final, drop the temporary table
DROP TABLE #temp_BI_Program_CardUsageCounts; -- Final, drop the temporary table

SET NOCOUNT OFF;

END
