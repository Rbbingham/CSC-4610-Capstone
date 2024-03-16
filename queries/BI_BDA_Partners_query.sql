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