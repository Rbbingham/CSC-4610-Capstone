Select
	CAST(CreatedOn as DATE) as CreatedOn,
	SUM(sumTransactionAmount)as TransactionSum 
FROM [BI_Feed].[dbo].[BI_BDA_TransactionsSummary] with (nolock)
Where CAST(CreatedOn as DATE) = CAST(GETDATE() AS DATE)
Group by CAST(CreatedOn as DATE)
ORDER BY CAST(CreatedOn as DATE) DESC
-----------------------------------------------------

-----------------------------------------------------

select CAST(CreatedOn as DATE) as CreatedOn, 
	SUM(transactionAmount)
FROM [BI_Feed].[dbo].[BI_BDA_Transactions] with (nolock)
Where CAST(CreatedOn as DATE) = CAST(GETDATE() AS DATE)
Group by CAST(CreatedOn as DATE)
ORDER BY CAST(CreatedOn as DATE) DESC

SELECT * 
FROM [BI_Feed].[dbo].[BI_BDA_Transactions]


Select * from [CapstoneDB].[dbo].[BI_HealthResults]