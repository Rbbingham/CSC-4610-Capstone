--------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------
-- BI_Call_Detail Test (final updated dynamic query with averages from recent 365 days)
WITH WeeklyAverages AS (
	SELECT 
		timespan, 
		AVG(ActualResult) as AverageResult
	FROM (
		SELECT -- For each day, calculate count of calls and compare against expected data
			CAST(connectTime AS DATE) AS connectTime,
			DATEPART(WEEKDAY, connectTime) AS day_of_week,
			CASE
				WHEN DATEPART(WEEKDAY, connectTime) IN (1,7) THEN 'Sat-Sun'
				WHEN DATEPART(WEEKDAY, connectTime) IN (2,3,4,5) THEN 'Mon-Thu'
				WHEN DATEPART(WEEKDAY, connectTime) = 6 THEN 'Fri'
				ELSE 'NULL'
			END as timespan,
			COUNT(distinct callID) AS ActualResult
		FROM BI_Feed.dbo.BI_Call_Detail WITH (nolock)
		WHERE connectTime >= DATEADD(day, -365, GETDATE())
		GROUP BY DATEPART(WEEKDAY, connectTime), CAST(connectTime AS DATE)
	) AS subquery
	GROUP BY timespan
),
DetailInfo AS (
	SELECT -- For each day, calculate count of calls and compare against expected data
		CAST(connectTime AS DATE) AS connectTime,
		DATEPART(WEEKDAY, connectTime) AS day_of_week,
		COUNT(distinct callID) AS ActualResult,
		CASE
			WHEN DATEPART(WEEKDAY, connectTime) IN (1,7) THEN 'Sat-Sun'
			WHEN DATEPART(WEEKDAY, connectTime) IN (2,3,4,5) THEN 'Mon-Thu'
			WHEN DATEPART(WEEKDAY, connectTime) = 6 THEN 'Fri'
			ELSE 'NULL'
		END as timespan
	FROM BI_Feed.dbo.BI_Call_Detail WITH (nolock)
	GROUP BY DATEPART(WEEKDAY, connectTime), CAST(connectTime AS DATE)
)
SELECT 
	connectTime,
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
WHERE connectTime = DATEADD(day, -1, CAST(GETDATE() AS DATE))
GROUP BY connectTime, DetailInfo.timespan, day_of_week, AverageResult, ActualResult
ORDER BY connectTime DESC;
--------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------





-- BI_Call_Detail Test (hardcoded query)
USE BI_Feed
SELECT 
	connectTime, day_of_week, ExpectedResult, ActualResult,
	CASE
		WHEN ActualResult <= ExpectedResult THEN ExpectedResult - ActualResult
		WHEN ActualResult > ExpectedResult THEN ActualResult - ExpectedResult
	END as Variance
FROM (
	SELECT -- For each day, calculate count of calls and compare against expected data
		CAST(connectTime AS DATE) AS connectTime,
		DATEPART(WEEKDAY, connectTime) as day_of_week,
		CASE
			WHEN DATEPART(WEEKDAY, connectTime) IN (1,7) THEN 3797
			WHEN DATEPART(WEEKDAY, connectTime) IN (2,3,4,5) THEN 4716
			WHEN DATEPART(WEEKDAY, connectTime) = 6 THEN 6647
			ELSE 686602
		END as ExpectedResult,
		COUNT(distinct callID) AS ActualResult
	FROM dbo.BI_Call_Detail WITH (nolock)
	GROUP BY CAST(connectTime AS DATE), DATEPART(WEEKDAY, connectTime)
) as Subquery
GROUP BY connectTime, day_of_week, ExpectedResult, ActualResult
ORDER BY connectTime DESC;



-- BI_Call_Detail calculate averages of each weekday (used to hardcode test)
USE BI_Feed

SELECT
	timespan,
	AVG(ActualResult) as AverageResult
FROM (
	SELECT -- For each day, calculate count of calls and compare against expected data
		CAST(connectTime AS DATE) AS connectTime,
		DATEPART(WEEKDAY, connectTime) AS day_of_week,
		CASE
			WHEN DATEPART(WEEKDAY, connectTime) IN (1,7) THEN 'Sat-Sun'
			WHEN DATEPART(WEEKDAY, connectTime) IN (2,3,4,5) THEN 'Mon-Thu'
			WHEN DATEPART(WEEKDAY, connectTime) = 6 THEN 'Fri'
			ELSE 'NULL'
		END as timespan,
		COUNT(distinct callID) AS ActualResult
	FROM dbo.BI_Call_Detail WITH (nolock)
	WHERE connectTime >= DATEADD(day, -365, GETDATE())
	GROUP BY DATEPART(WEEKDAY, connectTime), CAST(connectTime AS DATE)
) AS subquery
GROUP BY
	timespan
