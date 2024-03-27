USE [CapstoneDB]
GO

/******************************************************************************
	
	CREATOR:	Robert Bingham

	CREATED:	03/27/2024

	PURPOSE:	Flag as an issue if records don't get loaded for 2 or more 
				continuous days.

******************************************************************************/

CREATE OR ALTER PROCEDURE [dbo].[BI_Health_BI_PA_ChecksOutBound]
AS 
BEGIN
	SET NOCOUNT ON;

	DECLARE @RecordCheckExistance int;
	DECLARE @InsertsExist int;
	SET @RecordCheckExistance = (
		SELECT 
			COUNT([Id]) AS Records
		FROM
			[BI_Feed].[dbo].[BI_PA_ChecksOutbound] with (nolock)
		WHERE
			CAST([CreatedOn] AS DATE) >= DATEADD(DAY, -2, CAST(GETDATE() AS DATE)));
	
	IF @RecordCheckExistance > 0
		SET @InsertsExist = 0;
	ELSE
		SET @InsertsExist = 1;

	-- temp table creation 
	DECLARE @temp_BI_PA_ChecksOutBound as [dbo].[TnTech_TableType];

	-- run normal query into temp table
	INSERT INTO 
		@temp_BI_PA_ChecksOutBound(
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
		'BI_PA_ChecksOutBound' AS TableName,
		 CAST(GETDATE() AS DATE) AS TestRunDate,
		'Check if records get loaded for 2 or more continuous days' AS TestName,
		@InsertsExist AS ActualResult,
		0 AS ExpectedResult,
		@InsertsExist AS Deviation,
		[dbo].[CalculateRiskScore](@InsertsExist, 0) AS RiskScore,
		GETDATE() AS CreatedOn,
		'[CapstoneDB].[dbo].[BI_Health_BI_PA_ChecksOutBound]' AS CreatedBy,
		NULL AS ModifiedOn,
		NULL AS ModifiedBy;

	-- upload data into CapstoneDB.dbo.BI_HealthResults
	EXEC [dbo].[BI_InsertTestResult]@Table = @temp_BI_PA_ChecksOutBound

	SET NOCOUNT OFF;
END