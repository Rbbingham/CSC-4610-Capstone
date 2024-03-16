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
-- COUNT(transactionReferenceId) as TransactionCount
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
				WHEN DATEPART(DAY, CAST(transactionDate as DATE)) = 1 THEN 'FirstofMonth'
				WHEN DATEPART(WEEKDAY, transactionDate) = 1 THEN 'Sun'
				WHEN DATEPART(WEEKDAY, transactionDate) = 2 THEN 'Mon'
				WHEN DATEPART(WEEKDAY, transactionDate) = 3 THEN 'Tues'
				WHEN DATEPART(WEEKDAY, transactionDate) = 4 THEN 'Wed'
				WHEN DATEPART(WEEKDAY, transactionDate) = 5 THEN 'Thu'
				WHEN DATEPART(WEEKDAY, transactionDate) = 6 THEN 'Fri'
				WHEN DATEPART(WEEKDAY, transactionDate) = 7 THEN 'Sat'
				ELSE 'NULL'
			END as timespan
		FROM BI_Feed.dbo.BI_PA_Transactions with (nolock)
		WHERE TransactionDate >= DATEADD(day, -183, GETDATE())
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
			WHEN DATEPART(DAY, CAST(transactionDate as DATE)) = 1 THEN 'FirstofMonth'
			WHEN DATEPART(WEEKDAY, transactionDate) = 1 THEN 'Sun'
			WHEN DATEPART(WEEKDAY, transactionDate) = 2 THEN 'Mon'
			WHEN DATEPART(WEEKDAY, transactionDate) = 3 THEN 'Tues'
			WHEN DATEPART(WEEKDAY, transactionDate) = 4 THEN 'Wed'
			WHEN DATEPART(WEEKDAY, transactionDate) = 5 THEN 'Thu'
			WHEN DATEPART(WEEKDAY, transactionDate) = 6 THEN 'Fri'
			WHEN DATEPART(WEEKDAY, transactionDate) = 7 THEN 'Sat'
			ELSE 'NULL'
		END as timespan
	FROM BI_Feed.dbo.BI_PA_Transactions with (nolock)
	WHERE TransactionDate >= DATEADD(day, -183, GETDATE())
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
-- COUNT(distinct paymentAccountId) as PaymentAccountId
WITH WeeklyAverages as (
	SELECT 
		timespan, 
		AVG(PaymentAccountId) as AverageResult
	FROM (
		SELECT 
			CAST(transactionDate as date) as TransactionDate,
			COUNT(distinct paymentAccountId) as PaymentAccountId,
			DATEPART(Weekday, transactionDate) AS day_of_week,
			CASE
				WHEN DATEPART(DAY, CAST(transactionDate as DATE)) = 1 THEN 'FirstofMonth'
				WHEN DATEPART(WEEKDAY, transactionDate) in (1) THEN 'Sun'
				WHEN DATEPART(WEEKDAY, transactionDate) IN (2) THEN 'Mon'
				WHEN DATEPART(WEEKDAY, transactionDate) IN (3) THEN 'T'
				WHEN DATEPART(WEEKDAY, transactionDate) IN (4) THEN 'W'
				WHEN DATEPART(WEEKDAY, transactionDate) IN (5) THEN 'TH'
				WHEN DATEPART(WEEKDAY, transactionDate) IN (6) THEN 'Fr'
				WHEN DATEPART(WEEKDAY, transactionDate) IN (7) THEN 'Sat'
				ELSE 'NULL'
			END as timespan
		FROM BI_Feed.dbo.BI_PA_Transactions with (nolock)
		WHERE TransactionDate >= DATEADD(day, -150, GETDATE())
		GROUP BY DATEPART(Weekday, transactionDate), CAST(transactionDate as date)
		) AS subquery
		GROUP BY timespan
),
DetailInfo as (
	SELECT 
		CAST(transactionDate as date) as TransactionDate,
		COUNT(distinct paymentAccountId) as ActualResult,
		DATEPART(Weekday, transactionDate) AS day_of_week,
		CASE
			WHEN DATEPART(DAY, CAST(transactionDate as DATE)) = 1 THEN 'FirstofMonth'
			WHEN DATEPART(WEEKDAY, transactionDate) in (1) THEN 'Sun'
			WHEN DATEPART(WEEKDAY, transactionDate) IN (2) THEN 'Mon'
			WHEN DATEPART(WEEKDAY, transactionDate) IN (3) THEN 'T'
			WHEN DATEPART(WEEKDAY, transactionDate) IN (4) THEN 'W'
			WHEN DATEPART(WEEKDAY, transactionDate) IN (5) THEN 'TH'
			WHEN DATEPART(WEEKDAY, transactionDate) IN (6) THEN 'Fr'
			WHEN DATEPART(WEEKDAY, transactionDate) IN (7) THEN 'Sat'
			ELSE 'NULL'
		END as timespan
	FROM BI_Feed.dbo.BI_PA_Transactions with (nolock)
	WHERE TransactionDate >= DATEADD(day, -150, GETDATE())
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

----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
-- COUNT(transactionReferenceId) as TransactionCount
CREATE TABLE #DayOfMonthAvgs (
	day_of_month NVARCHAR(20),
	transCountAvg INT
);
INSERT INTO #DayOfMonthAvgs
SELECT 
	day_of_month, 
	AVG(TransactionCount) as transCountAvg
FROM 
(
	SELECT 
		CAST(transactionDate as date) as transactionDate,
		COUNT(transactionReferenceId) as transactionCount,
		DATEPART(day, transactionDate) AS day_of_month
	FROM BI_Feed.dbo.BI_PA_Transactions with (nolock)
	WHERE TransactionDate >= DATEADD(day, -183, GETDATE())
	GROUP BY CAST(transactionDate as date), DATEPART(day, transactionDate)
	--ORDER BY CAST(transactionDate as date)
) AS subquery
GROUP BY day_of_month;


CREATE TABLE #DetailInfo (
	transactionDate DATE,
	ActualResult INT,
	day_of_month INT
)

INSERT INTO #DetailInfo
SELECT 
		CAST(transactionDate as date) as transactionDate,
		COUNT(transactionReferenceId) as ActualResult,
		DATEPART(day, transactionDate) AS day_of_month
FROM BI_Feed.dbo.BI_PA_Transactions with (nolock)
WHERE TransactionDate >= DATEADD(day, -183, GETDATE())
GROUP BY CAST(transactionDate as date), DATEPART(day, transactionDate)
--ORDER BY CAST(transactionDate as date)


SELECT
	transactionDate,
	#DetailInfo.day_of_month,
	transCountAvg as ExpectedResult,
	ActualResult,
	ABS(transCountAvg - ActualResult) as Deviation
FROM #DetailInfo
FULL OUTER JOIN #DayOfMonthAvgs ON #DetailInfo.day_of_month = #DayOfMonthAvgs.day_of_month
WHERE transactionDate >= DATEADD(day, -183, GETDATE())
GROUP BY transactionDate, #DetailInfo.day_of_month, transCountAvg, ActualResult
ORDER BY transactionDate DESC;

DROP TABLE #DayOfMonthAvgs;
DROP TABLE #DetailInfo;