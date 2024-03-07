select *
from BI_Feed.dbo.BI_PA_Transactions;
-----------------------------------------------------------
SELECT 
	CAST(transactionDate as date) as TransactionDate,
	COUNT(transactionReferenceId) as TransactionCount,
	COUNT(distinct paymentAccountId) as PaymentAccountId
FROM BI_Feed.dbo.BI_PA_Transactions
GROUP BY Cast(transactionDate as date)
ORDER BY Cast(transactionDate as date) DESC;
------------------------------------------------------------------

WITH WeeklyAverages as (
	SELECT 
		timespan, 
		AVG(TransactionCount) as AverageResult
	FROM (
		SELECT 
			CAST(transactionDate as date) as TransactionDate,
			COUNT(transactionReferenceId) as TransactionCount,
			DATEPART(Weekday, transactionDate) AS day_of_week,
			CASE
				WHEN DATEPART(WEEKDAY, transactionDate) in (1,7) THEN 'Sat-Sun'
				WHEN DATEPART(WEEKDAY, transactionDate) IN (2,3,4,5,6) THEN 'Mon-Fri'
				ELSE 'NULL'
			END as timespan
		FROM BI_Feed.dbo.BI_PA_Transactions with (nolock)
		WHERE TransactionDate >= DATEADD(day, -365, GETDATE())
		GROUP BY DATEPART(Weekday, transactionDate), CAST(transactionDate as date)
		) AS subquery
		GROUP BY timespan
),
DetailInfo as (
	SELECT 
		CAST(transactionDate as date) as TransactionDate,
		COUNT(transactionReferenceId) as ActualResult,
		DATEPART(Weekday, transactionDate) AS day_of_week,
		CASE
			WHEN DATEPART(WEEKDAY, transactionDate) in (1,7) THEN 'Sat-Sun'
			WHEN DATEPART(WEEKDAY, transactionDate) IN (2,3,4,5, 6) THEN 'Mon-Fri'
			ELSE 'NULL'
		END as timespan
	FROM BI_Feed.dbo.BI_PA_Transactions with (nolock)
	WHERE TransactionDate >= DATEADD(day, -365, GETDATE())
	GROUP BY DATEPART(Weekday, transactionDate), CAST(transactionDate as date)
)
SELECT
	TransactionDate,
	DetailInfo.timespan,
	day_of_week,
	AverageResult as ExpectedResult,
	ActualResult,
	CASE
		WHEN ActualResult <= AverageResult THEN AverageResult - ActualResult
		WHEN ActualResult > AverageResult THEN ActualResult - AverageResult
	END as Deviation
FROM WeeklyAverages
FULL OUTER JOIN DetailInfo ON WeeklyAverages.timespan = DetailInfo.timespan
GROUP BY TransactionDate, DetailInfo.timespan, day_of_week, AverageResult, ActualResult
ORDER BY TransactionDate DESC;


-------------------------------------------------------------------

WITH WeeklyAverages as (
	SELECT 
		timespan,
		AVG(ActualResult) as AverageResults
	FROM(
		SELECT 
			CAST(transactionDate AS DATE) AS TransactionDate,
			DATEPART(WEEKDAY, transactionDate) AS day_of_week,
			CASE
				WHEN DATEPART(WEEKDAY, transactionDate) IN (1,7) THEN 'Sat-Sun'
				WHEN DATEPART(WEEKDAY, transactionDate) IN (2,3,4,5) THEN 'Mon-Thu'
				WHEN DATEPART(WEEKDAY, transactionDate) = 6 THEN 'Fri'
				ELSE 'NULL'
			END as timespan),
			Count(distinct paymentAccountId)as ActualResult
		FROM BI_Feed.dbo.BI_PA_transactions WITH (nolock)
)