USE [CapstoneDB]
GO

CREATE TYPE [dbo].[TnTech_TableType] AS TABLE (
	[ID] [bigint] IDENTITY(1, 1) NOT NULL,
	[CreatedOn] [datetime] NOT NULL,
	[CreatedBy] [varchar](256) NULL,
	[ModifiedOn] [datetime] NULL,
	[ModifiedBy] [varchar](256) NULL
)
GO