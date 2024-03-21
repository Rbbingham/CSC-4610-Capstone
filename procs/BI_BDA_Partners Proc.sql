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