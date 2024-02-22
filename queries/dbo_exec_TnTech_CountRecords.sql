USE [CapstoneDB]
GO

DECLARE @TodaysDate datetime;
SET @TodaysDate = GETDATE();
EXEC [dbo].[TnTech_CountRecords] @TableName = '[BI_Feed].[dbo].[BI_BankCore_Products]', 
								 @Column = '[ProductId]', 
								 @Date = @TodaysDate,
								 @Expected = 5;

EXEC [dbo].[TnTech_CountRecords] @TableName = '[BI_Feed].[dbo].[BI_BDA_Institutions]', 
								 @Column = '[institutionId]', 
								 @Date = @TodaysDate,
								 @Expected = 20;

EXEC [dbo].[TnTech_CountRecords] @TableName = '[BI_Feed].[dbo].[BI_BDA_UniqueProducts]', 
								 @Column = '[ID]', 
								 @Date = @TodaysDate,
								 @Expected = 3850;

EXEC [dbo].[TnTech_CountRecords] @TableName = '[BI_Feed].[dbo].[BI_ProductInclusionTables]', 
								 @Column = '[MerchantGroup]', 
								 @Date = @TodaysDate,
								 @Expected = 60;

EXEC [dbo].[TnTech_CountRecords] @TableName = '[BI_Feed].[dbo].[BI_ProductInclusionTables]', 
								 @Column = '[ProductID]', 
								 @Date = @TodaysDate,
								 @Expected = 275;

EXEC [dbo].[TnTech_CountRecords] @TableName = '[BI_Feed].[dbo].[Toyota_Distribution]', 
								 @Column = '[Vin]', 
								 @Date = @TodaysDate,
								 @Expected = '13000';


SELECT * FROM [dbo].[BI_HealthResults];
DECLARE @test AS [dbo].[TnTech_TableType];
INSERT INTO @test
SELECT TOP(1) * FROM [dbo].[BI_HealthResults] ORDER BY TestRunDate ASC;
SELECT * FROM @test;
EXEC [dbo].[BI_InsertTestResult] @test;
SELECT * FROM [dbo].[BI_HealthResults];