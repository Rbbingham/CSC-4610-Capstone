USE CapstoneDB
GO

/******************************************************************************
	
	CREATOR:	Lorenzo Abellanosa

	CREATED:	2/26/2024

	PURPOSE:	Counting ID of BI_TPAS_AccountHolders.

******************************************************************************/

CREATE OR ALTER Procedure[dbo].[BI_TPAS_AccountHolders] --name of procedure
AS 

BEGIN
	SET NOCOUNT ON;

	DECLARE @temp_BI_TPAS_AccountHolders AS [dbo].[TnTech_TableType];

	-- run normal query into temp table
	INSERT INTO 
		@temp_BI_TPAS_AccountHolders --temp table name
		(CreatedBy,
		TestRunDate, 
		TableName,
		TestName,
		ActualResult,
		ExpectedResult)
	SELECT
		 '[CapstoneDB].[dbo].[BI_TPAS_AccountHolders]', -- CreatedBy
		 Cast(GETDATE() AS DATE), -- TestRunDate
		'BI_TPAS_AccountHolders',--name of table
		'ID Count',-- name of test
		count(distinct Id),--actual result
		1500000 -- expected result 
	FROM 
		BI_Feed.dbo.BI_TPAS_AccountHolders with(nolock); --choose table from BI_feed

	--Altering temp table to add deviation column
	ALTER TABLE #temp_BI_TPAS_AccountHolders ADD Deviation INT;

	--Updates the Deviation column with Actual-Expected
	UPDATE @temp_BI_TPAS_AccountHolders
	SET Deviation = ActualResult -ExpectedResult;

	--Upload data into CapstoneDB.dbo.BI_HealthResults
	INSERT INTO 
		CapstoneDB.dbo.BI_HealthResults
		(Createdby,
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
		@temp_BI_TPAS_AccountHolders;--temp table 

	EXEC [dbo].[BI_InsertTestResult] @Table = @temp_BI_TPAS_AccountHolders

	SET NOCOUNT OFF;
END