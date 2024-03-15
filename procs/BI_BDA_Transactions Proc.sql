USE [CapstoneDB]
GO

/******************************************************************************
	
	CREATOR:	Harrison Peloquin, Carlos Escudero

	CREATED:	2024/03/15

	PURPOSE:	Transaction count matches expected amount and checks if
	yesterday's records exist.

******************************************************************************/

CREATE OR ALTER PROCEDURE [dbo].[BI_Health_BI_BDA_Transactions]
AS 
BEGIN
	SET NOCOUNT ON;

	-- create temp table 
	DECLARE @temp_BI_BDA_Transactions AS [dbo].[TnTech_TableType];

	CREATE TABLE #WeeklyAverages (
			day_of_week NVARCHAR(20),
			weeklyIDCountAvg DECIMAL(18,2)
		);

		INSERT INTO #WeeklyAverages
		SELECT day_of_week, AVG(tranIDCount) as weeklyIDCountAvg
		FROM
		(
			SELECT
				CAST(createdOn AS DATE) AS createdOn,
				CASE
					WHEN DATEPART(WEEKDAY, createdOn) IN (1,2) THEN 'Sun-Mon'
					WHEN DATEPART(WEEKDAY, createdOn) IN (3,4) THEN 'Tues-Wed'
					WHEN DATEPART(WEEKDAY, createdOn) = 5 THEN 'Thur'
					WHEN DATEPART(WEEKDAY, createdOn) = 6 THEN 'Fri'
					WHEN DATEPART(WEEKDAY, createdOn) = 7 THEN 'Sat'
					ELSE 'NULL'
				END as day_of_week,
				COUNT(tranID) as tranIDCount
			FROM BI_Feed.dbo.BI_BDA_Transactions WITH (nolock)
			WHERE createdOn >= DATEADD(day, -183, GETDATE())
			GROUP BY CAST(createdOn AS DATE), DATEPART(WEEKDAY, createdOn)
		) AS subquery
		GROUP BY day_of_week;

		-- Create a temporary table for day of month averages
		CREATE TABLE #DayOfMonthAverages (
			day_of_month NVARCHAR(20),
			dayofMonthIDCountAvg DECIMAL(18,2)
		);

		INSERT INTO #DayOfMonthAverages
		SELECT day_of_month, AVG(tranIDCount) as dayofMonthIDCountAvg
		FROM
		(
			SELECT
				CAST(createdOn AS DATE) AS createdOn,
				CASE
					WHEN DATEPART(day, CAST(createdOn as DATE)) = 2 THEN 'Sec'
					WHEN DATEPART(day, CAST(createdOn as DATE)) = 9 THEN 'Nin'
					ELSE 'NULL'
				END as day_of_month,
				COUNT(tranID) as tranIDCount
			FROM BI_Feed.dbo.BI_BDA_Transactions WITH (nolock)
			WHERE createdOn >= DATEADD(day, -62, GETDATE())
			GROUP BY CAST(createdOn AS DATE)
		) AS subquery
		GROUP BY day_of_month;

		-- Create a temporary table for detailed information
		CREATE TABLE #DetailInfo (
			transactionDate DATE,
			day_of_week NVARCHAR(20),
			day_of_month NVARCHAR(20),
			ActualResult INT
		);

		INSERT INTO #DetailInfo
		SELECT
			CAST(createdOn as DATE) as transactionDate, 
			CASE
				WHEN DATEPART(WEEKDAY, createdOn) IN (1,2) THEN 'Sun-Mon'
				WHEN DATEPART(WEEKDAY, createdOn) IN (3,4) THEN 'Tues-Wed'
				WHEN DATEPART(WEEKDAY, createdOn) = 5 THEN 'Thur'
				WHEN DATEPART(WEEKDAY, createdOn) = 6 THEN 'Fri'
				WHEN DATEPART(WEEKDAY, createdOn) = 7 THEN 'Sat'
				ELSE 'NULL'
			END as day_of_week,
			CASE
				WHEN DATEPART(day, CAST(createdOn as DATE)) = 2 THEN 'Sec'
				WHEN DATEPART(day, CAST(createdOn as DATE)) = 9 THEN 'Nin'
				ELSE 'NULL'
			END as day_of_month,
			COUNT(tranID) as ActualResult
		FROM BI_Feed.dbo.BI_BDA_Transactions WITH (nolock)
		WHERE createdOn >= DATEADD(day, -183, GETDATE())
		GROUP BY CAST(createdOn as DATE), DATEPART(WEEKDAY, createdOn);

		-- Create a temporary table for expected results
		CREATE TABLE #ExpectedCalculator (
			transactionDate DATE,
			ExpectedResult INT
		);

		INSERT INTO #ExpectedCalculator
		SELECT
			transactionDate,
			CASE
				WHEN #DayOfMonthAverages.day_of_month IN ('Sec', 'Nin') THEN CAST((dayofMonthIDCountAvg * 0.99 + weeklyIDCountAvg * 0.01) AS INT)
				ELSE CAST(weeklyIDCountAvg AS INT)
			END as ExpectedResult
		FROM #DetailInfo
		FULL OUTER JOIN #WeeklyAverages on #WeeklyAverages.day_of_week = #DetailInfo.day_of_week
		FULL OUTER JOIN #DayOfMonthAverages on #DayOfMonthAverages.day_of_month = #DetailInfo.day_of_month
		WHERE transactionDate >= DATEADD(day, -183, GETDATE())
		GROUP BY transactionDate, #DayOfMonthAverages.day_of_month, dayofMonthIDCountAvg, weeklyIDCountAvg;
	
	-- run normal query into temp table
	INSERT INTO 
		@temp_BI_BDA_Transactions(
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

		-- Select query with deviations
		SELECT
			'BI_BDA_Transactions' AS TableName,
			CAST(GETDATE() AS DATE) AS TestRunDate,
			'Transaction Count' AS TestName,
			ActualResult,
			ExpectedResult,
			ABS(ExpectedResult - ActualResult) as Deviation,
			CAST(GETDATE() AS DATE) AS CreatedOn,
			'[CapstoneDB].[dbo].[BI_Health_BI_BDA_Transactions]' AS CreatedBy,
			NULL AS ModifiedOn,
			NULL AS ModifiedBy
		FROM #DetailInfo
		FULL OUTER JOIN #WeeklyAverages on #WeeklyAverages.day_of_week = #DetailInfo.day_of_week
		FULL OUTER JOIN #DayOfMonthAverages on #DayOfMonthAverages.day_of_month = #DetailInfo.day_of_month
		FULL OUTER JOIN #ExpectedCalculator ON #ExpectedCalculator.transactionDate = #DetailInfo.transactionDate
		WHERE #DetailInfo.transactionDate >= DATEADD(day, -183, GETDATE())
		GROUP BY #DetailInfo.transactionDate, ExpectedResult, ActualResult
		ORDER BY #DetailInfo.transactionDate DESC;

	-- upload data into CapstoneDB.dbo.BI_HealthResults
	EXEC [dbo].[BI_InsertTestResult] @Table = @temp_BI_BDA_Transactions;

	-- Drop temporary tables
	DROP TABLE #WeeklyAverages;
	DROP TABLE #DayOfMonthAverages;
	DROP TABLE #DetailInfo;
	DROP TABLE #ExpectedCalculator;

	
	SET NOCOUNT OFF;
END;
GO