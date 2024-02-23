USE BI_Feed

SELECT id, createdON, tranID, adminNumber, transactionAmount
FROM BI_BDA_Transactions;


-- Finds averages of same day of each month
USE BI_Feed

SELECT DATEPART(day, transactionDate) as DayofMonth, AVG(transactionAmount) as avgamount
FROM
(
	SELECT id, CAST(createdON as DATE) as transactionDate, tranID, adminNumber, transactionAmount
	FROM BI_BDA_Transactions
) AS subquery
GROUP BY DATEPART(day, transactionDate)