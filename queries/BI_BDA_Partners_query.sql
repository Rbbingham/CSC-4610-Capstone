SELECT *
FROM BI_Feed.dbo.BI_BDA_Partners with (nolock)
ORDER BY id DESC;
-------------------------------------------------------------------
select * from BI_BDA_Partners order by id Desc;

select Count(partnerId) from BI_BDA_Partners
select Count(Distinct partnerId) from BI_BDA_Partners

select Count(partnerName) from BI_BDA_Partners
select Count(Distinct partnerName) from BI_BDA_Partners

select Count(*) from BI_BDA_Partners

Select Count(productId) from BI_BDA_Partners with(nolock)
Select Count(Distinct productId) from BI_BDA_Partners with(nolock)

SELECT COUNT(ID)from BI_BDA_Partners with(nolock)
SELECT COUNT(DISTINCT ID)from BI_BDA_Partners with (nolock)
-------------------------------------------------------------------

-- total number of records in the table
SELECT day_of_week, AVG(IDCount) as weeklyIDCountAvg
FROM 
(
	SELECT
		CAST(createdOn AS DATE) AS createdOn,
		CASE
			WHEN DATEPART(WEEKDAY, createdOn) = 1 THEN 'Sun'
			WHEN DATEPART(WEEKDAY, createdOn) = 2 THEN 'Mon'
			WHEN DATEPART(WEEKDAY, createdOn) = 3 THEN 'Tues'
			WHEN DATEPART(WEEKDAY, createdOn) = 4 THEN 'Wed'
			WHEN DATEPART(WEEKDAY, createdOn) = 5 THEN 'Thur'
			WHEN DATEPART(WEEKDAY, createdOn) = 6 THEN 'Fri'
			WHEN DATEPART(WEEKDAY, createdOn) = 7 THEN 'Sat'
			ELSE 'NULL'
		END as day_of_week,
		COUNT(ID) as IDCount
	FROM BI_Feed.dbo.BI_BDA_Partners
	WHERE createdOn >= DATEADD(day, -365, CAST(GETDATE() AS DATE))
	GROUP BY CAST(createdOn AS DATE), DATEPART(WEEKDAY, createdOn)
	--ORDER BY CAST(createdOn AS DATE) DESC
) as subquery
GROUP BY day_of_week;


-- count of distinct products
SELECT day_of_week, AVG(IDCount) as weeklyIDCountAvg
FROM 
(
	SELECT
		CAST(createdOn AS DATE) AS createdOn,
		CASE
			WHEN DATEPART(WEEKDAY, createdOn) = 1 THEN 'Sun'
			WHEN DATEPART(WEEKDAY, createdOn) = 2 THEN 'Mon'
			WHEN DATEPART(WEEKDAY, createdOn) = 3 THEN 'Tues'
			WHEN DATEPART(WEEKDAY, createdOn) = 4 THEN 'Wed'
			WHEN DATEPART(WEEKDAY, createdOn) = 5 THEN 'Thur'
			WHEN DATEPART(WEEKDAY, createdOn) = 6 THEN 'Fri'
			WHEN DATEPART(WEEKDAY, createdOn) = 7 THEN 'Sat'
			ELSE 'NULL'
		END as day_of_week,
		COUNT(distinct partnerId) as IDCount
	FROM BI_Feed.dbo.BI_BDA_Partners
	WHERE createdOn >= DATEADD(day, -365, CAST(GETDATE() AS DATE))
	GROUP BY CAST(createdOn AS DATE), DATEPART(WEEKDAY, createdOn)
	--ORDER BY CAST(createdOn AS DATE) DESC
) as subquery
GROUP BY day_of_week;

--count of distinct partners
SELECT day_of_week, AVG(IDCount) as weeklyIDCountAvg
FROM 
(
	SELECT
		CAST(createdOn AS DATE) AS createdOn,
		CASE
			WHEN DATEPART(WEEKDAY, createdOn) = 1 THEN 'Sun'
			WHEN DATEPART(WEEKDAY, createdOn) = 2 THEN 'Mon'
			WHEN DATEPART(WEEKDAY, createdOn) = 3 THEN 'Tues'
			WHEN DATEPART(WEEKDAY, createdOn) = 4 THEN 'Wed'
			WHEN DATEPART(WEEKDAY, createdOn) = 5 THEN 'Thur'
			WHEN DATEPART(WEEKDAY, createdOn) = 6 THEN 'Fri'
			WHEN DATEPART(WEEKDAY, createdOn) = 7 THEN 'Sat'
			ELSE 'NULL'
		END as day_of_week,
		COUNT(distinct productId) as IDCount
	FROM BI_Feed.dbo.BI_BDA_Partners
	WHERE createdOn >= DATEADD(day, -365, CAST(GETDATE() AS DATE))
	GROUP BY CAST(createdOn AS DATE), DATEPART(WEEKDAY, createdOn)
	--ORDER BY CAST(createdOn AS DATE) DESC
) as subquery
GROUP BY day_of_week;

--------------------------------------------------------------------------------

