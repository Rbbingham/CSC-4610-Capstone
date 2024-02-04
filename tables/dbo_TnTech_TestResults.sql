USE [CapstoneDB]
GO

-- TODO: drop result bit
-- TODO: convert datetime to date
-- TODO: ID is a weak identifier, find another solution
CREATE TABLE [dbo].[TnTech_TestResults](
	[ID] [bigint] IDENTITY(1, 1) NOT NULL CONSTRAINT [PK_TnTech_TestResults] PRIMARY KEY CLUSTERED ([ID] ASC),
	[CreatedOn] [date] NOT NULL CONSTRAINT [DF_TnTech_TestResults_CreatedOn] DEFAULT(GETDATE()),
	[CreatedBy] [varchar](256) NULL,
	[ModifiedOn] [date] NULL,
	[ModifiedBy] [varchar](256) NULL,
	[TableName] [varchar](256) NOT NULL,
	[TestName] [varchar](256) NOT NULL,
	[TestRunDate] [date] NOT NULL,
	[ActualResult] [bigint] NOT NULL,
	[ExpectedResult] [bigint] NULL,
	[Completed] [bit] NOT NULL,
)
GO