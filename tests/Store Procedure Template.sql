-- =============================================
-- Author:      
-- Create Date: 
-- Description: 
-- =============================================
Use CapstoneDB
GO

CREATE OR ALTER Procedure[dbo].[BI_Health_] --name of procedure
AS 

BEGIN

SET NOCOUNT ON;

IF OBJECT_ID('tempdb.dbo.TEMP_TABLE_NAME') is not null 
begin 
	Drop Table  --temp table 
end;

--Create temp table 
CREATE TABLE #temp_(
	[CreatedBy][varchar](256) NOT NULL,
	[TestRunDate][date]NOT NULL,
	[TableName][varchar](256) NOT NULL,
	[TestName][varchar](256) NOT NULL,
	[ActualResult] [bigint] NOT NULL,
	[ExpectedResult] [bigint] NULL,
)
-- run normal query into temp table
INSERT INTO 
	#temp_ --temp table name
	(CreatedBy,
	TestRunDate, 
	TableName,
	TestName,
	ActualResult,
	ExpectedResult)
SELECT
	 '[CapstoneDB].[dbo].[BI_Health_PROCEDURE_NAME]', -- CreatedBy
	 Cast(GETDATE() AS DATE), -- TestRunDate
	'',--name of table
	'',-- name of test
	count(distinct ),--actual result
	 -- expected result 
FROM 
	BI_Feed.dbo. with(nolock); --choose table from BI_feed

--Upload data into CapstoneDB.dbo.TnTech_TestResults
INSERT INTO 
	CapstoneDB.dbo.TnTech_TestResults
	(Createdby,
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
	;--temp table 

-- Final, drop the temporary table
DROP TABLE ; -- Final, drop the temporary table

SET NOCOUNT OFF;

END
