/******************************************************************************
	
	CREATOR:	Robert Bingham

	CREATED:	2024/01/25

	PURPOSE:	Counts the number of records in the table.

******************************************************************************/

USE [CapstoneDB]
GO

CREATE OR ALTER PROCEDURE [dbo].[TnTech_CountRecords] (
	@Records [dbo].[TnTech_TableType] READONLY,
	@TableName varchar(256)
)
AS
BEGIN
	SET NOCOUNT ON;

	CREATE TABLE #TCR (
		[TableName] [varchar] (100) NOT NULL,
		[RecordCounts] [int] NULL,
		[CreatedOn] [datetime] NOT NULL,
		[CreatedBy] [varchar](256) NOT NULL,
		[ModifiedOn] [datetime] NULL,
		[ModifiedBy] [varchar](256) NULL
	)

	INSERT INTO 
		#TCR(TableName, RecordCounts, CreatedOn, CreatedBy, ModifiedOn, ModifiedBy)
	SELECT
		@TableName,
		COUNT(DISTINCT ID),
		GETDATE() AS CreatedOn,
		'TnTech_CountRecords' AS CreatedBy,
		NULL AS ModifiedOn,
		NULL AS ModifiedBy
	FROM
		@Records;

	INSERT INTO 
		[dbo].[TnTech_RecordCounts](TableName, RecordCounts, CreatedOn, CreatedBy, ModifiedOn, ModifiedBy)
	SELECT 
		*
	FROM
		#TCR;

	DROP TABLE #TCR;

	SET NOCOUNT OFF;
END;
GO