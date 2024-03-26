USE [CapstoneDB]
GO

/******************************************************************************
	
	CREATOR:	Carlos Escudero

	CREATED:	2024/02/02

	PURPOSE:	Merchant Group & ProductID Count Test.

******************************************************************************/

CREATE OR ALTER PROCEDURE [dbo].[BI_Health_BI_ProductInclusionTables]
AS 
BEGIN
	SET NOCOUNT ON;

	DECLARE @temp_BI_ProductInclusionTables AS [dbo].[TnTech_TableType];

	-- runs Merchant group test
	INSERT INTO 
		@temp_BI_ProductInclusionTables(
			TableName,
			TestRunDate, 
			TestName,
			ActualResult,
			ExpectedResult,
			Deviation,
			RiskScore,
			CreatedOn,
			CreatedBy,
			ModifiedOn,
			ModifiedBy)
	SELECT
		'BI_ProductInclusionTables' AS TableName,
		 CAST(GETDATE() AS DATE) AS TestRunDate,
		'Check merchant groups' AS TestName,
		COUNT(DISTINCT MerchantGroup) AS ActualResult,
		60 AS ExpectedResult,
		(COUNT(DISTINCT MerchantGroup) - 60) AS Deviation,
		NULL AS RiskScore,
		GETDATE() AS CreatedOn,
		'[CapstoneDB].[dbo].[BI_Health_BI_ProductInclusionTables]' AS CreatedBy,
		NULL AS ModifiedOn,
		NULL AS ModifiedBy
	FROM 
		BI_Feed.dbo.BI_ProductInclusionTables with (nolock); --choose table from BI_feed

	INSERT INTO
		@temp_BI_ProductInclusionTables(
			TableName,
			TestRunDate, 
			TestName,
			ActualResult,
			ExpectedResult,
			Deviation,
			RiskScore,
			CreatedOn,
			CreatedBy,
			ModifiedOn,
			ModifiedBy)
	SELECT
		 'BI_ProductInclusionTables' AS TableName,
		 CAST(GETDATE() AS DATE) AS TestRunDate,
		'Count Product IDs' AS TestName,
		COUNT(DISTINCT ProductID) AS ActualResult,
		275 AS ExpectedResult,
		(COUNT(DISTINCT ProductID) - 275) AS Deviation,
		NULL AS RiskScore,
		GETDATE() AS CreatedOn,
		'[CapstoneDB].[dbo].[BI_Health_BI_ProductInclusionTables]' AS CreatedBy,
		NULL AS ModifiedOn,
		NULL AS ModifiedBy
	FROM 
		BI_Feed.dbo.BI_ProductInclusionTables with (nolock); --choose table from BI_feed

	EXEC [dbo].[BI_InsertTestResult] @Table = @temp_BI_ProductInclusionTables;

	SET NOCOUNT OFF;
END;
GO