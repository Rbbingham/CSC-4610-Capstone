-- =============================================
-- Author: Carlos Escudero   
-- Create Date: 2/15/24
-- Description: Counting ID of MerchantGroupsMIDs
-- =============================================
Use CapstoneDB
GO

CREATE OR ALTER Procedure[dbo].[BI_Health_BI_MerchantGroupMIDs] --name of procedure
AS 

BEGIN
	SET NOCOUNT ON;

	IF OBJECT_ID('tempdb.dbo.BI_MerchantGroupMIDs') is not null 
	begin 
		Drop Table  #temp_BI_MerchantGroupMIDs--temp table 
	end;

	--Create temp table 
	CREATE TABLE #temp_BI_MerchantGroupMIDs(
		[CreatedBy][varchar](256) NOT NULL,
		[TestRunDate][date]NOT NULL,
		[TableName][varchar](256) NOT NULL,
		[TestName][varchar](256) NOT NULL,
		[ActualResult] [bigint] NOT NULL,
		[ExpectedResult] [bigint] NULL,
	)
	-- run normal query into temp table
	INSERT INTO 
		#temp_BI_MerchantGroupMIDs --temp table name
		(CreatedBy,
		TestRunDate, 
		TableName,
		TestName,
		ActualResult,
		ExpectedResult)
	SELECT
		 '[CapstoneDB].[dbo].[BI_Health_BI_MerchantGroupMIDs]', -- CreatedBy
		 Cast(GETDATE() AS DATE), -- TestRunDate
		'BI_MerchantGroupMIDs',--name of table
		'ID Count',-- name of test
		count(distinct Id),--actual result
		40000 -- expected result 
	FROM 
		BI_Feed.dbo.BI_MerchantGroupMIDs with(nolock); --choose table from BI_feed

	--Altering temp table to add deviation column
	ALTER TABLE #temp_BI_MerchantGroupMIDs ADD Deviation INT;

	--Updates the Deviation column with Actual-Expected
	UPDATE #temp_BI_MerchantGroupMIDs
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
		#temp_BI_MerchantGroupMIDs;--temp table 

	-- Final, drop the temporary table
	DROP TABLE #temp_BI_MerchantGroupMIDs; -- Final, drop the temporary table

	SET NOCOUNT OFF;
END
