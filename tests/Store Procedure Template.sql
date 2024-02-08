-- =============================================
-- Author:      
-- Create Date: 
-- Description: 
-- =============================================
Use CapstoneDB
GO

CREATE OR ALTER Procedure[dbo].[] --name of procedure
AS 

BEGIN

SET NOCOUNT ON;
--Create temp table 
CREATE TABLE #temp_(
	[TestRunDate][date]NOT NULL,
	[TableName][varchar](256) NOT NULL,
	[TestName][varchar](256) NOT NULL,
	[ActualResult] [bigint] NOT NULL,
	[ExpectedResult] [bigint] NULL,
)
-- run normal query into temp table
INSERT INTO 
	--temp table name
SELECT
	 Cast(GETDATE() AS DATE),
	'',--name of table
	'',-- name of test
	count(distinct ),--actual result
	 -- expected result 
FROM 
	BI_Feed.dbo. with(nolock); --choose table from BI_feed
--Upload data into CapstoneDB.dbo.TnTech_TestResults
INSERT INTO 
	CapstoneDB.dbo.TnTech_TestResults(TestRunDate,TestName,TableName,ActualResult, ExpectedResult)
SELECT
	TestRunDate,TestName,TableName, ActualResult,ExpectedResult
FROM 
	;--temp table 

-- Final, drop the temporary table
DROP TABLE ; -- Final, drop the temporary table

SET NOCOUNT OFF;

END
