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
	weeklyIDCountAvg DECIMAL(18,2)
);

INSERT INTO #WeeklyAverages
SELECT day_of_week, AVG(callIDCount) as weeklyIDCountAvg
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
	WHERE localCallStartTime >= DATEADD(day, -183, GETDATE())
	GROUP BY CAST(localCallStartTime AS DATE), DATEPART(WEEKDAY, localCallStartTime)
	ORDER BY CAST(localCallStartTime AS DATE) DESC
) AS subquery
GROUP BY day_of_week;

