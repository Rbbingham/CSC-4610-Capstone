USE [CapstoneDB]
GO

CREATE OR ALTER PROCEDURE [dbo].[BI_Health_BI_BDA_Balances]
AS 
BEGIN
	SET NOCOUNT ON;
	-- create temp variable for storing results
	DECLARE @temp_BI_BDA_Balances AS [dbo].[TnTech_TableType];

	DECLARE @ExpectedResultTemp BIGINT;
	-- TODO: Replace productId with AccountNumber
	SET @ExpectedResultTemp = (SELECT COUNT(productId)
			FROM BI_Feed.dbo.BI_BDA_Balances WITH (nolock) 
			WHERE CAST(CreatedOn AS DATE) = DATEADD(day, -1, CAST(GETDATE() AS DATE))) -- set the expected result to the previous day's results
	 -- run normal query into temp table
	INSERT INTO 
		@temp_BI_BDA_Balances(
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
		'BI_BDA_Balances' as TableName,
		CAST(GETDATE() AS DATE) as TestRunDate,
		'Balances Product Count' as TestName,
		COUNT(productId) as ActualResult,
		@ExpectedResultTemp as ExpectedResult, -- set the expected result
		COUNT(productId) - @ExpectedResultTemp as Deviation, -- set the deviation into the select
		CAST(GETDATE() AS DATE) AS CreatedOn,
		'[CapstoneDB].[dbo].[BI_Health_BI_BDA_Institutions]' AS CreatedBy,
		NULL AS ModifiedOn,
		NULL AS ModifiedBy
	FROM BI_Feed.dbo.BI_BDA_Balances WITH (nolock) 
	WHERE CAST(CreatedOn AS DATE) = CAST(GETDATE() AS DATE);

--  upload data into CapstoneDB.dbo.BI_HealthResults
	EXEC [dbo].[BI_InsertTestResult] @Table = @temp_BI_BDA_Balances;

	SET NOCOUNT OFF;
END;
GO
