SELECT
	CAST(localCallStartTime as date) as localCallStartTime, 
	COUNT(callID) as callIDCount
FROM BI_Feed.dbo.BI_Call_Master
GROUP BY CAST(localCallStartTime as date)
ORDER BY CAST(localCallStartTime as date) DESC;
----------------------------------------------------------------

-- Create a temporary table for weekly averages
CREATE TABLE #WeeklyAverages (
	day_of_week NVARCHAR(20),
	ExpectedResult INT
);

INSERT INTO #WeeklyAverages
SELECT day_of_week, AVG(callIDCount) as ExpectedResult
FROM
(
	SELECT
		CAST(localCallStartTime as date) as localCallStartTime,
		CASE
			WHEN DATEPART(WEEKDAY, localCallStartTime) = 1 THEN 'Sun'
			WHEN DATEPART(WEEKDAY, localCallStartTime) = 2 THEN 'Mon'
			WHEN DATEPART(WEEKDAY, localCallStartTime) IN (3,4,5) THEN 'Tues-Thur'
			WHEN DATEPART(WEEKDAY, localCallStartTime) = 6 THEN 'Fri'
			WHEN DATEPART(WEEKDAY, localCallStartTime) = 7 THEN 'Sat'
			ELSE 'NULL'
		END as day_of_week,
		COUNT(callID) as callIDCount
	FROM BI_Feed.dbo.BI_Call_Master WITH (nolock)
	WHERE localCallStartTime >= DATEADD(day, -365, GETDATE())
	GROUP BY CAST(localCallStartTime AS DATE), DATEPART(WEEKDAY, localCallStartTime)
) AS subquery
GROUP BY day_of_week;

-- Create a temporary table for detailed information
CREATE TABLE #DetailInfo (
	localCallStartTime DATE,
	day_of_week NVARCHAR(20),
	ActualResult INT
);

INSERT INTO #DetailInfo
SELECT
	CAST(localCallStartTime as date) as localCallStartTime,
	CASE
		WHEN DATEPART(WEEKDAY, localCallStartTime) = 1 THEN 'Sun'
		WHEN DATEPART(WEEKDAY, localCallStartTime) = 2 THEN 'Mon'
		WHEN DATEPART(WEEKDAY, localCallStartTime) IN (3,4,5) THEN 'Tues-Thur'
		WHEN DATEPART(WEEKDAY, localCallStartTime) = 6 THEN 'Fri'
		WHEN DATEPART(WEEKDAY, localCallStartTime) = 7 THEN 'Sat'
		ELSE 'NULL'
	END as day_of_week,
	COUNT(callID) as ActualResult
FROM BI_Feed.dbo.BI_Call_Master WITH (nolock)
WHERE localCallStartTime >= DATEADD(day, -365, GETDATE())
GROUP BY CAST(localCallStartTime AS DATE), DATEPART(WEEKDAY, localCallStartTime)


-- Select query with deviations
SELECT
	'BI_Call_Master' AS TableName,
	CAST(GETDATE() AS DATE) AS TestRunDate,
	'Call Count' AS TestName,
	ActualResult,
	ExpectedResult,
	ABS(ExpectedResult - ActualResult) as Deviation,
	NULL as RiskScore,
	GETDATE() AS CreatedOn,
	'[CapstoneDB].[dbo].[BI_Health_BI_Call_Master]' AS CreatedBy,
	NULL AS ModifiedOn,
	NULL AS ModifiedBy
FROM #DetailInfo
FULL OUTER JOIN #WeeklyAverages on #WeeklyAverages.day_of_week = #DetailInfo.day_of_week
WHERE #DetailInfo.localCallStartTime = DATEADD(day, -2, CAST(GETDATE() as DATE))
GROUP BY #DetailInfo.localCallStartTime, ExpectedResult, ActualResult
ORDER BY #DetailInfo.localCallStartTime DESC;

-- Drop temporary tables
DROP TABLE #WeeklyAverages;
DROP TABLE #DetailInfo;