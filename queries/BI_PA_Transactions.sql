select *
from BI_Feed.dbo.BI_PA_Transactions;



-----------------------------------------------------------
SELECT 
	CAST(transactionDate as date) as TransactionDate,
	COUNT(transactionReferenceId) as TransactionCount,
	COUNT(distinct paymentAccountId) as PaymentAccountId
FROM BI_Feed.dbo.BI_PA_Transactions
GROUP BY Cast(transactionDate as date)
ORDER BY Cast(transactionDate as date) DESC;


SELECT 
	CAST(transactionDate as date) as TransactionDate,
	COUNT(transactionReferenceId) as TransactionCount,
	COUNT(distinct paymentAccountId) as PaymentAccountId,
	DATEPART(Weekday, transactionDate) AS day_of_week,
	CASE
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
GROUP BY DATEPART(Weekday, transactionDate), CAST(transactionDate as date)
ORDER BY Cast(transactionDate as date) DESC;