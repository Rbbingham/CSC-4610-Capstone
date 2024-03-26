USE [CapstoneDB]
GO

/******************************************************************************
	
	CREATOR:	Robert Bingham

	CREATED:	03/04/2024

	PURPOSE:	Raises alerts if no new records were inserted for continuous days.

******************************************************************************/

CREATE OR ALTER PROCEDURE [dbo].[BI_Health_PaymentAccountMemos](
	@DaysBefore int
)
AS
BEGIN
	SET NOCOUNT ON;

	IF @DaysBefore > 0
	BEGIN
		RAISERROR('Warning: %s was passed %d > 0', 0, 0, 'DaysBefore', @DaysBefore)
	END

	DECLARE @RecordCheckExistance int;
	SET @RecordCheckExistance = (
		SELECT 
			COUNT([Id]) AS Records
		FROM
			[BI_Feed].[dbo].[BI_PaymentAccountMemos] with (nolock)
		WHERE
			CAST([CreatedOn] AS DATE) >= DATEADD(DAY, @DaysBefore, CAST(GETDATE() AS DATE)));

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
		CASE
			WHEN @RecordCheckExistance > 0
				THEN 0
				ELSE 1
		END AS ActualResult,
		0 AS ExpectedResult,
		CASE
			WHEN @RecordCheckExistance > 0
				THEN 0
				ELSE 1
		END AS Deviation,
		CAST(GETDATE() AS DATE) AS CreatedOn,
		'[CapstoneDB].[dbo].[BI_Health_PaymentAccountMemos]' AS CreatedBy,
		NULL AS ModifiedOn,
		NULL AS ModifiedBy;

	-- upload data into CapstoneDB.dbo.BI_HealthResults
	EXEC [dbo].[BI_InsertTestResult] @Table = @temp_BI_PaymentAccountMemos;

	SET NOCOUNT OFF;
END;
GO