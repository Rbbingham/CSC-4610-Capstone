/******************************************************************************
	
	CREATOR:	Carlos Escudero

	CREATED:	2024/02/02

	PURPOSE:	Counts the number of Vins in the Toyota_Distribution

******************************************************************************/

Use CapstoneDB
GO

CREATE OR ALTER PROCEDURE [dbo].[BI_Health_Toyota_Distribution] 
AS 
BEGIN
	SET NOCOUNT ON;

	IF OBJECT_ID('tempdb.dbo.temp_Toyota_Distribution') IS NOT NULL BEGIN
		DROP TABLE #temp_Toyota_Distribution
	END;

	-- create temp table 
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

	-- upload data into CapstoneDB.dbo.TnTech_TestResults
	INSERT INTO 
		CapstoneDB.dbo.TnTech_TestResults
		(CreatedBy,
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
		#temp_Toyota_Distribution;

	DROP TABLE #temp_Toyota_Distribution;

	SET NOCOUNT OFF;
END;
GO
