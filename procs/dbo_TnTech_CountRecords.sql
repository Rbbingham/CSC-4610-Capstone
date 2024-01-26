/******************************************************************************
	
	CREATOR:	Robert Bingham

	CREATED:	2024/01/25

	PURPOSE:	Counts the number of records in the table.

******************************************************************************/

USE [CapstoneDB]
GO

CREATE OR ALTER PROCEDURE [dbo].[TnTech_CountRecords]
AS
BEGIN
	SET NOCOUNT ON;

	CREATE TABLE #TCR (
		[ID] [bigint] IDENTITY(1, 1) NOT NULL,
		[TableName] [varchar] (100) NOT NULL,
		[CountRecord] [int] NULL,
		[CreatedOn] [datetime] NOT NULL,
		[CreatedBy] [varchar](256) NOT NULL,
		[ModifiedOn] [datetime] NULL,
		[ModifiedBy] [varchar](256) NULL
	)



	SET NOCOUNT OFF;
END;
GO