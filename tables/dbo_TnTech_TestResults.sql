USE [CapstoneDB]
GO

IF OBJECT_ID('CapstoneDB.dbo.BI_HealthResults') IS NOT NULL
BEGIN
	DROP TABLE [CapstoneDB].[dbo].[BI_HealthResults];
END

CREATE TABLE [dbo].[BI_HealthResults](
	[TableName] varchar(256) NOT NULL,
	[TestRunDate] date NOT NULL,
	[TestName] varchar(256) NOT NULL,
	[ActualResult] bigint NOT NULL,
	[ExpectedResult] bigint NOT NULL,
	[Deviation] bigint NOT NULL,
	[CreatedOn] date NOT NULL CONSTRAINT [DF_TnTech_TestResults_CreatedOn] DEFAULT(GETDATE()),
	[CreatedBy] varchar(256) NOT NULL,
	[ModifiedOn] date NULL,
	[ModifiedBy] varchar(256) NULL,
	CONSTRAINT [PK_TnTech_TestResults] PRIMARY KEY CLUSTERED ([TestRunDate] DESC, [TableName] ASC, [TestName] DESC),
)
GO