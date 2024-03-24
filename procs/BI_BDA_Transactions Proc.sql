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

	-- Create temp table 
	DECLARE @temp_BI_BDA_Transactions AS [dbo].[TnTech_TableType];

	-- Create a temp table for weekly averages
	CREATE TABLE #WeeklyAverages (
		day_of_week NVARCHAR(20),
		weeklyIDCountAvg DECIMAL(18,2)
	);

	-- Query calculates averages of each day (or group of days) of the week
	INSERT INTO #WeeklyAverages
	SELECT day_of_week, AVG(tranIDCount) as weeklyIDCountAvg
	FROM
	(
		-- Subquery to calculate transaction counts by day of week
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

	-- Create a temp table for day of month averages
	CREATE TABLE #DayOfMonthAverages (
		day_of_month NVARCHAR(20),
		dayofMonthIDCountAvg DECIMAL(18,2)
	);

	-- Query calculates averages of 3 days of the month that behave uniquely (the 2nd, 9th, & 23rd)
	INSERT INTO #DayOfMonthAverages
	SELECT day_of_month, AVG(tranIDCount) as dayofMonthIDCountAvg
	FROM
	(
		-- Subquery to calculate transactions counts by day of month (only concerned with the 2nd, 9th, 23rd)
		SELECT
			CAST(createdOn AS DATE) AS createdOn,
			CASE
				WHEN DATEPART(day, CAST(createdOn as DATE)) = 2 THEN 'Sec'
				WHEN DATEPART(day, CAST(createdOn as DATE)) = 9 THEN 'Nin'
				WHEN DATEPART(day, CAST(createdOn as DATE)) = 23 THEN 'TwentyThree'
				ELSE 'NULL'
			END as day_of_month,
			COUNT(tranID) as tranIDCount
		FROM BI_Feed.dbo.BI_BDA_Transactions WITH (nolock)
		WHERE createdOn >= DATEADD(day, -62, GETDATE())
		GROUP BY CAST(createdOn AS DATE)
	) AS subquery
	GROUP BY day_of_month;

	-- Create a temporary table for actual result that will be used to connect previously tables together
	CREATE TABLE #DetailInfo (
		transactionDate DATE,
		day_of_week NVARCHAR(20),
		day_of_month NVARCHAR(20),
		ActualResult INT
	);

	-- Query calculates actual result (count of tranID) as it is not accessible from the previous temp tables
	-- It also finds the day of week and day of month, which are used to join the previous temp tables with this one,
	-- allowing access to the previously calculated monthly and weekly averages.
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
			WHEN DATEPART(day, CAST(createdOn as DATE)) = 23 THEN 'TwentyThree'
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

	-- Query calculates an expected result based on both the day of the week and the day of the month
	INSERT INTO #ExpectedCalculator
	SELECT
		transactionDate,
		CASE
			-- If the day is a 2nd, 9th, or 23rd of the month, 99% of the ExpectedResult will be calculated from the average of the day of month
			-- Then, 1% of the ExpectedResult will be calculated on the average of what day of the week it was
			WHEN #DayOfMonthAverages.day_of_month IN ('Sec', 'Nin', 'TwentyThree') THEN CAST((dayofMonthIDCountAvg * 0.99 + weeklyIDCountAvg * 0.01) AS INT)
			--If it is not the 2nd, 9th, or 23rd of the month, the ExpectedResult is calculated soley on the average of what day of week it was
			ELSE CAST(weeklyIDCountAvg AS INT)
		END as ExpectedResult
	FROM #DetailInfo
	FULL OUTER JOIN #WeeklyAverages on #WeeklyAverages.day_of_week = #DetailInfo.day_of_week
	FULL OUTER JOIN #DayOfMonthAverages on #DayOfMonthAverages.day_of_month = #DetailInfo.day_of_month
	WHERE transactionDate >= DATEADD(day, -183, GETDATE())
	GROUP BY transactionDate, #DayOfMonthAverages.day_of_month, dayofMonthIDCountAvg, weeklyIDCountAvg;
	
	-- Run normal query into temp table
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

		-- Query selects necessary information to be put in table
		SELECT
			'BI_BDA_Transactions' AS TableName,
			CAST(GETDATE() AS DATE) AS TestRunDate,
			'Transaction Count' AS TestName,
			ActualResult,
			ExpectedResult,
			ABS(ExpectedResult - ActualResult) as Deviation,
			NULL as RiskScore,
			GETDATE() AS CreatedOn,
			'[CapstoneDB].[dbo].[BI_Health_BI_BDA_Transactions]' AS CreatedBy,
			NULL AS ModifiedOn,
			NULL AS ModifiedBy
		FROM #DetailInfo
		FULL OUTER JOIN #WeeklyAverages on #WeeklyAverages.day_of_week = #DetailInfo.day_of_week
		FULL OUTER JOIN #DayOfMonthAverages on #DayOfMonthAverages.day_of_month = #DetailInfo.day_of_month
		FULL OUTER JOIN #ExpectedCalculator ON #ExpectedCalculator.transactionDate = #DetailInfo.transactionDate
		WHERE #DetailInfo.transactionDate = DATEADD(day, -1, CAST(GETDATE() AS DATE))
		GROUP BY #DetailInfo.transactionDate, ExpectedResult, ActualResult
		ORDER BY #DetailInfo.transactionDate DESC;

	-- Upload data into CapstoneDB.dbo.BI_HealthResults
	EXEC [dbo].[BI_InsertTestResult] @Table = @temp_BI_BDA_Transactions;

	-- Drop temporary tables
	DROP TABLE #WeeklyAverages;
	DROP TABLE #DayOfMonthAverages;
	DROP TABLE #DetailInfo;
	DROP TABLE #ExpectedCalculator;
	
	SET NOCOUNT OFF;
END;
GO