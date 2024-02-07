USE [CapstoneDB]
GO

CREATE TABLE [dbo].[TnTech_TestResults](
	[ID] bigint IDENTITY(1,1) NOT NULL CONSTRAINT [PK_TnTech_TestResults] PRIMARY KEY CLUSTERED ([ID] ASC),
	[CreatedOn] date NOT NULL CONSTRAINT [DF_TnTech_TestResults_CreatedOn] DEFAULT(GETDATE()),
	[CreatedBy] varchar(256) NULL,
	[TestRunDate] datetime NULL,
	[TestName] varchar(256)NOT NULL,
	[ModifiedOn] datetime NULL,
	[ModifiedBy] varchar(256) NULL,
	[TableName] varchar(256) NOT NULL,
	[ActualResult] bigint NOT NULL,
	[ExpectedResult] bigint NULL,
	[Completed] bit NOT NULL,
 CONSTRAINT [PK_TnTech_TestResults] PRIMARY KEY CLUSTERED 
(
	[ID] ASC --ID is a weak Primary key
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[TnTech_TestResults] ADD  CONSTRAINT [DF_TnTech_TestResults_CreatedOn]  DEFAULT (getdate()) FOR [CreatedOn]
GO


