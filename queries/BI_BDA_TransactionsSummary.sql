SELECT *
FROM [BI_Feed].[dbo].[BI_BDA_TransactionsSummary] with (nolock)
where productId is NUll

Select
	CAST(CreatedOn as DATE) as CreatedOn,
	SUM(sumTransactionAmount) as TransactionSum 
FROM [BI_Feed].[dbo].[BI_BDA_TransactionsSummary] with (nolock)
WHERE CAST(CreatedOn as DATE) = CAST(GETDATE() AS DATE) 
GROUP BY CAST(CreatedOn as DATE)
ORDER BY CAST(CreatedOn as DATE) DESC;
-----------------------------------------------------

-----------------------------------------------------

select CAST(CreatedOn as DATE) as CreatedOn, 
	SUM(transactionAmount)
FROM [BI_Feed].[dbo].[BI_BDA_Transactions] with (nolock)
Where CAST(CreatedOn as DATE) = CAST(GETDATE()  AS DATE) AND adminNumber is NOT NUll
Group by CAST(CreatedOn as DATE)
ORDER BY CAST(CreatedOn as DATE) DESC

SELECT	id,
		createdOn,
		TranId,
		adminNumber, 
		transactionAmount
FROM [BI_Feed].[dbo].[BI_BDA_Transactions]
where adminNumber is Null


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
	SummarySum as ActualAmount,
	TransactionSum as ExpectedAmount,
	ROUND(ABS(SummarySum - TransactionSum), 2) as Deviation,
	NULL AS RiskScore,
	CAST(GETDATE() AS DATE) AS CreatedOn,
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

---------------------------------------------------------------------------------
---------------------------------------------------------------------------------
CREATE TABLE #WeeklyAverages (
	day_of_week NVARCHAR(20),
	weekIDCountAvg INT,
);

INSERT INTO #WeeklyAverages
SELECT 
	day_of_week,
	AVG(IDCount) as weekIDCountAvg
FROM (
	SELECT
		CAST(CreatedOn as DATE) as CreatedOn,
		COUNT(ID) as IDCount,
		CASE
			WHEN DATEPART(WEEKDAY, createdOn) IN (1,2) THEN 'Sun-Mon'
			WHEN DATEPART(WEEKDAY, createdOn) IN (3,4,5,6) THEN 'Tues-Fri'
			WHEN DATEPART(WEEKDAY, createdOn) = 7 THEN 'Sat'
			ELSE 'NULL'
		END as day_of_week
	FROM [BI_Feed].[dbo].[BI_BDA_TransactionsSummary] with (nolock)
	WHERE CAST(CreatedOn as DATE) >= DATEADD(day, -183, CAST(GETDATE() AS DATE))
	GROUP BY CAST(CreatedOn as DATE), DATEPART(WEEKDAY, createdOn)
	--ORDER BY CAST(CreatedOn as DATE) DESC
) as subquery
GROUP BY day_of_week;

CREATE TABLE #DayOfMonthAverages (
	day_of_month NVARCHAR(20),
	dayofMonthIDCountAvg DECIMAL(18,2)
);

INSERT INTO #DayOfMonthAverages
SELECT day_of_month, AVG(IDCount) as dayofMonthIDCountAvg
FROM
(
	SELECT
		CAST(createdOn AS DATE) AS createdOn,
		CASE
			WHEN DATEPART(day, CAST(createdOn as DATE)) = 2 THEN 'Sec'
			ELSE 'NULL'
		END as day_of_month,
		COUNT(ID) as IDCount
	FROM BI_Feed.dbo.BI_BDA_TransactionsSummary WITH (nolock)
	WHERE createdOn >= DATEADD(day, -183, GETDATE())
	GROUP BY CAST(createdOn AS DATE)
) AS subquery
GROUP BY day_of_month;

CREATE TABLE #DetailInfo (
	CreatedOn DATE,
	IDCount INT,
	day_of_week NVARCHAR(20),
	day_of_month NVARCHAR(20)
);

