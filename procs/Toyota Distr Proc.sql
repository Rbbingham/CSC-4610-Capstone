USE [CapstoneDB]
GO

/******************************************************************************
	
	CREATOR:	Carlos Escudero

	CREATED:	2024/02/02

	PURPOSE:	Counts the number of Vins in the Toyota_Distribution

******************************************************************************/

CREATE OR ALTER PROCEDURE [dbo].[BI_Health_Toyota_Distribution] 
AS 
BEGIN
	SET NOCOUNT ON;

	-- create temp table
	DECLARE @temp_Toyota_Distribution AS [dbo].[TnTech_TableType];

	-- run normal query into temp table
	INSERT INTO 
		@temp_Toyota_Distribution(
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
		'Toyota_Distribution' AS TableName,
		 CAST(GETDATE() AS DATE) AS TestRunDate,
		'VIN Count' AS TestName,
		COUNT(DISTINCT Vin) AS ActualResult,
		13000 AS ExpectedResult,
		(COUNT(DISTINCT Vin) - 13000) AS Deviation,
		CAST(GETDATE() AS DATE) AS CreatedOn,
		'[CapstoneDB].[dbo].[BI_Health_Toyota_Distribution]' AS CreatedBy,
		NULL AS ModifiedOn,
		NULL AS ModifiedBy
	FROM 
		BI_Feed.dbo.Toyota_Distribution with (nolock);

	-- upload data into CapstoneDB.dbo.BI_HealthResults
	EXEC [dbo].[BI_InsertTestResult] @Table = @temp_Toyota_Distribution;

	SET NOCOUNT OFF;
END;
GO