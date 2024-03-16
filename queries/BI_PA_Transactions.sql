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
	transCountAvgMonth INT
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
		CASE
			WHEN DATEPART(day, transactionDate) = 1 THEN 'First'
			WHEN DATEPART(day, transactionDate) = 9 THEN 'Ninth'
			ELSE 'Normal'
		END as day_of_month
	FROM BI_Feed.dbo.BI_PA_Transactions with (nolock)
	WHERE TransactionDate >= DATEADD(day, -62, GETDATE())
	GROUP BY CAST(transactionDate as date), DATEPART(day, transactionDate)
	--ORDER BY CAST(transactionDate as date)
) AS subquery
GROUP BY day_of_month;

CREATE TABLE #WeeklyAverages (
	timespan NVARCHAR(20),
	transCountAvgWeek INT
);

INSERT INTO #WeeklyAverages
SELECT 
	timespan, 
	AVG(TransactionCount) as transCountAvgWeek
FROM 
(
	SELECT 
		CAST(transactionDate as date) as transactionDate,
		COUNT(transactionReferenceId) as transactionCount,
		DATEPART(WEEKDAY, transactionDate) AS day_of_week,
		CASE
			WHEN DATEPART(WEEKDAY, transactionDate) IN (1,7) THEN 'Sat-Sun'
			WHEN DATEPART(WEEKDAY, transactionDate) IN (2,6) THEN 'Mon,Fri'
			WHEN DATEPART(WEEKDAY, transactionDate) IN (3,4,5) THEN 'Tues-Thu'
			ELSE 'NULL'
		END as timespan
	FROM BI_Feed.dbo.BI_PA_Transactions with (nolock)
	WHERE TransactionDate >= DATEADD(day, -183, GETDATE())
	GROUP BY CAST(transactionDate as date), DATEPART(WEEKDAY, transactionDate)
	--ORDER BY CAST(transactionDate as date) DESC
) AS subquery
GROUP BY timespan;

CREATE TABLE #DetailInfo (
	transactionDate DATE,
	ActualResult INT,
	day_of_month NVARCHAR(20),
	timespan NVARCHAR(20)
);

INSERT INTO #DetailInfo
SELECT 
		CAST(transactionDate as date) as transactionDate,
		COUNT(transactionReferenceId) as ActualResult,
		CASE
			WHEN DATEPART(day, transactionDate) = 1 THEN 'First'
			WHEN DATEPART(day, transactionDate) = 9 THEN 'Ninth'
			ELSE 'Normal'
		END as day_of_month,
		CASE
			WHEN DATEPART(WEEKDAY, transactionDate) IN (1,7) THEN 'Sat-Sun'
			WHEN DATEPART(WEEKDAY, transactionDate) IN (2,6) THEN 'Mon,Fri'
			WHEN DATEPART(WEEKDAY, transactionDate) IN (3,4,5) THEN 'Tues-Thu'
			ELSE 'NULL'
		END as timespan
FROM BI_Feed.dbo.BI_PA_Transactions with (nolock)
WHERE TransactionDate >= DATEADD(day, -183, GETDATE())
GROUP BY CAST(transactionDate as date), DATEPART(day, transactionDate), DATEPART(WEEKDAY, transactionDate)
ORDER BY CAST(transactionDate as date) DESC;

CREATE TABLE #ExpectedCalculator (
	transactionDate DATE,
	ExpectedResult INT
);

INSERT INTO #ExpectedCalculator
SELECT
	transactionDate,
	CASE
		WHEN #DayOfMonthAvgs.day_of_month IN ('First', 'Ninth') THEN transCountAvgWeek * 0.01 + transCountAvgMonth * 0.99
		ELSE transCountAvgWeek * 0.99 + transCountAvgMonth * 0.01
	END as ExpectedResult
FROM #DetailInfo
FULL OUTER JOIN #WeeklyAverages on #WeeklyAverages.timespan = #DetailInfo.timespan
FULL OUTER JOIN #DayOfMonthAvgs on #DayOfMonthAvgs.day_of_month = #DetailInfo.day_of_month
WHERE transactionDate >= DATEADD(day, -183, GETDATE())
GROUP BY transactionDate, #DayOfMonthAvgs.day_of_month, #WeeklyAverages.timespan, transCountAvgMonth, transCountAvgWeek;

SELECT
	#DetailInfo.transactionDate,
	ExpectedResult,
	ActualResult,
	ABS(ExpectedResult - ActualResult) as Deviation
FROM #DetailInfo
FULL OUTER JOIN #DayOfMonthAvgs ON #DetailInfo.day_of_month = #DayOfMonthAvgs.day_of_month
FULL OUTER JOIN #WeeklyAverages ON #DetailInfo.timespan = #WeeklyAverages.timespan
FULL OUTER JOIN #ExpectedCalculator ON #ExpectedCalculator.transactionDate = #DetailInfo.transactionDate
WHERE #DetailInfo.transactionDate = DATEADD(day, -1, CAST(GETDATE() AS DATE))
GROUP BY #DetailInfo.transactionDate, ExpectedResult, ActualResult
ORDER BY transactionDate DESC;

DROP TABLE #DayOfMonthAvgs;
DROP TABLE #WeeklyAverages
DROP TABLE #ExpectedCalculator
DROP TABLE #DetailInfo;