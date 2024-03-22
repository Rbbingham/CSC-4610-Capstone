use BI_Feed;

select Count(ModifedOnDate) as Amount from dbo.BI_BankCore_Funding_Transactions with (nolock);
--where ModifedOnDate = CAST(DATEADD(day, -1, GETDATE()) as DATE);

select CAST(createdOn as DATE), count(ModifedOnDate) from dbo.BI_BankCore_Funding_Transactions with (nolock)
group by CAST(createdOn as DATE)
order by CAST(createdOn as DATE) DESC;




/*------------------------------------------------------------------------------------------------------
SELECT
	timespan,
	AVG(modifiedCount)
FROM (
	select 
		CAST(createdOn as DATE) as createdOn, 
		count(ModifedOnDate) as modifiedCount,
		DATEPART(Weekday, createdOn) AS day_of_week,
		CASE
			WHEN DATEPART(DAY, CAST(createdOn as DATE)) = 1 THEN 'FirstofMonth'
			WHEN DATEPART(WEEKDAY, createdOn) in (1,2,3,4,5,6) THEN 'Sun-Fri'
			WHEN DATEPART(WEEKDAY, createdOn) = 7 THEN 'Sat'
			ELSE 'NULL'
		END as timespan
	from BI_Feed.dbo.BI_BankCore_Funding_Transactions with (nolock)
	where CreatedOn >= DATEADD(day, -183, GETDATE())
	group by DATEPART(Weekday, createdOn), CAST(createdOn as DATE)
) as subquery
group by timespan;
	
--------------------------------------------------------------------------------------------------
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
	*/