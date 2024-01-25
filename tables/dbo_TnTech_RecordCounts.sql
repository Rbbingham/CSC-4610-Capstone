USE [CapstoneDB]
GO

CREATE TABLE [dbo].[TnTech_RecordCounts] (
	[ID] [bigint] IDENTITY(1, 1) NOT NULL CONSTRAINT [PK_TnTech_RecordCounts] PRIMARY KEY CLUSTERED ([ID] ASC),
	[TableName] [varchar](100) NOT NULL,
	[RecordCounts] [int] NOT NULL CONSTRAINT [DF_TnTech_RecordCounts_NotNegative] CHECK ([RecordCounts] > 0),
	[CreatedOn] [datetime] NOT NULL CONSTRAINT [DF_TnTech_RecordCounts_CreatedOn] DEFAULT(GETDATE()),
	[CreatedBy] [varchar](256) NULL,
	[ModifiedOn] [datetime] NULL,
	[ModifiedBy] [varchar](256) NULL,
)
GO