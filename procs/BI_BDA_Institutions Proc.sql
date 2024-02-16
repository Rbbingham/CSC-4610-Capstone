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

--Altering temp table to add deviation column
	ALTER TABLE #temp_BI_BDA_Institutions ADD Deviation INT;

--Updates the Deviation column with Actual-Expected
	UPDATE #temp_BI_BDA_Institutions
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
	#temp_BI_BDA_Institutions;--temp table 

-- Final, drop the temporary table
DROP TABLE #temp_BI_BDA_Institutions; -- Final, drop the temporary table

SET NOCOUNT OFF;

END