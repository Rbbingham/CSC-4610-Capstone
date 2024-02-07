-- =============================================
-- Author:    Carlos Escudero  
-- Create Date: 2/2/2024
-- Description: Merchant Group & ProductID Count Test
-- =============================================
Use CapstoneDB
GO

Create Procedure[dbo].[BI_ProductInclusionTables_Procedures] --name of procedure
AS 

BEGIN

SET NOCOUNT ON;
--Create temp table 
CREATE TABLE #temp_BI_ProductInclusionTables(
	[TestRunDate][date]NOT NULL,
	[TableName][varchar](256) NOT NULL,
	[TestName][varchar](256) NOT NULL,
	[ActualResult] [bigint] NOT NULL,
	[ExpectedResult] [bigint] NULL,
)
-- runs Merhcant group test
INSERT INTO 
	#temp_BI_ProductInclusionTables--temp table name
SELECT
	 Cast(GETDATE() AS DATE),
	'BI_ProductInclusionTables',--name of table
	'Check merchant groups',-- name of test
	count(DISTINCT MerchantGroup),--actual result
	60 -- expected result 
FROM 
	BI_Feed.dbo.BI_ProductInclusionTables with(nolock); --choose table from BI_feed

-- runs
INSERT INTO 
	#temp_BI_ProductInclusionTables--temp table name
SELECT
	 Cast(GETDATE() AS DATE),
	'BI_ProductInclusionTables',--name of table
	'Count Product IDs',-- name of test
	count(DISTINCT ProductID ),--actual result
	 275-- expected result 
FROM 
	BI_Feed.dbo.BI_ProductInclusionTables with(nolock); --choose table from BI_feed


--Upload data into CapstoneDB.dbo.TnTech_TestResults
INSERT INTO 
	CapstoneDB.dbo.TnTech_TestResults(TestRunDate,TestName,TableName,ActualResult, ExpectedResult,Completed)
SELECT
	TestRunDate,TestName,TableName, ActualResult,ExpectedResult,1
FROM 
	#temp_BI_ProductInclusionTables;--temp table 

-- Final, drop the temporary table
DROP TABLE #temp_BI_ProductInclusionTables; -- Final, drop the temporary table

SET NOCOUNT OFF;

END