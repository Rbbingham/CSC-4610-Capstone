USE [CapstoneDB]
GO

CREATE TYPE [dbo].[TnTech_TableType] AS TABLE (
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
)
GO