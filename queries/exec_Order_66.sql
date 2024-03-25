USE [CapstoneDB]
GO

EXEC [dbo].[BI_Health_BalancesSummary];
EXEC [dbo].[BI_Health_BI_BankCore_Products];
EXEC [dbo].[BI_Health_BI_BDA_Balances];
EXEC [dbo].[BI_Health_BI_BDA_Institutions];
EXEC [dbo].[BI_Health_BI_BDA_Partners];
EXEC [dbo].[BI_Health_BI_BDA_Transactions];
EXEC [dbo].[BI_Health_BI_BDA_UniqueProducts];
EXEC [dbo].[BI_Health_BI_Call_Detail];
EXEC [dbo].[BI_Health_BI_MerchantGroupMIDs];
EXEC [dbo].[BI_Health_BI_MonthlyProductStats];
EXEC [dbo].[BI_Health_BI_PA_Transactions_DistinctPaymentCount];
EXEC [dbo].[BI_Health_BI_PA_Transactions_TransactionCount];
EXEC [dbo].[BI_Health_BI_ProductInclusionTables];
EXEC [dbo].[BI_Health_BI_Program_CardUsageCounts];
EXEC [dbo].[BI_Health_CardCounts];
EXEC [dbo].[BI_Health_PaymentAccountMemos] @DaysBefore = -5;
EXEC [dbo].[BI_Health_Toyota_Distribution];
EXEC [dbo].[BI_Health_Toyota_Inventory];
EXEC [dbo].[BI_Health_VincentSLAAAgregate];
EXEC [dbo].[BI_TPAS_AccountHolders];