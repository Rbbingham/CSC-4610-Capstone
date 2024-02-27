-- =============================================
-- Author: Lorenzo Abellanosa  
-- Create Date: 2/26/24
-- Description: Counting ID of BI_TPAS_AccountHolders
-- =============================================

Use CapstoneDB
GO

CREATE OR ALTER Procedure[dbo].[BI_TPAS_AccountHolders] --name of procedure
AS 

BEGIN
	SET NOCOUNT ON;

	IF OBJECT_ID('tempdb.dbo.BI_TPAS_AccountHolders') is not null 
	begin 
		Drop Table  #temp_BI_TPAS_AccountHolders--temp table 
	end;

	--Create temp table 
	CREATE TABLE #temp_BI_TPAS_AccountHolders(
		[CreatedBy][varchar](256) NOT NULL,
		[TestRunDate][date]NOT NULL,
		[TableName][varchar](256) NOT NULL,
		[TestName][varchar](256) NOT NULL,
		[ActualResult] [bigint] NOT NULL,
		[ExpectedResult] [bigint] NULL,
	)
	-- run normal query into temp table
	INSERT INTO 
		#temp_BI_TPAS_AccountHolders --temp table name
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
	UPDATE #temp_BI_TPAS_AccountHolders
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
		#temp_BI_TPAS_AccountHolders;--temp table 

	-- Final, drop the temporary table
	DROP TABLE #temp_BI_TPAS_AccountHolders; -- Final, drop the temporary table

	SET NOCOUNT OFF;
END