USE [CapstoneDB]
GO

/******************************************************************************
	
	CREATOR: Robert Bingham, Carlos Escudero, Harrison Peloquin 

	CREATED: 3/20/2024

	PURPOSE: Checks the count of Partners for the day, if it is more than 6 then it fails

******************************************************************************/

CREATE OR ALTER PROCEDURE [dbo].[BI_Health_BI_BDA_Partners] --name of procedure
AS 
BEGIN
	SET NOCOUNT ON;

	DECLARE @temp_BI_BDA_Partners as [dbo].[TnTech_TableType];

	-- run normal query into temp table
	INSERT INTO 
		@temp_BI_BDA_Partners( --temp table name
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
		'BI_BDA_Partners' AS TableName,
		 CAST(GETDATE() AS DATE) AS TestRunDate,
		'Partner Count Check' AS TestName,
		ActualResult,
		ExpectedResult,
		ABS(ExpectedResult-ActualResult) as Deviation,
		CASE
			WHEN ABS(ExpectedResult-ActualResult) = 0 then 0
			WHEN ABS(ExpectedResult-ActualResult) > 0 AND ABS(ExpectedResult-ActualResult) <= 2 THEN 1
			WHEN ABS(ExpectedResult-ActualResult) > 2 AND ABS(ExpectedResult-ActualResult) <= 4 THEN 2
			WHEN ABS(ExpectedResult-ActualResult) > 4 AND ABS(ExpectedResult-ActualResult) <= 6 THEN 3
			WHEN ABS(ExpectedResult-ActualResult) > 6 AND ABS(ExpectedResult-ActualResult) <= 8 THEN 4
			WHEN ABS(ExpectedResult-ActualResult) > 8 AND ABS(ExpectedResult-ActualResult) <= 10 THEN 5
			WHEN ABS(ExpectedResult-ActualResult) > 10 AND ABS(ExpectedResult-ActualResult) <= 12 THEN 6
			WHEN ABS(ExpectedResult-ActualResult) > 12 AND ABS(ExpectedResult-ActualResult) <= 14 THEN 7
			WHEN ABS(ExpectedResult-ActualResult) > 14 AND ABS(ExpectedResult-ActualResult) <= 16 THEN 8
			WHEN ABS(ExpectedResult-ActualResult) > 16 AND ABS(ExpectedResult-ActualResult) <= 18 THEN 9
			ELSE 10
		END as RiskScore,
		CAST(GETDATE() AS DATE) AS CreatedOn,
		'[CapstoneDB].[dbo].[BI_Health_BI_BDA_Partners]' AS CreatedBy,
		NULL AS ModifiedOn,
		NULL AS ModifiedBy
	FROM 
		(
		
		SELECT
			COUNT(createdOn) AS ExpectedResult
		FROM
			[BI_Feed].[dbo].[BI_BDA_Partners] with (nolock)
		WHERE
			CAST(createdOn AS DATE) < CAST(GETDATE() AS DATE)
	) AS tb1,

	(Select
		Count(CreatedOn) as ActualResult
	From[BI_Feed].[dbo].[BI_BDA_Partners] with (nolock)
	WHERE
			CAST(createdOn AS DATE) <= CAST(GETDATE() AS DATE)) as tb2; -- choose table from BI_feed

	--Upload data into CapstoneDB.dbo.BI_HealthResults
	EXEC [dbo].[BI_InsertTestResult]@Table = @temp_BI_BDA_Partners


	SET NOCOUNT OFF;
END