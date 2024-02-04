-- =============================================
-- Author:      Carlos Escudero
-- Create Date: 02/02/2024
-- Description: Counts the number of Vins in the Toyota_Distribution
-- =============================================
Use CapstoneDB
GO

Create Procedure [dbo].[VIN_Count_Toyota_Distribution] (
	@param1 int,
	@param2 varchar(256),
	@param3 date
	)
AS 

BEGIN

SET NOCOUNT ON;

IF OBJECT_ID('#temp_Toyota_Distribution') IS NOT NULL BEGIN
	DROP TABLE #temp_Toyota_Distribution
END;

--Create temp table 
CREATE TABLE #temp_Toyota_Distribution(
	[TestRunDate][date]NOT NULL,
	[TableName][varchar](256) NOT NULL,
	[TestName][varchar](256) NOT NULL,
	[ActualResult] [bigint] NOT NULL,
	[ExpectedResult] [bigint] NULL,
)

-- run normal query into temp table
INSERT INTO 
	#temp_Toyota_Distribution
SELECT
	 Cast(GETDATE() AS DATE),
	'Toyota_Distribution',
	'VIN Count',
	count(distinct Vin),
	13000
FROM 
	BI_Feed.dbo.Toyota_Distribution with(nolock);

--Upload data into CapstoneDB.dbo.TnTech_TestResults
INSERT INTO 
	CapstoneDB.dbo.TnTech_TestResults(TestRunDate,TestName,TableName,ActualResult, ExpectedResult,Completed)
SELECT
	TestRunDate,TestName,TableName, ActualResult,ExpectedResult,1
FROM 
	#temp_Toyota_Distribution;

-- Final, drop the temporary table
DROP TABLE #temp_Toyota_Distribution; -- Final, drop the temporary table

SET NOCOUNT OFF;

END