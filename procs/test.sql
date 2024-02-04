USE [CapstoneDB]
GO

CREATE OR ALTER PROCEDURE [dbo].[test]
AS
BEGIN
	SET NOCOUNT ON;

	IF OBJECT_ID('#HashMap') IS NOT NULL BEGIN
		DROP TABLE #HashMap
	END;

	CREATE TABLE #HashMap (
		TableName varchar(256) NOT NULL,
		PrimeKey varchar(256) NOT NULL,
	)

	INSERT INTO #HashMap(TableName, PrimeKey) VALUES
	('[BI_Feed].[dbo].[BI_BankCore_Funding_Transactions]', '[FundingTransactionId]'),
	('[BI_Feed].[dbo].[BI_BDA_Institutions]', '[institutionId]'),
	('[BI_Feed].[dbo].[Toyota_Distribution]', '[VIN]'),
	('[BI_Feed].[dbo].[BI_BDA_UniqueProducts]', '[id]');

	-- TODO: insert into results table with table name
	-- TODO: check if record is already there; update record if it is
	-- NOTE: performance may be undesirable
	WHILE EXISTS(SELECT * FROM #HashMap)
	BEGIN
		DECLARE @TableName varchar(256);
		DECLARE @PrimeKey varchar(256);
		SET @TableName = (SELECT TOP(1) TableName FROM #HashMap);
		SET @PrimeKey = (SELECT TOP(1) PrimeKey FROM #HashMap);

		SELECT @TableName;

		DECLARE @Command varchar(max) = '
			SELECT
				COUNT(DISTINCT ' + @PrimeKey + ')
			FROM ' +
				@TableName + '
			WHERE
				CAST(CreatedOn AS DATE) = CAST(GETDATE() AS DATE);'

		EXEC(@Command);

		DELETE TOP(1) FROM #HashMap;
	END

	DROP TABLE #HashMap;

	SET NOCOUNT OFF;
END;
GO

SELECT
	COUNT(DISTINCT VIN)
FROM
	[BI_Feed].[dbo].[Toyota_Distribution]
WHERE
	CAST(CreatedOn AS DATE) = CAST(GETDATE() AS DATE);

SELECT
	COUNT(DISTINCT [FundingTransactionId])
FROM
	[BI_Feed].[dbo].[BI_BankCore_Funding_Transactions]
WHERE
	CAST(CreatedOn AS DATE) = CAST(GETDATE() AS DATE);

SELECT
	COUNT(DISTINCT [institutionId])
FROM
	[BI_Feed].[dbo].[BI_BDA_Institutions]
WHERE
	CAST(CreatedOn AS DATE) = CAST(GETDATE() AS DATE);

SELECT
	COUNT(DISTINCT [id])
FROM
	[BI_Feed].[dbo].[BI_BDA_UniqueProducts]
WHERE
	CAST(CreatedOn AS DATE) = CAST(GETDATE() AS DATE);

EXEC [dbo].[test];