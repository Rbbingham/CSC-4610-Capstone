-- =============================================
-- Author: Lorenzo Abellanosa      
-- Create Date: 2/12/2024
-- Description: Created Test run procedure for CardCounts table 
-- =============================================
Use CapstoneDB
GO

CREATE OR ALTER Procedure[dbo].[BI_Health_CardCount] --name of procedure
AS 

BEGIN

SET NOCOUNT ON;

IF OBJECT_ID('tempdb.dbo.temp_CardCount') is not null 
begin 
	Drop Table #temp_CardCount --temp table 
end;

--Create temp table 
CREATE TABLE #temp_CardCount(
	[CreatedBy][varchar](256) NOT NULL,
	[TestRunDate][date]NOT NULL,
	[TableName][varchar](256) NOT NULL,
	[TestName][varchar](256) NOT NULL,
	[ActualResult] [bigint] NOT NULL,
	[ExpectedResult] [bigint] NULL,
)
-- run normal query into temp table
INSERT INTO 
	#temp_CardCount(
	CreatedBy,
	TestRunDate,
	TableName,
	TestName,
	ActualResult,
	ExpectedResult)--temp table name
SELECT
	 '[CapstoneDB].[dbo].[BI_Health_CardCount]', 
	 Cast(GETDATE() AS DATE),
	'CardCounts',--name of table
	'CountRecords',-- name of test
	count(distinct productId  ),--actual result
	3800 -- expected result

FROM 
	BI_Feed.dbo.CardCounts with(nolock); --choose table from BI_feed
ALTER TABLE #temp_CardCount ADD Deviation Int; -- Adding Deviation to the temporary table
UPDATE #temp_CardCount
SET Deviation = ActualResult - ExpectedResult; -- Updating Deviation to the deviation
--Upload data into CapstoneDB.dbo.TnTech_TestResults
INSERT INTO 
	CapstoneDB.dbo.BI_HealthResults(
	CreatedBy,
	TestRunDate,
	TableName,
	TestName,
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
	#temp_CardCount;--temp table 

-- Final, drop the temporary table
DROP TABLE #temp_CardCount; -- Final, drop the temporary table

SET NOCOUNT OFF;

END
