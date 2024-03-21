USE [CapstoneDB]
GO

/******************************************************************************
	
	CREATOR:

	CREATED:

	PURPOSE:

******************************************************************************/

CREATE OR ALTER PROCEDURE [dbo].[BI_Health_] --name of procedure
AS 
BEGIN
	SET NOCOUNT ON;

	--Temp Table Creation 
	DECLARE @temp_ as [dbo].[TnTech_TableType];

	-- run normal query into temp table
	INSERT INTO 
		@temp_( --temp table name
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
		'TABLENAME' AS TableName,
		 CAST(GETDATE() AS DATE) AS TestRunDate,
		'TESTNAME' AS TestName,
		COUNT(DISTINCT </*INSERT COLUMN*/>) AS ActualResult,
		</*INSERT DEVIATION*/> AS ExpectedResult,
		(COUNT(DISTINCT </*INSERT COLUMN*/>) - </*INSERT DEVIATION*/>) AS Deviation,
		CAST(GETDATE() AS DATE) AS CreatedOn,
		'[CapstoneDB].[dbo].[BI_Health_PROCEDURE_NAME]' AS CreatedBy,
		NULL AS ModifiedOn,
		NULL AS ModifiedBy
	FROM 
		BI_Feed.dbo. with (nolock); -- choose table from BI_feed

	--Upload data into CapstoneDB.dbo.BI_HealthResults
	EXEC [dbo].[BI_InsertTestResult]@Table = @temp_  --put temp table here

	SET NOCOUNT OFF;
END