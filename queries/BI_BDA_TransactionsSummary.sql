SELECT *
FROM [BI_Feed].[dbo].[BI_BDA_TransactionsSummary] with (nolock)

Select
	CAST(CreatedOn as DATE) as CreatedOn,
	SUM(sumTransactionAmount) as TransactionSum 
FROM [BI_Feed].[dbo].[BI_BDA_TransactionsSummary] with (nolock)
WHERE CAST(CreatedOn as DATE) = CAST(GETDATE() - 1 AS DATE)
GROUP BY CAST(CreatedOn as DATE)
ORDER BY CAST(CreatedOn as DATE) DESC;
-----------------------------------------------------

-----------------------------------------------------

select CAST(CreatedOn as DATE) as CreatedOn, 
	SUM(transactionAmount)
FROM [BI_Feed].[dbo].[BI_BDA_Transactions] with (nolock)
Where CAST(CreatedOn as DATE) = CAST(GETDATE() - 1 AS DATE)
Group by CAST(CreatedOn as DATE)
ORDER BY CAST(CreatedOn as DATE) DESC

SELECT * 
FROM [BI_Feed].[dbo].[BI_BDA_Transactions]


Select * from [CapstoneDB].[dbo].[BI_HealthResults]

------------------------------------------------------------

Select
	'BI_BDA_TransactionsSummary' as TableName,
	CAST(GETDATE() AS DATE) as TestRunDate,
	'Transaction Amount Sum Check' AS TestName,
	CAST(BI_BDA_Transactions.CreatedOn as DATE) as CreatedOn,
	SUM(BI_BDA_TransactionsSummary.sumTransactionAmount) as ActualAmount,
	SUM(BI_BDA_Transactions.transactionAmount) as ExpectedAmount,
	ABS(SUM(transactionAmount) - SUM(sumTransactionAmount)) as Deviation,
	NULL AS RiskScore,
	'[CapstoneDB].[dbo].[BI_Health_BI_BDA_TransactionsSummary]' AS CreatedBy,
	NULL AS ModifiedOn,
	NULL AS ModifiedBy
FROM [BI_Feed].[dbo].[BI_BDA_TransactionsSummary] with (nolock)
FULL OUTER JOIN [BI_Feed].[dbo].[BI_BDA_Transactions] on CAST(BI_BDA_TransactionsSummary.CreatedOn as date) = CAST(BI_BDA_Transactions.createdOn as date)
WHERE CAST(BI_BDA_Transactions.CreatedOn as DATE) = DATEADD(day, -1, CAST(GETDATE() AS DATE))
AND CAST(BI_BDA_TransactionsSummary.CreatedOn as DATE) = DATEADD(day, -1, CAST(GETDATE() AS DATE))
GROUP BY CAST(BI_BDA_Transactions.CreatedOn as DATE)
ORDER BY CAST(BI_BDA_Transactions.CreatedOn as DATE) DESC;

--------------------------------------------------------------------

CREATE TABLE #SummaryCalculation (
	CreatedOn DATE,
	SummarySum FLOAT
);

INSERT INTO #SummaryCalculation
SELECT
	CAST(CreatedOn as DATE) as CreatedOn,
	SUM(sumTransactionAmount) as SummarySum
FROM [BI_Feed].[dbo].[BI_BDA_TransactionsSummary] with (nolock)
WHERE CAST(CreatedOn as DATE) = DATEADD(day, -1, CAST(GETDATE() AS DATE))
GROUP BY CAST(CreatedOn as DATE)
ORDER BY CAST(CreatedOn as DATE) DESC;

CREATE TABLE #TransactionsCalculation (
	CreatedOn DATE,
	TransactionSum FLOAT
);

INSERT INTO #TransactionsCalculation
SELECT
	CAST(CreatedOn as DATE) as CreatedOn,
	SUM(transactionAmount) as TransactionSum
FROM [BI_Feed].[dbo].[BI_BDA_Transactions] with (nolock)
WHERE CAST(CreatedOn as DATE) = DATEADD(day, -1, CAST(GETDATE() AS DATE))
Group by CAST(CreatedOn as DATE)
ORDER BY CAST(CreatedOn as DATE) DESC


SELECT
	'BI_BDA_TransactionsSummary' as TableName,
	CAST(GETDATE() AS DATE) as TestRunDate,
	'Transaction Amount Sum Check' AS TestName,
	#SummaryCalculation.CreatedOn as CreatedOn,
	SummarySum as ActualAmount,
	TransactionSum as ExpectedAmount,
	ROUND(ABS(SummarySum - TransactionSum), 2) as Deviation,
	NULL AS RiskScore,
	'[CapstoneDB].[dbo].[BI_Health_BI_BDA_TransactionsSummary]' AS CreatedBy,
	NULL AS ModifiedOn,
	NULL AS ModifiedBy
FROM #SummaryCalculation
FULL OUTER JOIN #TransactionsCalculation on #SummaryCalculation.CreatedOn = #TransactionsCalculation.CreatedOn
WHERE CAST(#SummaryCalculation.CreatedOn as DATE) = DATEADD(day, -1, CAST(GETDATE() AS DATE))
GROUP BY #SummaryCalculation.CreatedOn, #SummaryCalculation.SummarySum, #TransactionsCalculation.TransactionSum
ORDER BY #SummaryCalculation.CreatedOn DESC;

DROP TABLE #SummaryCalculation;
DROP TABLE #TransactionsCalculation;