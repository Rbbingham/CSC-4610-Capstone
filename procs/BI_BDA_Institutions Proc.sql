-- =============================================
-- Author:   Carlos Escudero   
-- Create Date: 2/2/24
-- Description: 
-- =============================================
Use CapstoneDB
GO

Create OR ALTER Procedure[dbo].[BI_Health_BI_BDA_Institutions] --name of procedure
AS 

BEGIN

SET NOCOUNT ON;

IF OBJECT_ID('tempdb.dbo.temp_BI_BDA_Institutions') IS NOT NULL BEGIN
	DROP TABLE #temp_BI_BDA_Institutions
END;

--Create temp table 
CREATE TABLE #temp_BI_BDA_Institutions(
	[CreatedBy][varchar](256)NOT NULL,
	[TestRunDate][date]NOT NULL,
	[TableName][varchar](256) NOT NULL,
	[TestName][varchar](256) NOT NULL,
	[ActualResult] [bigint] NOT NULL,
	[ExpectedResult] [bigint] NULL,
)
-- run normal query into temp table
INSERT INTO 
	#temp_BI_BDA_Institutions (
	CreatedBy,
	TestRunDate, 
	TableName,
	TestName,
	ActualResult,
	ExpectedResult)--temp table name
SELECT
	'[CapstoneDB].[dbo].[BI_Health_BI_BDA_Institutions]',
	 Cast(GETDATE() AS DATE),
	'BI_BDA_Institutions',--name of table
	'Institution Count',-- name of test
	COUNT(distinct institutionId),--actual result
	20 -- expected result 
FROM 
	BI_Feed.dbo.BI_BDA_Institutions with(nolock); --choose table from BI_feed
--Upload data into CapstoneDB.dbo.TnTech_TestResults
INSERT INTO 
	CapstoneDB.dbo.TnTech_TestResults(
	CreatedBy,
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
	#temp_BI_BDA_Institutions;--temp table 

-- Final, drop the temporary table
DROP TABLE #temp_BI_BDA_Institutions; -- Final, drop the temporary table

SET NOCOUNT OFF;

END