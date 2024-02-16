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
	
	--Altering temp table to add deviation column
	ALTER TABLE #tempTableName ADD Deviation INT;

	--Updates the Deviation column with Actual-Expected
	UPDATE --tempTableName
	SET Deviation = ActualResult - ExpectedResult;

	--Upload data into CapstoneDB.dbo.TnTech_TestResults
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
		;--temp table 

	-- Final, drop the temporary table
	DROP TABLE ; -- Final, drop the temporary table

	SET NOCOUNT OFF;
END
