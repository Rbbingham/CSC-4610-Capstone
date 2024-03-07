/******************************************************************************
	
	CREATOR:	Carlos Escudero

	CREATED:	2024/02/02

	PURPOSE:	ID Count for BI_BDA_UniqueProducts.

******************************************************************************/

USE [CapstoneDB]
GO

CREATE OR ALTER PROCEDURE [dbo].[BI_Health_BI_BDA_UniqueProducts]
AS 
BEGIN
	SET NOCOUNT ON;

	-- create temp table 
	DECLARE @temp_BI_BDA_UniqueProducts AS [dbo].[TnTech_TableType];

	-- run normal query into temp table
	INSERT INTO 
		@temp_BI_BDA_UniqueProducts(
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
		'BI_BDA_UniqueProducts' AS TableName,
		 CAST(GETDATE() AS DATE) AS TestRunDate,
		'ID Count' AS TestName,
		COUNT(DISTINCT ID) AS ActualResult,
		3850 AS ExpectedResult,
		(COUNT(DISTINCT ID) - 3850) AS Deviation,
		CAST(GETDATE() AS DATE) AS CreatedOn,
		'[CapstoneDB].[dbo].[BI_Health_BI_BDA_UniqueProducts]' AS CreatedBy,
		NULL AS ModifiedOn,
		NULL AS ModifiedBy
	FROM 
		BI_Feed.dbo.BI_BDA_UniqueProducts with (nolock); -- choose table from BI_feed

	-- upload data into CapstoneDB.dbo.BI_Health
	EXEC [dbo].[BI_InsertTestResult] @Table = @temp_BI_BDA_UniqueProducts;


	SET NOCOUNT OFF;
END;
GO