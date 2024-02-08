Use CapstoneDB
-- =============================================
-- Author:Carlos Escudero   
-- Create Date: 2/8/24
-- Description: Program ID Count Procedure 
-- =============================================

GO

CREATE OR ALTER Procedure[dbo].[BI_Program_CardUsageCounts_Procedure] --name of procedure
AS 

BEGIN

SET NOCOUNT ON;
--Create temp table 
CREATE TABLE #temp_BI_Program_CardUsageCounts(
	[TestRunDate][date]NOT NULL,
	[TableName][varchar](256) NOT NULL,
	[TestName][varchar](256) NOT NULL,
	[ActualResult] [bigint] NOT NULL,
	[ExpectedResult] [bigint] NULL,
)
-- run normal query into temp table
INSERT INTO 
--temp table name
#temp_BI_Program_CardUsageCounts(TestRunDate,TableName,TestName,ActualResult,ExpectedResult)
SELECT
	 Cast(GETDATE() AS DATE),
	'BI_Program_CardUsageCounts',--name of table
	'Program ID Count',-- name of test
	count(distinct ProgramId),--actual result
	 3200-- expected result 
FROM 
	BI_Feed.dbo.BI_Program_CardUsageCounts with(nolock); --choose table from BI_feed
--Upload data into CapstoneDB.dbo.TnTech_TestResults
INSERT INTO 
	CapstoneDB.dbo.TnTech_TestResults(TestRunDate,TestName,TableName,ActualResult, ExpectedResult)
SELECT
	TestRunDate,TestName,TableName, ActualResult,ExpectedResult
FROM 
	#temp_BI_Program_CardUsageCounts;--temp table 

-- Final, drop the temporary table
DROP TABLE #temp_BI_Program_CardUsageCounts; -- Final, drop the temporary table

SET NOCOUNT OFF;

END
