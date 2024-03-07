use BI_Feed;

select Count(ModifedOnDate) as Amount from dbo.BI_BankCore_Funding_Transactions with (nolock)
--where ModifedOnDate = CAST(DATEADD(day, -1, GETDATE()) as DATE);

select CAST(createdOn as DATE), count(ModifedOnDate) from dbo.BI_BankCore_Funding_Transactions with (nolock)
group by CAST(CreatedOn as DATE)
order by CAST(CreatedOn as DATE) DESC;

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