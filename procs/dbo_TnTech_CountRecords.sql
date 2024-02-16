/******************************************************************************
	
	CREATOR:	Robert Bingham

	CREATED:	2024/01/25

	PURPOSE:	Counts the number of records in the table.

******************************************************************************/

USE [CapstoneDB]
GO

CREATE OR ALTER PROCEDURE [dbo].[TnTech_CountRecords] (
	@TableName nvarchar(256),
	@Column nvarchar(256),
	@Date datetime,
	@Expected bigint
)
AS
BEGIN
	SET NOCOUNT ON;

	IF OBJECT_ID('tempdb.dbo.TCR') IS NOT NULL BEGIN
		DROP TABLE #TCR
	END;

	CREATE TABLE #TCR(
		[TableName] varchar(256) NOT NULL,
		[TestRunDate] date NOT NULL,
		[TestName] varchar(256) NOT NULL,
		[ActualResult] bigint NOT NULL,
		[ExpectedResult] bigint NOT NULL,
		[Deviation] bigint NOT NULL,
		[CreatedOn] date NOT NULL,
		[CreatedBy] varchar(256) NOT NULL,
		[ModifiedOn] date NULL,
		[ModifiedBy] varchar(256) NULL
	);
	
	DECLARE @Command nvarchar(max);
	SET @Command = 
		'SELECT ''' 
			+ @TableName
			+ ''', GETDATE() AS TestRunDate
			, ''CountRecords''
			, COUNT(DISTINCT ' + @Column + '), ' 
			+ CAST(@Expected AS nvarchar(265))
			+ ', GETDATE() AS CreatedOn
			, ''[CapstoneDB].[dbo].[TnTech_CountRecords]'' AS CreatedBy
			, NULL AS ModifiedOn
			, NULL AS ModifiedBy
		FROM ' 
			+ @TableName + ' with (nolock)
		WHERE ''' + CONVERT(varchar(10), @Date, 101) + ''' = CAST(GETDATE() AS DATE)';

	INSERT INTO 
		#TCR(
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
	EXEC(@Command);

	INSERT INTO
		[CapstoneDB].[dbo].[TnTech_TestResults](
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
		TableName,
		TestRunDate, 
		TestName,
		ActualResult,
		ExpectedResult,
		Deviation,
		CreatedOn,
		CreatedBy,
		ModifiedOn,
		ModifiedBy
	FROM
		#TCR;

	DROP TABLE #TCR;

	SET NOCOUNT OFF;
END;
GO