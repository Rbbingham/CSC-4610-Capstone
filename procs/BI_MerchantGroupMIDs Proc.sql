USE  CapstoneDB
GO

/******************************************************************************
	
	CREATOR:	Carlos Escudero

	CREATED:	2/15/2024

	PURPOSE:	Counting ID of MerchantGroupsMIDs

******************************************************************************/

CREATE OR ALTER Procedure[dbo].[BI_Health_BI_MerchantGroupMIDs]
AS 

BEGIN
	SET NOCOUNT ON;

	-- create temp table 
	DECLARE @temp_BI_MerchantGroupMIDs AS [dbo].[TnTech_TableType];

	-- run normal query into temp table
	INSERT INTO 
		@temp_BI_MerchantGroupMIDs(
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
		'BI_MerchantGroupMIDs' AS TableName,
		 CAST(GETDATE() AS DATE) AS TestRunDate,
		'ID Count' AS TestName,
		COUNT(DISTINCT id) AS ActualResult,
		40000 AS ExpectedResult,
		(COUNT(DISTINCT id) - 40000) AS Deviation,
		CAST(GETDATE() AS DATE) AS CreatedOn,
		'[CapstoneDB].[dbo].[BI_Health_BI_MerchantGroupMIDs]' AS CreatedBy,
		NULL AS ModifiedOn,
		NULL AS ModifiedBy
	FROM 
		BI_Feed.dbo.BI_MerchantGroupMIDs with(nolock);

	-- upload data into CapstoneDB.dbo.BI_HealthResults
	EXEC [dbo].[BI_InsertTestResult] @Table = @temp_BI_MerchantGroupMIDs;

	SET NOCOUNT OFF;
END