CREATE TABLE #WeeklyAverages (
	day_of_week NVARCHAR(20),
	weeklyIDCountAvg DECIMAL(18,2)
);

INSERT INTO #WeeklyAverages
SELECT day_of_week, AVG(IDCount) as weeklyIDCountAvg
FROM 
(
	SELECT
		CAST(createdOn AS DATE) AS createdOn,
		CASE
			WHEN DATEPART(WEEKDAY, createdOn) = 1 THEN 'Sun'
			WHEN DATEPART(WEEKDAY, createdOn) IN (2,3,5,6,7) THEN 'Mon-Tues,Thu-Sat'
			WHEN DATEPART(WEEKDAY, createdOn) = 4 THEN 'Wed'
			ELSE 'NULL'
		END as day_of_week,
		COUNT(ID) as IDCount
	FROM BI_Feed.dbo.BI_BDA_Partners
	WHERE createdOn >= DATEADD(day, -365, CAST(GETDATE() AS DATE))
	GROUP BY CAST(createdOn AS DATE), DATEPART(WEEKDAY, createdOn)
	--ORDER BY CAST(createdOn AS DATE) DESC
) as subquery
GROUP BY day_of_week;

CREATE TABLE #DetailInfo (
	createdOn DATE,
	day_of_week NVARCHAR(20),
	ActualResult INT
);

INSERT INTO #DetailInfo
SELECT
	CAST(createdOn AS DATE) AS createdOn,
	CASE
		WHEN DATEPART(WEEKDAY, createdOn) = 1 THEN 'Sun'
		WHEN DATEPART(WEEKDAY, createdOn) IN (2,3,5,6,7) THEN 'Mon-Tues,Thu-Sat'
		WHEN DATEPART(WEEKDAY, createdOn) = 4 THEN 'Wed'
		ELSE 'NULL'
	END as day_of_week,
	COUNT(ID) as IDCount
FROM BI_Feed.dbo.BI_BDA_Partners
WHERE createdOn >= DATEADD(day, -365, CAST(GETDATE() AS DATE))
GROUP BY CAST(createdOn AS DATE), DATEPART(WEEKDAY, createdOn)
ORDER BY CAST(createdOn AS DATE) DESC


SELECT
	#DetailInfo.createdOn,
	#DetailInfo.day_of_week,
	CAST(#WeeklyAverages.weeklyIDCountAvg as INT) as ExpectedResult,
	ActualResult,
	CAST(ABS(#WeeklyAverages.weeklyIDCountAvg - ActualResult) AS INT) as Deviation
FROM #DetailInfo
FULL OUTER JOIN #WeeklyAverages on #WeeklyAverages.day_of_week = #DetailInfo.day_of_week
WHERE #DetailInfo.createdOn >= DATEADD(day, -365, GETDATE())
GROUP BY #DetailInfo.createdOn, #DetailInfo.day_of_week, #WeeklyAverages.weeklyIDCountAvg, ActualResult
ORDER BY #DetailInfo.createdOn DESC;

-- drop tables
DROP TABLE #WeeklyAverages;
DROP TABLE #DetailInfo;
--------------------------------------------------------

Create table #DailySnapshot(
	SnapshotDate Date Primary key,
	TotalRecords INT,
	DistinctProducts INT,
	DistinctPartners INT
	);

INSERT INTO #DailySnapshot (
	SnapshotDate,
	TotalRecords,
	DistinctProducts,
	DistinctPartners)
SELECT 
	GETDATE(),
	COUNT(*),
	COUNT(DISTINCT PRODUCTID),
	COUNT(PartnerID)
FROM BI_Feed.dbo.BI_BDA_Partners;

SELECT 
	CASE 
		WHEN
			a.TotalRecords = b.TotalRecords
			AND a.DistinctProducts= b.DistinctProducts
			AND a.DistinctPartners = b.DistinctPartners
			THEN 'PASS'
		ELSE 'FAIL'
	END as TestResult
FROM #DailySnapshot AS a
	  JOIN #DailySnapshot b ON a.SnapshotDate = DATEADD(day,-1, b.SnapshotDate)
WHERE 
	a.SnapshotDate = CONVERT(date,GetDate());

DROP TABLE #DailySnapShot

SELECT * FROM [BI_Feed].[dbo].[BI_BDA_Partners];

SELECT
	CASE
		WHEN ((CAST(ABS((TodaysCount + 10) - YesterdaysCount) AS FLOAT) / CAST(YesterdaysCount AS FLOAT)) * 1000) >= 2 THEN 'FAIL'
		ELSE 'PASS'
	END
FROM (
		SELECT
			COUNT(createdOn) AS TodaysCount
		FROM
			[BI_Feed].[dbo].[BI_BDA_Partners]
	) AS tb1, (
		SELECT
			COUNT(createdOn) AS YesterdaysCount
		FROM
			[BI_Feed].[dbo].[BI_BDA_Partners]
		WHERE
			CAST(createdOn AS DATE) < CAST(GETDATE() AS DATE)
	) AS tb2;