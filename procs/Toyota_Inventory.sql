USE [CapstoneDB]
GO

/******************************************************************************
	
	CREATOR: Carlos Escudero

	CREATED: 2/26/24

	PURPOSE: To count the number of Admin Number for a given day, ensuring that is 21000

******************************************************************************/

CREATE OR ALTER PROCEDURE [dbo].[BI_Health_Toyota_Inventory]
AS 
BEGIN
	SET NOCOUNT ON;

	-- create temp table 
	DECLARE @temp_Toyota_Inventory AS [dbo].[TnTech_TableType];

	-- run normal query into temp table
	INSERT INTO 
		@temp_Toyota_Inventory(
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

	-- upload data into CapstoneDB.dbo.BI_HealthResults
	EXEC [dbo].[BI_InsertTestResult] @Table = @temp_Toyota_Inventory;

	SET NOCOUNT OFF;
END
