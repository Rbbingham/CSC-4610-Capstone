-- TODO: Replace AccountNumber with productId
SELECT 
	CAST(CreatedOn AS DATE) as CreatedOnDate,
	COUNT(productId) as NumProductID
FROM BI_Feed.dbo.BI_BDA_Balances WITH (nolock) 
WHERE CAST(CreatedOn AS DATE) > '2024-03-04'
GROUP BY CAST(CreatedOn AS DATE) 
ORDER BY CAST(CreatedOn AS DATE) DESC;

SELECT CreatedOn, balanceDate, productId, beginningBalance, endingBalance FROM BI_FEED.dbo.BI_BDA_Balances WITH (nolock);


WITH Weekly_Averages AS (
	SELECT 
		timespan, 
		AVG(numProductID) as AverageResult
	FROM (
		SELECT
			CAST(CreatedOn as DATE) as CreatedOn, 
			DATEPART(day, CAST(createdOn as DATE)) as day_of_month, 
			COUNT(productId) as numProductID,
			CASE
				WHEN DATEPART(WEEKDAY, CreatedOn) IN (1, 2,3,4,5,7) THEN 'Mon-Thurs, Sat'
				WHEN DATEPART(WEEKDAY, CreatedOn) = 6 THEN 'Fri'
				ELSE 'NULL'
			END as timespan
		FROM BI_Feed.dbo.BI_BDA_Balances WITH (nolock)
		WHERE CAST(CreatedOn AS DATE) >= '2024-01-01'
		GROUP BY DATEPART(Weekday, CreatedOn), CAST(CreatedOn as date)
) as subquery
GROUP BY timespan)
,
DetailInfo AS (
	SELECT
			CAST(CreatedOn as DATE) as CreatedOn, 
			DATEPART(day, CAST(createdOn as DATE)) as day_of_month, 
			COUNT(productId) as ActualResult,
			CASE
				WHEN DATEPART(WEEKDAY, CreatedOn) IN (1, 2,3,4,5,7) THEN 'Mon-Thurs, Sat'
				WHEN DATEPART(WEEKDAY, CreatedOn) = 6 THEN 'Fri'
				ELSE 'NULL'
			END as timespan
		FROM BI_Feed.dbo.BI_BDA_Balances WITH (nolock)
		WHERE CAST(CreatedOn AS DATE) >= '2024-01-01'
		GROUP BY DATEPART(Weekday, CreatedOn), CAST(CreatedOn as date)
)
SELECT
	CreatedOn,
	DetailInfo.timespan,
	day_of_month,
	AverageResult as ExpectedResult,
	ActualResult,
	CASE
		WHEN ActualResult <= AverageResult THEN AverageResult - ActualResult
		WHEN ActualResult > AverageResult THEN ActualResult - AverageResult
	END as Deviation
	FROM Weekly_Averages
FULL OUTER JOIN DetailInfo ON Weekly_Averages.timespan = DetailInfo.timespan
GROUP BY CreatedOn, DetailInfo.timespan, day_of_month, AverageResult, ActualResult
ORDER BY CreatedOn DESC;