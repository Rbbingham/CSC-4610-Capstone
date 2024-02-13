-- =============================================
-- Author:    Carlos Escudero  
-- Create Date: 2/2/24
-- Description: ID Count for BI_BDA_UniqueProducts
-- =============================================
Use CapstoneDB
GO

Create or Alter Procedure[dbo].[BI_Health_BI_BDA_UniqueProducts] --name of procedure
AS 

BEGIN

SET NOCOUNT ON;

IF OBJECT_ID('tempdb.dbo.temp_BI_BDA_UniqueProducts') IS NOT NULL BEGIN
	DROP TABLE #temp_BI_BDA_UniqueProducts
END;

--Create temp table 
CREATE TABLE #temp_BI_BDA_UniqueProducts(
	[TestRunDate][date]NOT NULL,
	[TableName][varchar](256) NOT NULL,
	[TestName][varchar](256) NOT NULL,
	[ActualResult] [bigint] NOT NULL,
	[ExpectedResult] [bigint] NULL,
)
-- run normal query into temp table
INSERT INTO 
	#temp_BI_BDA_UniqueProducts(TestRunDate, TableName,TestName,ActualResult,ExpectedResult)--temp table name
SELECT
	 Cast(GETDATE() AS DATE),
	'BI_BDA_UniqueProducts',--name of table
	'ID Count',-- name of test
	count(distinct ID),--actual result
	3850 -- expected result 
FROM 
	BI_Feed.dbo.BI_BDA_UniqueProducts with(nolock); --choose table from BI_feed
--Upload data into CapstoneDB.dbo.TnTech_TestResults
INSERT INTO 
	CapstoneDB.dbo.TnTech_TestResults(TestRunDate,TestName,TableName,ActualResult, ExpectedResult)
SELECT
	TestRunDate,TestName,TableName, ActualResult,ExpectedResult
FROM 
	#temp_BI_BDA_UniqueProducts;--temp table 

-- Final, drop the temporary table
DROP TABLE #temp_BI_BDA_UniqueProducts; -- Final, drop the temporary table

SET NOCOUNT OFF;

END