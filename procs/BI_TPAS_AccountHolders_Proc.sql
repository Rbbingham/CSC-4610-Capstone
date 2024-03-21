USE CapstoneDB
GO

/******************************************************************************
	
	CREATOR:	Lorenzo Abellanosa

	CREATED:	2/26/2024

	PURPOSE:	Counting ID of BI_TPAS_AccountHolders.

******************************************************************************/

CREATE OR ALTER PROCEDURE [dbo].[BI_TPAS_AccountHolders]
AS 
BEGIN
	SET NOCOUNT ON;

	-- create temp table 
	DECLARE @temp_BI_TPAS_AccountHolders AS [dbo].[TnTech_TableType];

	-- run normal query into temp table
	INSERT INTO 
		@temp_BI_TPAS_AccountHolders(
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
		'BI_TPAS_AccountHolders' AS TableName,
		CAST(GETDATE() AS DATE) AS TestRunDate,
		'ID Count' AS TestName,
		COUNT(DISTINCT [Id]) AS ActualResult,
		1500000 AS ExpectedResult,
		(COUNT(DISTINCT [Id]) - 1500000) AS Deviation,
		CAST(GETDATE() AS DATE) AS CreatedOn,
		'[CapstoneDB].[dbo].[BI_Health_AccountHolders]' AS CreatedBy,
		NULL AS ModifiedOn,
		NULL AS ModifiedBy
	FROM 
		[BI_Feed].[dbo].[BI_TPAS_AccountHolders] with (nolock);

	-- upload data into CapstoneDB.dbo.BI_HealthResults
	EXEC [dbo].[BI_InsertTestResult] @Table = @temp_BI_TPAS_AccountHolders;

	SET NOCOUNT OFF;
END;
GO