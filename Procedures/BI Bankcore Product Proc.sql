-- =============================================
-- Author:  Carlos Escudero	    
-- Create Date: 2/2/2024
-- Description: Counts the number of Product Id's
-- =============================================
Use CapstoneDB
GO

CREATE or ALTER PROCEDURE [dbo].[Product_ID_Count_BI_BankCore_Products] --name of procedure
AS 

BEGIN

SET NOCOUNT ON;
--Create temp table 
CREATE TABLE #temp_BI_BankCore_Products(
	[TestRunDate][date]NOT NULL,
	[TableName][varchar](256) NOT NULL,
	[TestName][varchar](256) NOT NULL,
	[ActualResult] [bigint] NOT NULL,
	[ExpectedResult] [bigint] NULL,
)
-- run normal query into temp table
INSERT INTO 
	#temp_BI_BankCore_Products(TestRunDate, TableName,TestName,ActualResult,ExpectedResult)--temp table name
SELECT
	 Cast(GETDATE() AS DATE),
	'BI_BankCore_Products',--name of table
	'Product ID Count',-- name of test
	count(distinct ProductId),--actual result
	5 -- expected result 
FROM 
	BI_Feed.dbo.BI_BankCore_Products with(nolock); --choose table from BI_feed

--Upload data into CapstoneDB.dbo.TnTech_TestResults
INSERT INTO 
	CapstoneDB.dbo.TnTech_TestResults(TestRunDate,TestName,TableName,ActualResult, ExpectedResult)
SELECT
	TestRunDate,TestName,TableName, ActualResult,ExpectedResult
FROM 
	#temp_BI_BankCore_Products;--temp table 

-- Final, drop the temporary table
DROP TABLE #temp_BI_BankCore_Products; -- Final, drop the temporary table

SET NOCOUNT OFF;

END
