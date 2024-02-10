USE [CapstoneDB]
GO

CREATE TABLE [dbo].[BI_Health_Results](
	[ID] bigint IDENTITY(1,1) NOT NULL CONSTRAINT [PK_TnTech_TestResults] PRIMARY KEY CLUSTERED ([ID] ASC),
	[TableName] varchar(256) NOT NULL,
	[TestRunDate] date NULL,
	[TestName] varchar(256)NOT NULL,
	[ActualResult] bigint NOT NULL,
	[ExpectedResult] bigint NULL,
	[CreatedOn] date NOT NULL CONSTRAINT [DF_TnTech_TestResults_CreatedOn] DEFAULT(GETDATE()),
	[CreatedBy] varchar(256) NOT NULL,
	[ModifiedOn] datetime NULL,
	[ModifiedBy] varchar(256) NULL,
)
GO


