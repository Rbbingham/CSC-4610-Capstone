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
			WHEN DATEPART(WEEKDAY, connectTime) IN (1,7) THEN 3801
			WHEN DATEPART(WEEKDAY, connectTime) IN (2,3,4,5) THEN 4712
			WHEN DATEPART(WEEKDAY, connectTime) = 6 THEN 6580
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
	day_of_week,
	AVG(ActualResult) as AverageResult
FROM (
	SELECT -- For each day, calculate count of calls and compare against expected data
		CAST(connectTime AS DATE) AS connectTime,
		DATEPART(WEEKDAY, connectTime) AS day_of_week,
		COUNT(distinct callID) AS ActualResult
	FROM dbo.BI_Call_Detail WITH (nolock)
	WHERE DATEPART(YEAR, connectTime) >= 2023
	GROUP BY DATEPART(WEEKDAY, connectTime), CAST(connectTime AS DATE)
) AS subquery
GROUP BY
	day_of_week
ORDER BY
	day_of_week;



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