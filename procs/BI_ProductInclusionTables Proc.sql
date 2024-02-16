-- =============================================
-- Author:    Carlos Escudero  
-- Create Date: 2/2/2024
-- Description: Merchant Group & ProductID Count Test
-- =============================================
Use CapstoneDB
GO

Create Or ALTER Procedure[dbo].[BI_Health_BI_ProductInclusionTables] --name of procedure
AS 

BEGIN

SET NOCOUNT ON;

--drop the table 
IF OBJECT_ID('tempdb.dbo.temp_BI_ProductInclusionTables') IS NOT NULL BEGIN
	DROP TABLE #temp_BI_ProductInclusionTables
END;
--Create temp table 
CREATE TABLE #temp_BI_ProductInclusionTables(
	[CreatedBy][varchar](256)NOT NULL,
	[TestRunDate][date]NOT NULL,
	[TableName][varchar](256) NOT NULL,
	[TestName][varchar](256) NOT NULL,
	[ActualResult] [bigint] NOT NULL,
	[ExpectedResult] [bigint] NULL,
)
-- runs Merhcant group test
INSERT INTO 
	#temp_BI_ProductInclusionTables(
	CreatedBy,
	TestRunDate, 
	TableName,
	TestName,
	ActualResult,
	ExpectedResult)--temp table name
SELECT
	'[CapstoneDB].[dbo].[BI_Health_BI_ProductInclusionTables]',
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
	'[CapstoneDB].[dbo].[BI_Health_BI_ProductInclusionTables]',
	 Cast(GETDATE() AS DATE),
	'BI_ProductInclusionTables',--name of table
	'Count Product IDs',-- name of test
	count(DISTINCT ProductID ),--actual result
	 275-- expected result 
FROM 
	BI_Feed.dbo.BI_ProductInclusionTables with(nolock); --choose table from BI_feed

--Altering temp table to add deviation column
	ALTER TABLE #temp_BI_ProductInclusionTables ADD Deviation INT;

--Updates the Deviation column with Actual-Expected
	UPDATE #temp_BI_ProductInclusionTables
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
	#temp_BI_ProductInclusionTables;--temp table 

-- Final, drop the temporary table
DROP TABLE #temp_BI_ProductInclusionTables; -- Final, drop the temporary table

SET NOCOUNT OFF;

END