USE BI_Feed

SELECT top 10 id, createdON, tranID, adminNumber, transactionAmount
FROM BI_BDA_Transactions;

-----------------------------------------------------------------------------------------
USE BI_Feed

SELECT day_of_month, AVG(tranIDCount) as avgTranIDCount
FROM
(
	SELECT 
		CAST(createdOn as DATE) as transactionDate, 
		DATEPART(day, CAST(createdOn as DATE)) as day_of_month, 
		COUNT(tranID) as tranIDCount
	FROM BI_BDA_Transactions
	WHERE createdOn >= DATEADD(day, -365, GETDATE())
	GROUP BY CAST(createdON as DATE)
) AS subquery
GROUP BY day_of_month
ORDER BY day_of_month;
-------------------------------------------------------------------------------------------
SELECT
	CAST(createdOn as DATE) as transactionDate, 
	DATEPART(day, CAST(createdOn as DATE)) as day_of_month,
	COUNT(tranID) as tranIDCount
FROM BI_BDA_Transactions
GROUP BY CAST(createdOn as DATE);
--------------------------------------------------------------------

WITH AveragesByDay AS (
	SELECT day_of_month, AVG(tranIDCount) as avgTranIDCount
	FROM
	(
		SELECT 
			CAST(createdOn as DATE) as transactionDate, 
			DATEPART(day, CAST(createdOn as DATE)) as day_of_month, 
			COUNT(tranID) as tranIDCount
		FROM BI_Feed.dbo.BI_BDA_Transactions WITH (nolock)
		WHERE createdOn >= DATEADD(day, -183, GETDATE())
		GROUP BY CAST(createdON as DATE)
	) AS subquery
	GROUP BY day_of_month
),
DetailInfo AS (
	SELECT
		CAST(createdOn as DATE) as transactionDate, 
		DATEPART(day, CAST(createdOn as DATE)) as day_of_month,
		COUNT(tranID) as ActualResult
	FROM BI_Feed.dbo.BI_BDA_Transactions WITH (nolock)
	WHERE createdOn >= DATEADD(day, -183, GETDATE())
	GROUP BY CAST(createdOn as DATE)
)
SELECT
	transactionDate,
	DetailInfo.day_of_month,
	avgTranIDCount as ExpectedResult,
	ActualResult,
	CASE
		WHEN ActualResult <= avgTranIDCount THEN avgTranIDCount - ActualResult
		WHEN ActualResult > avgTranIDCount THEN ActualResult - avgTranIDCount
	END as Deviation
FROM AveragesByDay
FULL OUTER JOIN DetailInfo on AveragesByDay.day_of_month = DetailInfo.day_of_month
WHERE transactionDate >= DATEADD(day, -183, GETDATE())
GROUP BY transactionDate, DetailInfo.day_of_month, avgTranIDCount, ActualResult
ORDER BY transactionDate DESC;


------------------------------------------------------------------------------------------

SELECT
	CAST(createdOn AS DATE) AS createdOn,
	DATEPART(day, CAST(createdOn as DATE)) as day_of_month,
	CASE
		WHEN DATEPART(WEEKDAY, createdOn) IN (1,2) THEN 'Sun-Mon'
		WHEN DATEPART(WEEKDAY, createdOn) IN (3,4,5) THEN 'Tues-Thur'
		WHEN DATEPART(WEEKDAY, createdOn) = 6 THEN 'Fri'
		WHEN DATEPART(WEEKDAY, createdOn) = 7 THEN 'Sat'
		ELSE 'NULL'
	END as day_of_week,
	CASE
		WHEN DATEPART(day, CAST(createdOn as DATE)) = 2 THEN 'SecondofMonth'
		WHEN DATEPART(day, CAST(createdOn as DATE)) = 9 THEN 'NinthofMonth'
		ELSE 'NULL'
	END as day_of_month,
	COUNT(tranID) as ActualResult
FROM BI_Feed.dbo.BI_BDA_Transactions WITH (nolock)
WHERE createdOn >= DATEADD(day, -183, GETDATE())
GROUP BY CAST(createdOn AS DATE), DATEPART(day, CAST(createdOn as DATE)), DATEPART(WEEKDAY, createdOn)
ORDER BY CAST(createdOn AS DATE) DESC;


----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
-- Create a temporary table for weekly averages
CREATE TABLE #WeeklyAverages (
	day_of_week NVARCHAR(20),
	weeklyAvgTranIDCount DECIMAL(18,2)
);

INSERT INTO #WeeklyAverages
SELECT day_of_week, AVG(ActualResult) as weeklyAvgTranIDCount
FROM
(
	SELECT
		CAST(createdOn AS DATE) AS createdOn,
		CASE
			WHEN DATEPART(WEEKDAY, createdOn) IN (1,2) THEN 'Sun-Mon'
			WHEN DATEPART(WEEKDAY, createdOn) IN (3,4,5) THEN 'Tues-Thur'
			WHEN DATEPART(WEEKDAY, createdOn) = 6 THEN 'Fri'
			WHEN DATEPART(WEEKDAY, createdOn) = 7 THEN 'Sat'
			ELSE 'NULL'
		END as day_of_week,
		COUNT(tranID) as ActualResult
	FROM BI_Feed.dbo.BI_BDA_Transactions WITH (nolock)
	WHERE createdOn >= DATEADD(day, -183, GETDATE())
	GROUP BY CAST(createdOn AS DATE), DATEPART(WEEKDAY, createdOn)
) AS subquery
GROUP BY day_of_week;