ORDER BY
	timespan;


-- BI_Call_Detail Test (original approach)
USE BI_Feed

SELECT -- For each day, calculate count of calls and compare against expected data
	CAST(connectTime AS DATE) AS connectTime,
	'4000-8000' as ExpectedRange,
	COUNT(distinct callID) AS ActualResult,
	CASE
		WHEN COUNT(DISTINCT callID) < 4000 THEN 4000 - COUNT(DISTINCT callID)
		WHEN COUNT(DISTINCT callID) > 8000 THEN COUNT(DISTINCT callID) - 8000
		ELSE 0
	END as Variance
FROM dbo.BI_Call_Detail WITH (nolock)
GROUP BY CAST(connectTime AS DATE)
ORDER BY CAST(connectTime AS DATE) DESC;



-- BI_Call_Detail Test (work in progress to dynamically calculate averages)
USE BI_Feed

SELECT -- For each day, calculate count of calls and compare against expected data
	DATEPART(WEEKDAY, connectTime) AS day_of_week,
	AVG(COUNT(distinct callID)) AS AVG_Result
FROM dbo.BI_Call_Detail WITH (nolock)
GROUP BY DATEPART(WEEKDAY, connectTime)
ORDER BY day_of_week;

USE BI_Feed
SELECT 
FROM (
	SELECT
		day_of_week,
		AVG(ActualResult) as AverageResult
	FROM (
		SELECT -- For each day, calculate count of calls and compare against expected data
			CAST(connectTime AS DATE) AS connectTime,
			DATEPART(WEEKDAY, connectTime) AS day_of_week,
			COUNT(distinct callID) AS ActualResult
		FROM dbo.BI_Call_Detail WITH (nolock)
		GROUP BY DATEPART(WEEKDAY, connectTime), CAST(connectTime AS DATE)
	) AS subquery
	GROUP BY
		day_of_week
) as subquery











-- BI_Call_Detail Test (final updated query)
USE BI_Feed
SELECT 
	connectTime, day_of_week, ExpectedResult, ActualResult,
	CASE
		WHEN ActualResult <= ExpectedResult THEN ExpectedResult - ActualResult
		WHEN ActualResult > ExpectedResult THEN ActualResult - ExpectedResult
	END as Variance
FROM (
	SELECT -- For each day, calculate count of calls and compare against expected data
		CAST(connectTime AS DATE) AS connectTime,
		DATEPART(WEEKDAY, connectTime) as day_of_week,
		CASE
			WHEN DATEPART(WEEKDAY, connectTime) IN (1,7) THEN 3797
			WHEN DATEPART(WEEKDAY, connectTime) IN (2,3,4,5) THEN 4716
			WHEN DATEPART(WEEKDAY, connectTime) = 6 THEN 6647
			ELSE 686602
		END as ExpectedResult,
		COUNT(distinct callID) AS ActualResult
	FROM dbo.BI_Call_Detail WITH (nolock)
	GROUP BY CAST(connectTime AS DATE), DATEPART(WEEKDAY, connectTime)
) as Subquery
GROUP BY connectTime, day_of_week, ExpectedResult, ActualResult
ORDER BY connectTime DESC;





-- BI_Call_Detail Test (final updated query)
USE BI_Feed
SELECT 
	connectTime, day_of_week, ExpectedResult, ActualResult,
	CASE
		WHEN ActualResult <= ExpectedResult THEN ExpectedResult - ActualResult
		WHEN ActualResult > ExpectedResult THEN ActualResult - ExpectedResult
	END as Variance
FROM (
	SELECT -- For each day, calculate count of calls and compare against expected data
		CAST(connectTime AS DATE) AS connectTime,
		DATEPART(WEEKDAY, connectTime) AS day_of_week,
		CASE
			WHEN DATEPART(WEEKDAY, connectTime) IN (1,7) THEN 'Sat-Sun'
			WHEN DATEPART(WEEKDAY, connectTime) IN (2,3,4,5) THEN 'Mon-Thu'
			WHEN DATEPART(WEEKDAY, connectTime) = 6 THEN 'Fri'
			ELSE 'NULL'
		END as timespan,
		COUNT(distinct callID) AS ActualResult
	FROM dbo.BI_Call_Detail WITH (nolock)
	WHERE connectTime >= DATEADD(day, -365, GETDATE())
	GROUP BY DATEPART(WEEKDAY, connectTime), CAST(connectTime AS DATE)
) as Subquery
GROUP BY connectTime, day_of_week, ExpectedResult, ActualResult
ORDER BY connectTime DESC;


