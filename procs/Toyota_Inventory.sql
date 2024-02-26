/******************************************************************************
	
	CREATOR: Carlos Escudero

	CREATED: 2/26/24

	PURPOSE: To count the number of Admin Number for a given day, ensuring that is 21000

******************************************************************************/

Use [CapstoneDB]
GO

CREATE OR ALTER PROCEDURE [dbo].[BI_Health_Toyota_Inventory] --name of procedure
AS 
BEGIN
	SET NOCOUNT ON;

	IF OBJECT_ID('tempdb.dbo.temp_Toyota_Inventory') IS NOT NULL
	BEGIN
		DROP TABLE #temp_Toyota_Inventory-- temp table 
	END;

	--Create temp table 
	CREATE TABLE #temp_Toyota_Inventory(
		[TableName] varchar(256) NOT NULL,
		[TestRunDate] date NOT NULL,
		[TestName] varchar(256) NOT NULL,
		[ActualResult] bigint NOT NULL,
		[ExpectedResult] bigint NOT NULL,
		[Deviation] bigint NOT NULL,
		[CreatedOn] date NOT NULL,
		[CreatedBy] varchar(256) NOT NULL,
		[ModifiedOn] date NULL,
		[ModifiedBy] varchar(256) NULL
	);

	-- run normal query into temp table
	INSERT INTO 
		#temp_Toyota_Inventory( --temp table name
			TableName,
			TestRunDate, 
			TestName,
			ActualResult,
			ExpectedResult,
			Deviation,
			CreatedOn,
			CreatedBy,
			ModifiedOn,
			ModifiedBy)
	SELECT
		'Toyota_Inventory' AS TableName,
		 CAST(GETDATE() AS DATE) AS TestRunDate,
		'Admin Number Count' AS TestName,
		COUNT(DISTINCT AdminNumber) AS ActualResult,
		21000 AS ExpectedResult,
		(COUNT(DISTINCT AdminNumber) - 21000) AS Deviation,
		CAST(GETDATE() AS DATE) AS CreatedOn,
		'[CapstoneDB].[dbo].[BI_Health_Toyota_Inventory]' AS CreatedBy,
		NULL AS ModifiedOn,
		NULL AS ModifiedBy
	FROM 
		BI_Feed.dbo.Toyota_Inventory with (nolock); -- choose table from BI_feed

	--Upload data into CapstoneDB.dbo.BI_HealthResults
	INSERT INTO 
		CapstoneDB.dbo.BI_HealthResults(
			TableName,
			TestRunDate, 
			TestName,
			ActualResult,
			ExpectedResult,
			Deviation,
			CreatedOn,
			CreatedBy,
			ModifiedOn,
			ModifiedBy)
	SELECT
		TableName,
		TestRunDate, 
		TestName,
		ActualResult,
		ExpectedResult,
		Deviation,
		CreatedOn,
		CreatedBy,
		ModifiedOn,
		ModifiedBy
	FROM 
		#temp_Toyota_Inventory; --temp table 

	DROP TABLE #temp_Toyota_Inventory;

	SET NOCOUNT OFF;
END