-- Create a temporary table for day of month averages
CREATE TABLE #DayOfMonthAverages (
	day_of_month NVARCHAR(20),
	dayofMonthAvgTranIDCount DECIMAL(18,2)
);

INSERT INTO #DayOfMonthAverages
SELECT day_of_month, AVG(ActualResult) as dayofMonthAvgTranIDCount
FROM
(
	SELECT
		CAST(createdOn AS DATE) AS createdOn,
		CASE
			WHEN DATEPART(day, CAST(createdOn as DATE)) = 2 THEN 'Sec'
			WHEN DATEPART(day, CAST(createdOn as DATE)) = 9 THEN 'Nin'
			ELSE 'NULL'
		END as day_of_month,
		COUNT(tranID) as ActualResult
	FROM BI_Feed.dbo.BI_BDA_Transactions WITH (nolock)
	WHERE createdOn >= DATEADD(day, -91, GETDATE())
	GROUP BY CAST(createdOn AS DATE)
) AS subquery
GROUP BY day_of_month;

-- Create a temporary table for detailed information
CREATE TABLE #DetailInfo (
	transactionDate DATE,
	day_of_week NVARCHAR(20),
	day_of_month NVARCHAR(20),
	ActualResult INT
);

INSERT INTO #DetailInfo
SELECT
	CAST(createdOn as DATE) as transactionDate, 
	CASE
		WHEN DATEPART(WEEKDAY, createdOn) IN (1,2) THEN 'Sun-Mon'
		WHEN DATEPART(WEEKDAY, createdOn) IN (3,4,5) THEN 'Tues-Thur'
		WHEN DATEPART(WEEKDAY, createdOn) = 6 THEN 'Fri'
		WHEN DATEPART(WEEKDAY, createdOn) = 7 THEN 'Sat'
		ELSE 'NULL'
	END as day_of_week,
	CASE
		WHEN DATEPART(day, CAST(createdOn as DATE)) = 2 THEN 'Sec'
		WHEN DATEPART(day, CAST(createdOn as DATE)) = 9 THEN 'Nin'
		ELSE 'NULL'
	END as day_of_month,
	COUNT(tranID) as ActualResult
FROM BI_Feed.dbo.BI_BDA_Transactions WITH (nolock)
WHERE createdOn >= DATEADD(day, -183, GETDATE())
GROUP BY CAST(createdOn as DATE), DATEPART(WEEKDAY, createdOn);

-- Create a temporary table for expected results
CREATE TABLE #ExpectedCalculator (
	transactionDate DATE,
	ExpectedResult INT
);

INSERT INTO #ExpectedCalculator
SELECT
    transactionDate,
    CASE
        WHEN #DayOfMonthAverages.day_of_month IN ('Sec', 'Nin') THEN CAST((dayofMonthAvgTranIDCount * 0.99 + weeklyAvgTranIDCount * 0.01) AS INT)
        ELSE CAST(weeklyAvgTranIDCount AS INT)
    END as ExpectedResult
FROM #DetailInfo
FULL OUTER JOIN #WeeklyAverages on #WeeklyAverages.day_of_week = #DetailInfo.day_of_week
FULL OUTER JOIN #DayOfMonthAverages on #DayOfMonthAverages.day_of_month = #DetailInfo.day_of_month
WHERE transactionDate >= DATEADD(day, -183, GETDATE())
GROUP BY transactionDate, #DayOfMonthAverages.day_of_month, dayofMonthAvgTranIDCount, weeklyAvgTranIDCount;


-- Select query with deviations
SELECT
	#DetailInfo.transactionDate,
	#DayOfMonthAverages.day_of_month,
	CAST(ExpectedResult AS INT) as ExpectedResult,
	ActualResult,
	CASE
		WHEN ActualResult <= ExpectedResult THEN CAST(ExpectedResult - ActualResult AS INT)
		WHEN ActualResult > ExpectedResult THEN CAST(ActualResult - ExpectedResult AS INT)
	END as Deviation
FROM #DetailInfo
FULL OUTER JOIN #WeeklyAverages on #WeeklyAverages.day_of_week = #DetailInfo.day_of_week
FULL OUTER JOIN #DayOfMonthAverages on #DayOfMonthAverages.day_of_month = #DetailInfo.day_of_month
LEFT JOIN #ExpectedCalculator ON #ExpectedCalculator.transactionDate = #DetailInfo.transactionDate
WHERE #DetailInfo.transactionDate >= DATEADD(day, -183, GETDATE())
GROUP BY #DetailInfo.transactionDate, #DayOfMonthAverages.day_of_month, ExpectedResult, ActualResult
ORDER BY #DetailInfo.transactionDate DESC;

-- Drop temporary tables
DROP TABLE #WeeklyAverages;
DROP TABLE #DayOfMonthAverages;
DROP TABLE #DetailInfo;
DROP TABLE #ExpectedCalculator;
