/******************************************************************************
	
	CREATOR:	Lorenzo Abellanosa

	CREATED:	2024/02/12

	PURPOSE:	Created Test run procedure for CardCounts table.

******************************************************************************/

USE [CapstoneDB]
GO

CREATE OR ALTER PROCEDURE [dbo].[BI_Health_CardCounts]
AS 
BEGIN
	SET NOCOUNT ON;

	DECLARE @temp_CardCounts AS [dbo].[TnTech_TableType];
	
	-- run normal query into temp table
	INSERT INTO 
		@temp_CardCounts(
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
		'BI_CardCounts' AS TableName,
		 CAST(GETDATE() AS DATE) AS TestRunDate,
		'Count of ProductID' AS TestName,
		COUNT(DISTINCT productId) AS ActualResult,
		3800 AS ExpectedResult,
		(COUNT(DISTINCT productId) - 3800) AS Deviation,
		CAST(GETDATE() AS DATE) AS CreatedOn,
		'[CapstoneDB].[dbo].[BI_Health_CardCounts]' AS CreatedBy,
		NULL AS ModifiedOn,
		NULL AS ModifiedBy
	FROM 
		BI_Feed.dbo.CardCounts with (nolock); --choose table from BI_feed

	--Upload data into CapstoneDB.dbo.BI_HealthResults
	EXEC [dbo].[BI_InsertTestResult] @Table = @temp_CardCounts;

	SET NOCOUNT OFF;
END;
GO