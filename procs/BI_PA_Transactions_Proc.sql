/******************************************************************************
	
	CREATOR: Carlos Escudero & Harrison Peloquin

	CREATED:

	PURPOSE:

******************************************************************************/

Use [CapstoneDB]
GO

CREATE OR ALTER PROCEDURE [dbo].[BI_Health_BI_PA_Transactions] --name of procedure
AS 
BEGIN
	SET NOCOUNT ON;

	IF OBJECT_ID('tempdb.dbo.#temp_BI_PA_Transactions') IS NOT NULL
	BEGIN
		DROP TABLE #temp_BI_PA_Transactions-- temp table 
	END;

	--Create temp table 
	CREATE TABLE #temp_BI_PA_Transactions(
		[TableName] varchar(256) NOT NULL,
		[TestRunDate] date NOT NULL,
		[TestName] varchar(256) NOT NULL,
		[ActualResult] bigint NOT NULL,
		[ExpectedResult] bigint NOT NULL,
		[Deviation] bigint NOT NULL,
		[CreatedOn] date NOT NULL,
		[CreatedBy] varchar(256) NOT NULL,
		[ModifiedOn] date NULL,
		[ModifiedBy] varchar(256) NULL
	);
------ CTE for COUNT(transactionReferenceId) as TransactionCount------
	WITH WeeklyAverages as (
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
),
DetailInfo as (
	SELECT 
		CAST(transactionDate as date) as TransactionDate,
		COUNT(transactionReferenceId) as ActualResult,
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
)

	-- run normal query into temp table
	INSERT INTO 
		#temp_BI_PA_Transactions( --temp table name
			TableName,
			TestRunDate, 
			TestName,
			ActualResult,
			ExpectedResult,
			Deviation,
			CreatedOn,
			CreatedBy,
			ModifiedOn,
			ModifiedBy)
	SELECT
		'BI_PA_Transactions' AS TableName,
		 CAST(GETDATE() AS DATE) AS TestRunDate,
		'Transactions Count' AS TestName,
		ActualResult,
		AverageResult AS ExpectedResult,
		CASE
			WHEN ActualResult <= AverageResult THEN AverageResult - ActualResult
            WHEN ActualResult > AverageResult THEN ActualResult - AverageResult
        END as Deviation,
		CAST(GETDATE() AS DATE) AS CreatedOn,
		'[CapstoneDB].[dbo].[BI_Health_BI_PA_Transactions]' AS CreatedBy,
		NULL AS ModifiedOn,
		NULL AS ModifiedBy
	FROM 
		WeeklyAverages
		FULL OUTER JOIN DetailInfo ON WeeklyAverages.timespan = DetailInfo.timespan
		GROUP BY TransactionDate, DetailInfo.timespan, day_of_week, AverageResult, ActualResult
		ORDER BY TransactionDate DESC; -- choose table from BI_feed
---------------------------------------------------------------------------------------------
----- CTE for COUNT(distinct paymentAccountId) as PaymentAccountId----------------------

