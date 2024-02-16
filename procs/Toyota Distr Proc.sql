-- =============================================
-- Author:      Carlos Escudero
-- Create Date: 02/02/2024
-- Description: Counts the number of Vins in the Toyota_Distribution
-- =============================================
Use CapstoneDB
GO

CREATE OR ALTER Procedure [dbo].[BI_Health_Toyota_Distribution] 
AS 

BEGIN

	SET NOCOUNT ON;

	IF OBJECT_ID('tempdb.dbo.temp_Toyota_Distribution') IS NOT NULL BEGIN
		DROP TABLE #temp_Toyota_Distribution
	END;

--Create temp table 
	CREATE TABLE #temp_Toyota_Distribution(
		[CreatedBy][varchar](256) NOT NULL,
		[TestRunDate][date]NOT NULL,
		[TableName][varchar](256) NOT NULL,
		[TestName][varchar](256) NOT NULL,
		[ActualResult] [bigint] NOT NULL,
		[ExpectedResult] [bigint] NULL,
	)

-- run normal query into temp table
	INSERT INTO 
		#temp_Toyota_Distribution
		(CreatedBy,
		TestRunDate, 
		TableName,
		TestName,
		ActualResult,
		ExpectedResult)
	SELECT
		'[CapstoneDB].[dbo].[BI_Health_Toyota_Distribution]',
		 Cast(GETDATE() AS DATE),
		'Toyota_Distribution',
		'VIN Count',
		count(distinct Vin),
		13000
	FROM 
		BI_Feed.dbo.Toyota_Distribution with(nolock);

--Altering temp table to add deviation column
	ALTER TABLE #temp_Toyota_Distribution ADD Deviation INT;

--Updates the Deviation column with Actual-Expected
	UPDATE #temp_Toyota_Distribution
	SET Deviation = ActualResult - ExpectedResult;

--Upload data into CapstoneDB.dbo.TnTech_TestResults
	INSERT INTO 
		CapstoneDB.dbo.BI_HealthResults
		(CreatedBy,
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
		#temp_Toyota_Distribution;

-- Final, drop the temporary table
	DROP TABLE #temp_Toyota_Distribution; -- Final, drop the temporary table

	SET NOCOUNT OFF;

END
