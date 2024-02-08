/******************************************************************************
	
	CREATOR:	Robert Bingham

	CREATED:	2024/01/25

	PURPOSE:	Counts the number of records in the table.

******************************************************************************/

USE [CapstoneDB]
GO

-- TODO: convert datetime to date
-- TODO: convert @Expected to bigint
CREATE OR ALTER PROCEDURE [dbo].[TnTech_CountRecords] (
	@TableName nvarchar(256),
	@Column nvarchar(256),
	@Date datetime,
	@Expected int
)
AS
BEGIN
	SET NOCOUNT ON;

	IF OBJECT_ID('#TCR') IS NOT NULL BEGIN
		DROP TABLE #TCR
	END;

	CREATE TABLE #TCR (
		[TableName] varchar(256) NOT NULL,
		[TestName] varchar(256) NOT NULL,
		[ActualResult] bigint NULL,
		[ExpectedResult] bigint NULL,
		[CreatedOn] date NOT NULL, -- 
		[CreatedBy] varchar(256) NULL,
		[ModifiedOn] datetime NULL,
		[ModifiedBy] varchar(256) NULL,
	);
	
	DECLARE @Command nvarchar(max);
	SET @Command = 
		'SELECT ''' 
			+ @TableName 
			+ ''', ''CountRecords''
			, COUNT(DISTINCT ' + @Column + '), ' 
			+ CAST(@Expected AS nvarchar(265))
			+ ', GETDATE() AS CreatedOn
			, ''[CapstoneDB].[dbo].[TnTech_CountRecords]''
			, NULL AS ModifiedOn
			, NULL AS ModifiedBy
		FROM ' 
			+ @TableName + ' with (nolock)
		WHERE ''' + CONVERT(varchar(10), @Date, 101) + ''' = CAST(GETDATE() AS DATE)';

	INSERT INTO 
		#TCR(TableName, TestName, ActualResult, ExpectedResult, CreatedOn, CreatedBy, ModifiedOn, ModifiedBy)
	EXEC(@Command);

	SELECT * FROM #TCR;

	--INSERT INTO
	--	[dbo].[TnTech_TestResults](TableName, TestName, ActualResult, ExpectedResult, CreatedOn, CreatedBy, ModifiedOn, ModifiedBy)
	--SELECT 
	--	TableName,
	--	ActualResult,
	--	ExpectedResult,
	--	CreatedOn,
	--	CreatedBy,
	--	ModifiedOn,
	--	ModifiedBy
	--FROM
	--	#TCR;

	DROP TABLE #TCR;

	SET NOCOUNT OFF;
END;
GO 

DECLARE @TodaysDate datetime;
SET @TodaysDate = GETDATE();
EXEC [dbo].[TnTech_CountRecords] @TableName = '[BI_Feed].[dbo].[BI_BankCore_Products]', 
								 @Column = '[ProductId]', 
								 @Date = @TodaysDate,
								 @Expected = 5;

EXEC [dbo].[TnTech_CountRecords] @TableName = '[BI_Feed].[dbo].[BI_BDA_Institutions]', 
								 @Column = '[institutionId]', 
								 @Date = @TodaysDate,
								 @Expected = 20;

EXEC [dbo].[TnTech_CountRecords] @TableName = '[BI_Feed].[dbo].[BI_BDA_UniqueProducts]', 
								 @Column = '[ID]', 
								 @Date = @TodaysDate,
								 @Expected = 3850;

EXEC [dbo].[TnTech_CountRecords] @TableName = '[BI_Feed].[dbo].[BI_ProductInclusionTables]', 
								 @Column = '[MerchantGroup]', 
								 @Date = @TodaysDate,
								 @Expected = 60;

EXEC [dbo].[TnTech_CountRecords] @TableName = '[BI_Feed].[dbo].[Toyota_Distribution]', 
								 @Column = '[Vin]', 
								 @Date = @TodaysDate,
								 @Expected = '13000';