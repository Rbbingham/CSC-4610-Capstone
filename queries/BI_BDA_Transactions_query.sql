USE BI_Feed

SELECT top 10 id, createdON, tranID, adminNumber, transactionAmount
FROM BI_BDA_Transactions;

-----------------------------------------------------------------------------------------
USE BI_Feed

SELECT day_of_month, AVG(tranIDCount) as avgTranIDCount
FROM
(
	SELECT 
		CAST(createdOn as DATE) as transactionDate, 
		DATEPART(day, CAST(createdOn as DATE)) as day_of_month, 
		COUNT(tranID) as tranIDCount
	FROM BI_BDA_Transactions
	WHERE createdOn >= DATEADD(day, -365, GETDATE())
	GROUP BY CAST(createdON as DATE)
) AS subquery
GROUP BY day_of_month
ORDER BY day_of_month;
-------------------------------------------------------------------------------------------
SELECT
	CAST(createdOn as DATE) as transactionDate, 
	DATEPART(day, CAST(createdOn as DATE)) as day_of_month,
	COUNT(tranID) as tranIDCount
FROM BI_BDA_Transactions
GROUP BY CAST(createdOn as DATE);
--------------------------------------------------------------------

WITH AveragesByDay AS (
	SELECT day_of_month, AVG(tranIDCount) as avgTranIDCount
	FROM
	(
		SELECT 
			CAST(createdOn as DATE) as transactionDate, 
			DATEPART(day, CAST(createdOn as DATE)) as day_of_month, 
			COUNT(tranID) as tranIDCount
		FROM BI_BDA_Transactions
		WHERE createdOn >= DATEADD(day, -365, GETDATE())
		GROUP BY CAST(createdON as DATE)
	) AS subquery
	GROUP BY day_of_month
),
DetailInfo AS (
	SELECT
		CAST(createdOn as DATE) as transactionDate, 
		DATEPART(day, CAST(createdOn as DATE)) as day_of_month,
		COUNT(tranID) as tranIDCount
	FROM BI_BDA_Transactions
	GROUP BY CAST(createdOn as DATE)
)
SELECT
	
FROM AveragesByDay
FULL OUTER JOIN DetailInfo on AveragesByDay.day_of_month = DetailInfo.day_of_month;