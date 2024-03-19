/******************************************************************************
	
	CREATOR: Lorenzo Abellanosa

	CREATED: 3/19/24

	PURPOSE: Ensures that there is apporximately 1500 products Id(s) in the table

******************************************************************************/

Use [CapstoneDB]
GO

CREATE OR ALTER PROCEDURE [dbo].[BI_Health_BalancesSummary] --name of procedure
AS 
BEGIN
	SET NOCOUNT ON;

	-- create temp table 
	DECLARE @temp_BI_Health_BalancesSummary AS [dbo].[TnTech_TableType];

	-- run normal query into temp table
	INSERT INTO 
		@temp_BI_Health_BalancesSummary( --temp table name
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
		'BalancesSummary' As TableName,
		 CAST(GETDATE() As DATE) As TestRunDate,
		'Product Id Number Count' As TestName,
		COUNT(DISTINCT productId) As ActualResult,
		1500 AS ExpectedResult,
		(COUNT(DISTINCT productId) - 1500) As Deviation,
		CAST(GETDATE() As DATE) As CreatedOn,
		'[CapstoneDB].[dbo].[BI_Health_BalancesSummary]' As CreatedBy,
		NULL As ModifiedOn,
		NULL As ModifiedBy
	FROM 
		BI_Feed.dbo.BI_BDA_BalancesSummary with (nolock); -- choose table from BI_feed

	-- upload data into CapstoneDB.dbo.BI_HealthResults
	EXEC [dbo].[BI_InsertTestResult] @Table = @temp_BI_Health_BalancesSummary;

	SET NOCOUNT OFF;
END
