/******************************************************************************
	
	CREATOR:	Carlos Escudero

	CREATED:	2024/02/02

	PURPOSE:	Counts the number of Product Id's.

******************************************************************************/

USE [CapstoneDB]
GO

CREATE OR ALTER PROCEDURE [dbo].[BI_Health_BI_BankCore_Products]
AS 
BEGIN
	SET NOCOUNT ON;

	-- create temp table
	DECLARE @temp_BI_VincentSLAAAgregate AS [dbo].[TnTech_TableType];

	-- run normal query into temp table
	INSERT INTO 
		@temp_BI_VincentSLAAAgregate(
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
		'BI_BankCore_Products' AS TableName,
		 CAST(GETDATE() AS DATE) AS TestRunDate,
		'Product ID Count' AS TestName,
		COUNT(DISTINCT ProductId) AS ActualResult,
		5 AS ExpectedResult,
		(COUNT(DISTINCT ProductId) - 5) AS Deviation,
		CAST(GETDATE() AS DATE) AS CreatedOn,
		'[CapstoneDB].[dbo].[BI_Health_BI_BankCore_Products]' AS CreatedBy,
		NULL AS ModifiedOn,
		NULL AS ModifiedBy
	FROM 
		BI_Feed.dbo.BI_BankCore_Products with (nolock); --choose table from BI_feed

	-- upload data into CapstoneDB.dbo.BI_HealthResults
	EXEC [dbo].[BI_InsertTestResult] @Table = @temp_BI_VincentSLAAAgregate;

	SET NOCOUNT OFF;
END;
GO