USE [CapstoneDB]
GO

CREATE TABLE [dbo].[TnTech_TestResults](
	[ID] [bigint] IDENTITY(1, 1) NOT NULL CONSTRAINT [PK_TnTech_TestResults] PRIMARY KEY CLUSTERED ([ID] ASC),
	[CreatedOn] [datetime] NOT NULL CONSTRAINT [DF_TnTech_TestResults_CreatedOn] DEFAULT(GETDATE()),
	[CreatedBy] [varchar](256) NULL,
	[ModifiedOn] [datetime] NULL,
	[ModifiedBy] [varchar](256) NULL,
	[TableName] [varchar](256) NOT NULL,
	[TestName] [varchar](256) NOT NULL,
	[ActualResult] [bigint] NOT NULL,
	[ExpectedResult] [bigint] NULL,
	[Result] [bit] NOT NULL,
)
GO