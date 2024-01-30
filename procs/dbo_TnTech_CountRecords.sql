/******************************************************************************
	
	CREATOR:	Robert Bingham

	CREATED:	2024/01/25

	PURPOSE:	Counts the number of records in the table.

******************************************************************************/

USE [CapstoneDB]
GO

CREATE OR ALTER PROCEDURE [dbo].[TnTech_CountRecords] (
	@Records [dbo].[TnTech_TableType] READONLY,
	@TableName varchar(256),
	@Expected bigint
)
AS
BEGIN
	SET NOCOUNT ON;

	CREATE TABLE #TCR (
		[TableName] [varchar] (100) NOT NULL,
		[ActualResult] [bigint] NULL,
		[ExpectedResult] [bigint] NULL,
		[CreatedOn] [datetime] NOT NULL,
		[CreatedBy] [varchar](256) NOT NULL,
		[ModifiedOn] [datetime] NULL,
		[ModifiedBy] [varchar](256) NULL,
		[Result] [bit] NOT NULL,
	)

	INSERT INTO 
		#TCR(TableName, ActualResult, ExpectedResult, CreatedOn, CreatedBy, ModifiedOn, ModifiedBy, Result)
	SELECT
		@TableName,
		COUNT(DISTINCT ID),
		@Expected,
		GETDATE() AS CreatedOn,
		'TnTech_CountRecords' AS CreatedBy,
		NULL AS ModifiedOn,
		NULL AS ModifiedBy,
		1
	FROM
		@Records
	WHERE
		CAST(CreatedOn AS DATE) = CAST(GETDATE() AS DATE);

	INSERT INTO 
		[dbo].[TnTech_TestResults](TableName, ActualResult, ExpectedResult, CreatedOn, CreatedBy, ModifiedOn, ModifiedBy, Result)
	SELECT 
		*
	FROM
		#TCR;

	DROP TABLE #TCR

	SET NOCOUNT OFF;
END;
GO