INSERT INTO #DetailInfo
SELECT
	CAST(CreatedOn as DATE) as CreatedOn,
	COUNT(ID) as IDCount,
	CASE
		WHEN DATEPART(WEEKDAY, createdOn) IN (1,2) THEN 'Sun-Mon'
		WHEN DATEPART(WEEKDAY, createdOn) IN (3,4,5,6) THEN 'Tues-Fri'
		WHEN DATEPART(WEEKDAY, createdOn) = 7 THEN 'Sat'
		ELSE 'NULL'
	END as day_of_week,
	CASE
		WHEN DATEPART(day, CAST(createdOn as DATE)) = 2 THEN 'Sec'
		ELSE 'NULL'
	END as day_of_month
FROM [BI_Feed].[dbo].[BI_BDA_TransactionsSummary] with (nolock)
WHERE CAST(CreatedOn as DATE) >= DATEADD(day, -183, CAST(GETDATE() AS DATE))
GROUP BY CAST(CreatedOn as DATE), DATEPART(WEEKDAY, createdOn), DATEPART(day, CAST(createdOn as DATE))
ORDER BY CAST(CreatedOn as DATE) DESC;

CREATE TABLE #ExpectedCalculator (
	CreatedOn DATE,
	ExpectedResult INT
);

INSERT INTO #ExpectedCalculator
SELECT
    CreatedOn,
    CASE
        WHEN #DayOfMonthAverages.day_of_month IN ('Sec') THEN CAST((dayofMonthIDCountAvg * 0.99 + weekIDCountAvg * 0.01) AS INT)
        ELSE CAST(weekIDCountAvg AS INT)
    END as ExpectedResult
FROM #DetailInfo
FULL OUTER JOIN #WeeklyAverages on #WeeklyAverages.day_of_week = #DetailInfo.day_of_week
FULL OUTER JOIN #DayOfMonthAverages on #DayOfMonthAverages.day_of_month = #DetailInfo.day_of_month
WHERE CreatedOn >= DATEADD(day, -183, GETDATE())
GROUP BY CreatedOn, #DayOfMonthAverages.day_of_month, dayofMonthIDCountAvg, weekIDCountAvg;


SELECT
	--'BI_BDA_TransactionsSummary' as TableName,
	--CAST(GETDATE() AS DATE) as TestRunDate,
	--'Transaction Amount Sum Check' AS TestName,
	#DetailInfo.CreatedOn,
	IDCount as ActualResult,
	ExpectedResult,
	ABS(IDCount - weekIDCountAvg) as Deviation
	--NULL AS RiskScore,
	--CAST(GETDATE() AS DATE) AS CreatedOn,
	--'[CapstoneDB].[dbo].[BI_Health_BI_BDA_TransactionsSummary]' AS CreatedBy,
	--NULL AS ModifiedOn,
	--NULL AS ModifiedBy
FROM #DetailInfo
FULL OUTER JOIN #WeeklyAverages ON #DetailInfo.day_of_week = #WeeklyAverages.day_of_week
FULL OUTER JOIN #DayOfMonthAverages ON #DetailInfo.day_of_month = #DayOfMonthAverages.day_of_month
FULL OUTER JOIN #ExpectedCalculator ON #DetailInfo.CreatedOn = #ExpectedCalculator.CreatedOn
WHERE CAST(#DetailInfo.CreatedOn as DATE) >= DATEADD(day, -183, CAST(GETDATE() AS DATE))
GROUP BY CAST(#DetailInfo.CreatedOn as DATE), IDCount, weekIDCountAvg
ORDER BY CAST(#DetailInfo.CreatedOn as DATE) DESC;

DROP TABLE #WeeklyAverages;
DROP TABLE #DayOfMonthAverages;
DROP TABLE #DetailInfo;
DROP TABLE #ExpectedCalculator;