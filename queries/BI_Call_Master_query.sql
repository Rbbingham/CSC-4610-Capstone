USE [CapstoneDB]

SELECT
	CAST(localCallStartTime as date) as localCallStartTime, 
	COUNT(callID) as callIDCount
FROM BI_Feed.dbo.BI_Call_Master
GROUP BY CAST(localCallStartTime as date)
ORDER BY CAST(localCallStartTime as date) DESC;
----------------------------------------------------------------
----------------------------------------------------------------
USE [CapstoneDB]
-- Create a temporary table for weekly averages
CREATE TABLE #WeeklyAverages (
	day_of_week NVARCHAR(20),
	ExpectedResult INT
);

-- Query calculates averages of each day (or group of days) of the week
INSERT INTO #WeeklyAverages
SELECT day_of_week, AVG(callIDCount) as ExpectedResult
FROM
(
	-- Subquery to calculate call counts by day of week
	SELECT
		CAST(localCallStartTime as date) as localCallStartTime,
		CASE
			WHEN DATEPART(WEEKDAY, localCallStartTime) = 1 THEN 'Sun'
			WHEN DATEPART(WEEKDAY, localCallStartTime) = 2 THEN 'Mon'
			WHEN DATEPART(WEEKDAY, localCallStartTime) IN (3,4,5) THEN 'Tues-Thur'
			WHEN DATEPART(WEEKDAY, localCallStartTime) = 6 AND COUNT(callID) < 7000 THEN 'Low-Fri'
			WHEN DATEPART(WEEKDAY, localCallStartTime) = 6 AND COUNT(callID) >= 7000 THEN 'High-Fri'
			WHEN DATEPART(WEEKDAY, localCallStartTime) = 7 THEN 'Sat'
			ELSE 'Other'
		END as day_of_week,
		COUNT(callID) as callIDCount
	FROM BI_Feed.dbo.BI_Call_Master WITH (nolock)
	WHERE localCallStartTime >= DATEADD(day, -365, GETDATE())
	GROUP BY CAST(localCallStartTime AS DATE), DATEPART(WEEKDAY, localCallStartTime)
) AS subquery
GROUP BY day_of_week;

-- Create a temporary table for actual result that will be used to connect previous table together
CREATE TABLE #DetailInfo (
	localCallStartTime DATE,
	day_of_week NVARCHAR(20),
	ActualResult INT
);

-- Query calculates actual result (count of callID) as it is not accessible from the previous temp table
-- It also finds the day of week, which is used to join the previous temp table with this one,
-- allowing access to the previously calculated weekly averages.
INSERT INTO #DetailInfo
SELECT
	CAST(localCallStartTime as date) as localCallStartTime,
	CASE
		WHEN DATEPART(WEEKDAY, localCallStartTime) = 1 THEN 'Sun'
		WHEN DATEPART(WEEKDAY, localCallStartTime) = 2 THEN 'Mon'
		WHEN DATEPART(WEEKDAY, localCallStartTime) IN (3,4,5) THEN 'Tues-Thur'
		WHEN DATEPART(WEEKDAY, localCallStartTime) = 6 AND COUNT(callID) < 7000 THEN 'Low-Fri'
		WHEN DATEPART(WEEKDAY, localCallStartTime) = 6 AND COUNT(callID) >= 7000 THEN 'High-Fri'
		WHEN DATEPART(WEEKDAY, localCallStartTime) = 7 THEN 'Sat'
		ELSE 'NULL'
	END as day_of_week,
	COUNT(callID) as ActualResult
FROM BI_Feed.dbo.BI_Call_Master WITH (nolock)
WHERE localCallStartTime >= DATEADD(day, -365, GETDATE())
GROUP BY CAST(localCallStartTime AS DATE), DATEPART(WEEKDAY, localCallStartTime)


-- Query selects necessary information to be put in table
SELECT
	'BI_Call_Master' AS TableName,
	CAST(GETDATE() AS DATE) AS TestRunDate,
	'Call Count' AS TestName,
	ActualResult,
	ExpectedResult,
	ABS(ExpectedResult - ActualResult) as Deviation,
	dbo.CalculateRiskScore(ActualResult, ExpectedResult) as RiskScore,
	GETDATE() AS CreatedOn,
	'[CapstoneDB].[dbo].[BI_Health_BI_Call_Master]' AS CreatedBy,
	NULL AS ModifiedOn,
	NULL AS ModifiedBy
FROM #DetailInfo
FULL OUTER JOIN #WeeklyAverages on #WeeklyAverages.day_of_week = #DetailInfo.day_of_week
WHERE #DetailInfo.localCallStartTime = DATEADD(day, -1, CAST(GETDATE() as DATE))
GROUP BY #DetailInfo.localCallStartTime, ExpectedResult, ActualResult
ORDER BY #DetailInfo.localCallStartTime DESC;

-- Drop temporary tables
DROP TABLE #WeeklyAverages;
DROP TABLE #DetailInfo;