USE BI_Feed

SELECT id, createdON, tranID, adminNumber, transactionAmount
FROM BI_BDA_Transactions;



USE BI_Feed

SELECT timespan, AVG(transactionAmount) as avgamount
FROM
(
	SELECT id, CAST(createdON as DATE) as transactionDate, tranID, adminNumber, transactionAmount,
	CASE
			WHEN DATEPART(WEEKDAY, createdOn) = 1 THEN 1
			WHEN DATEPART(WEEKDAY, createdOn) = 2 THEN 2
			WHEN DATEPART(WEEKDAY, createdOn) = 3 THEN 3
			WHEN DATEPART(WEEKDAY, createdOn) = 4 THEN 4
			WHEN DATEPART(WEEKDAY, createdOn) = 5 THEN 5
			WHEN DATEPART(WEEKDAY, createdOn) = 6 THEN 6
			WHEN DATEPART(WEEKDAY, createdOn) = 7 THEN 7
			ELSE 'NULL'
	END as timespan
	FROM BI_BDA_Transactions
	WHERE createdOn >= DATEADD(day, -365, GETDATE())
) AS subquery
GROUP BY timespan
ORDER BY timespan
------------------------------------------------------------------
------------------------------------------------------------------
SELECT timespan, AVG(transactionAmount) as avgamount
FROM
(
	SELECT id, CAST(createdON as DATE) as transactionDate, tranID, adminNumber, transactionAmount,
	CASE
			WHEN DATEPART(WEEKDAY, createdOn) in (1,2) THEN 'Sun-Mon'
			WHEN DATEPART(WEEKDAY, createdOn) in (3,4,5,6,7) THEN 'Tues-Sat'
			ELSE 'NULL'
	END as timespan
	FROM BI_BDA_Transactions
	WHERE createdOn >= DATEADD(day, -365, GETDATE())
) AS subquery
GROUP BY timespan
ORDER BY timespan



















USE BI_Feed

SELECT transactionDate, COUNT(transactionAmount) as amountCount
FROM
(
	SELECT id, CAST(createdON as DATE) as transactionDate, tranID, adminNumber, transactionAmount
	FROM BI_BDA_Transactions
	WHERE createdOn >= DATEADD(day, -365, GETDATE())
) AS subquery
GROUP BY transactionDate
ORDER BY transactionDate