WITH WeeklyAverages2 as (
	SELECT 
		timespan, 
		AVG(PaymentAccountId) as AverageResult
	FROM (
		SELECT 
			CAST(transactionDate as date) as TransactionDate,
			COUNT(distinct paymentAccountId) as PaymentAccountId,
			DATEPART(Weekday, transactionDate) AS day_of_week,
			CASE
				WHEN DATEPART(DAY, CAST(transactionDate as DATE)) = 1 THEN 'FirstofMonth'
				WHEN DATEPART(WEEKDAY, transactionDate) in (1) THEN 'Sun'
				WHEN DATEPART(WEEKDAY, transactionDate) IN (2) THEN 'Mon'
				WHEN DATEPART(WEEKDAY, transactionDate) IN (3) THEN 'T'
				WHEN DATEPART(WEEKDAY, transactionDate) IN (4) THEN 'W'
				WHEN DATEPART(WEEKDAY, transactionDate) IN (5) THEN 'TH'
				WHEN DATEPART(WEEKDAY, transactionDate) IN (6) THEN 'Fr'
				WHEN DATEPART(WEEKDAY, transactionDate) IN (7) THEN 'Sat'
				ELSE 'NULL'
			END as timespan
		FROM BI_Feed.dbo.BI_PA_Transactions with (nolock)
		WHERE TransactionDate >= DATEADD(day, -150, GETDATE())
		GROUP BY DATEPART(Weekday, transactionDate), CAST(transactionDate as date)
		) AS subquery
		GROUP BY timespan
),
DetailInfo2 as (
	SELECT 
		CAST(transactionDate as date) as TransactionDate,
		COUNT(distinct paymentAccountId) as ActualResult,
		DATEPART(Weekday, transactionDate) AS day_of_week,
		CASE
			WHEN DATEPART(DAY, CAST(transactionDate as DATE)) = 1 THEN 'FirstofMonth'
			WHEN DATEPART(WEEKDAY, transactionDate) in (1) THEN 'Sun'
			WHEN DATEPART(WEEKDAY, transactionDate) IN (2) THEN 'Mon'
			WHEN DATEPART(WEEKDAY, transactionDate) IN (3) THEN 'T'
			WHEN DATEPART(WEEKDAY, transactionDate) IN (4) THEN 'W'
			WHEN DATEPART(WEEKDAY, transactionDate) IN (5) THEN 'TH'
			WHEN DATEPART(WEEKDAY, transactionDate) IN (6) THEN 'Fr'
			WHEN DATEPART(WEEKDAY, transactionDate) IN (7) THEN 'Sat'
			ELSE 'NULL'
		END as timespan
	FROM BI_Feed.dbo.BI_PA_Transactions with (nolock)
	WHERE TransactionDate >= DATEADD(day, -150, GETDATE())
	GROUP BY DATEPART(Weekday, transactionDate), CAST(transactionDate as date)
)

	INSERT INTO
		#temp_BI_PA_Transactions--temp table name
	SELECT
		 'BI_PA_Transactions' AS TableName,
		 CAST(GETDATE() AS DATE) AS TestRunDate,
		'Distinct PaymentAccountID Count' AS TestName,
		ActualResult,
		AverageResult AS ExpectedResult,
		CASE 
			 WHEN ActualResult <= AverageResult THEN AverageResult - ActualResult
            WHEN ActualResult > AverageResult THEN ActualResult - AverageResult
        END as Deviation,
		CAST(GETDATE() AS DATE) AS CreatedOn,
		'[CapstoneDB].[dbo].[BI_Health_BI_PA_Transactions]' AS CreatedBy,
		NULL AS ModifiedOn,
		NULL AS ModifiedBy
	FROM 
		WeeklyAverages2
		FULL OUTER JOIN DetailInfo2 ON WeeklyAverages2.timespan = DetailInfo2.timespan
		GROUP BY TransactionDate, DetailInfo2.timespan, day_of_week, AverageResult, ActualResult
		ORDER BY TransactionDate DESC; --choose table from BI_feed
------------------------------------------------------------------------------------------------------------
	--Upload data into CapstoneDB.dbo.BI_HealthResults
	INSERT INTO 
		CapstoneDB.dbo.BI_HealthResults(
			TableName,
			TestRunDate, 
			TestName,
			ActualResult,
			ExpectedResult,
			Deviation,
			CreatedOn,
			CreatedBy,
			ModifiedOn,
			ModifiedBy)
	SELECT
		TableName,
		TestRunDate, 
		TestName,
		ActualResult,
		ExpectedResult,
		Deviation,
		CreatedOn,
		CreatedBy,
		ModifiedOn,
		ModifiedBy
	FROM 
		#temp_BI_PA_Transactions;--temp table 

	DROP TABLE #temp_BI_PA_Transactions;

	SET NOCOUNT OFF;
END