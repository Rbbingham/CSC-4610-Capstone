/******************************************************************************
	
	CREATOR:	Robert Bingham

	CREATED:	03/04/2024

	PURPOSE:	Raises alerts if no new records were inserted for continuous days.

******************************************************************************/

Use [CapstoneDB]
GO

CREATE OR ALTER PROCEDURE [dbo].[BI_Health_PaymentAccountMemos]
AS 
BEGIN
	SET NOCOUNT ON;

	-- create temp table
	DECLARE @temp_BI_PaymentAccountMemos AS [dbo].[TnTech_TableType];

	-- run normal query into temp table
	INSERT INTO 
		@temp_BI_PaymentAccountMemos(
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
		'BI_PaymentAccountMemos' AS TableName,
		CAST(GETDATE() AS DATE) AS TestRunDate,
		'Continuous record insertion' AS TestName,
		COUNT(DISTINCT Records) AS ActualResult,
		0 AS ExpectedResult,
		(COUNT(DISTINCT Records) - 0) AS Deviation,
		CAST(GETDATE() AS DATE) AS CreatedOn,
		'[CapstoneDB].[dbo].[BI_Health_PaymentAccountMemos]' AS CreatedBy,
		NULL AS ModifiedOn,
		NULL AS ModifiedBy
	FROM 
		(
		SELECT 
			COUNT([Id]) AS Records
		FROM
			[BI_Feed].[dbo].[BI_PaymentAccountMemos] with (nolock)
		GROUP BY
			CAST([CreatedOn] AS DATE)
		HAVING
			CAST([CreatedOn] AS DATE) >= DATEADD(DAY, -5, CAST(GETDATE() AS DATE))
	) AS subquery
	WHERE
		Records = 0;

	-- upload data into CapstoneDB.dbo.BI_HealthResults
	EXEC [dbo].[BI_InsertTestResult] @Table = @temp_BI_PaymentAccountMemos;

	SET NOCOUNT OFF;
END;
GO