WITH WeeklyAverages AS (
	SELECT 
		timespan, 
		AVG(ActualResult) as AverageResult
	FROM (
		SELECT -- For each day, calculate count of calls and compare against expected data
			CAST(connectTime AS DATE) AS connectTime,
			DATEPART(WEEKDAY, connectTime) AS day_of_week,
			CASE
				WHEN DATEPART(WEEKDAY, connectTime) IN (1,7) THEN 'Sat-Sun'
				WHEN DATEPART(WEEKDAY, connectTime) IN (2,3,4,5) THEN 'Mon-Thu'
				WHEN DATEPART(WEEKDAY, connectTime) = 6 THEN 'Fri'
				ELSE 'NULL'
			END as timespan,
			COUNT(distinct callID) AS ActualResult
		FROM dbo.BI_Call_Detail WITH (nolock)
		WHERE connectTime >= DATEADD(day, -365, GETDATE())
		GROUP BY DATEPART(WEEKDAY, connectTime), CAST(connectTime AS DATE)
	) AS subquery
	GROUP BY timespan
),
DetailInfo AS (
	SELECT -- For each day, calculate count of calls and compare against expected data
		CAST(connectTime AS DATE) AS connectTime,
		DATEPART(WEEKDAY, connectTime) AS day_of_week,
		COUNT(distinct callID) AS ActualResult,
		CASE
			WHEN DATEPART(WEEKDAY, connectTime) IN (1,7) THEN 'Sat-Sun'
			WHEN DATEPART(WEEKDAY, connectTime) IN (2,3,4,5) THEN 'Mon-Thu'
			WHEN DATEPART(WEEKDAY, connectTime) = 6 THEN 'Fri'
			ELSE 'NULL'
		END as timespan
	FROM dbo.BI_Call_Detail WITH (nolock)
	GROUP BY DATEPART(WEEKDAY, connectTime), CAST(connectTime AS DATE)
)
SELECT 
	connectTime,
	DetailInfo.timespan,
	day_of_week,
	AverageResult as ExpectedResult,
	ActualResult
FROM WeeklyAverages
FULL OUTER JOIN DetailInfo ON WeeklyAverages.timespan = DetailInfo.timespan
GROUP BY connectTime, DetailInfo.timespan, day_of_week, AverageResult, ActualResult
ORDER BY connectTime DESC;













--------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------
-- BI_Call_Detail Test (final updated dynamic query with averages from recent 365 days)
SELECT ActualResult, ExpectedResult, Variance
FROM (
	WITH WeeklyAverages AS (
		SELECT 
			timespan, 
			AVG(ActualResult) as AverageResult
		FROM (
			SELECT -- For each day, calculate count of calls and compare against expected data
				CAST(connectTime AS DATE) AS connectTime,
				DATEPART(WEEKDAY, connectTime) AS day_of_week,
				CASE
					WHEN DATEPART(WEEKDAY, connectTime) IN (1,7) THEN 'Sat-Sun'
					WHEN DATEPART(WEEKDAY, connectTime) IN (2,3,4,5) THEN 'Mon-Thu'
					WHEN DATEPART(WEEKDAY, connectTime) = 6 THEN 'Fri'
					ELSE 'NULL'
				END as timespan,
				COUNT(distinct callID) AS ActualResult
			FROM BI_Feed.dbo.BI_Call_Detail WITH (nolock)
			WHERE connectTime >= DATEADD(day, -365, GETDATE())
			GROUP BY DATEPART(WEEKDAY, connectTime), CAST(connectTime AS DATE)
		) AS subquery
		GROUP BY timespan
	),
	DetailInfo AS (
		SELECT -- For each day, calculate count of calls and compare against expected data
			CAST(connectTime AS DATE) AS connectTime,
			DATEPART(WEEKDAY, connectTime) AS day_of_week,
			COUNT(distinct callID) AS ActualResult,
			CASE
				WHEN DATEPART(WEEKDAY, connectTime) IN (1,7) THEN 'Sat-Sun'
				WHEN DATEPART(WEEKDAY, connectTime) IN (2,3,4,5) THEN 'Mon-Thu'
				WHEN DATEPART(WEEKDAY, connectTime) = 6 THEN 'Fri'
				ELSE 'NULL'
			END as timespan
		FROM BI_Feed.dbo.BI_Call_Detail WITH (nolock)
		GROUP BY DATEPART(WEEKDAY, connectTime), CAST(connectTime AS DATE)
	)
	SELECT 
		connectTime,
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
	WHERE connectTime = DATEADD(day, -1, CAST(GETDATE() AS DATE))
	GROUP BY connectTime, DetailInfo.timespan, day_of_week, AverageResult, ActualResult
	ORDER BY connectTime DESC
) AS ResultSummary;
--------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------