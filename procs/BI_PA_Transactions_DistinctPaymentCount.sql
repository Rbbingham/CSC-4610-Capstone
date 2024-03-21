/******************************************************************************
	
	CREATOR: Carlos Escudero & Harrison Peloquin

	CREATED: 3/17/24

	PURPOSE: Checks that the threshold of expected Distinct PaymentAccountIDs are met daily

******************************************************************************/

Use [CapstoneDB]
GO

CREATE OR ALTER PROCEDURE [dbo].[BI_Health_BI_PA_Transactions_DistinctPaymentCount] --name of procedure
AS 
BEGIN
	SET NOCOUNT ON;

	DECLARE @temp_BI_PA_Transactions AS [dbo].[TnTech_TableType];

	-- Create temp table for DayofMonthAvg
	CREATE TABLE #DayOfMonthAvgs (
	day_of_month NVARCHAR(20),
	payAcctIDCountAvgMonth INT
	);

	INSERT INTO #DayOfMonthAvgs
	SELECT 
		day_of_month, 
		AVG(payAcctIDCount) as payAcctIDCountAvgMonth
	FROM 
	(
		SELECT 
			CAST(CreatedOn as DATE) as Createdon,
			COUNT(distinct paymentAccountId) as payAcctIDCount,
			CASE
				WHEN DATEPART(day, Createdon) = 1 THEN 'First'
				WHEN DATEPART(day, Createdon) = 24 THEN 'TwentyFourth'
				WHEN DATEPART(day, Createdon) = 9 AND DATEPART(MONTH, Createdon) % 2 != 0 THEN 'Ninth-1'
				WHEN DATEPART(day, Createdon) = 9 AND DATEPART(MONTH, Createdon) % 2 = 0 THEN 'Ninth-2'
				WHEN DATEPART(day, Createdon) = 10 AND DATEPART(MONTH, Createdon) % 2 != 0 THEN 'Tenth-1'
				WHEN DATEPART(day, Createdon) = 10 AND DATEPART(MONTH, Createdon) % 2 = 0 THEN 'Tenth-2'
				ELSE 'Normal'
			END as day_of_month
		FROM BI_Feed.dbo.BI_PA_Transactions with (nolock)
		WHERE Createdon >= DATEADD(day, -62, GETDATE())
		GROUP BY CAST(Createdon as date), DATEPART(day, Createdon), DATEPART(MONTH, Createdon)
	
	) AS subquery
	GROUP BY day_of_month;

	-- Create temp table for WeeklyAverages
	CREATE TABLE #WeeklyAverages (
	timespan NVARCHAR(20),
	payAcctIDCountAvgWeek INT
	);

	INSERT INTO #WeeklyAverages
	SELECT 
		timespan, 
		AVG(payAcctIDCount) as payAcctIDCountAvgWeek
	FROM 
	(
		SELECT 
			CAST(Createdon as date) as Createdon,
			COUNT(distinct paymentAccountId) as payAcctIDCount,
			DATEPART(WEEKDAY, Createdon) AS day_of_week,
			CASE
				WHEN DATEPART(WEEKDAY, Createdon) = 1 THEN 'Sun'
				WHEN DATEPART(WEEKDAY, Createdon) = 2 THEN 'Mon'
				WHEN DATEPART(WEEKDAY, Createdon) IN (3,4,5) THEN 'Tues-Thu'
				WHEN DATEPART(WEEKDAY, Createdon) = 6 THEN 'Fri'
				WHEN DATEPART(WEEKDAY, Createdon) = 7 THEN 'Sat'
				ELSE 'NULL'
			END as timespan
		FROM BI_Feed.dbo.BI_PA_Transactions with (nolock)
		WHERE Createdon >= DATEADD(day, -183, GETDATE())
		GROUP BY CAST(Createdon as date), DATEPART(WEEKDAY, Createdon)
	
	) AS subquery
	GROUP BY timespan;

	-- Create temp table for DetailInfo
	CREATE TABLE #DetailInfo (
	Createdon DATE,
	ActualResult INT,
	day_of_month NVARCHAR(20),
	timespan NVARCHAR(20)
	);

	INSERT INTO #DetailInfo
	SELECT 
		CAST(Createdon as date) as Createdon,
		COUNT(distinct paymentAccountId) as ActualResult,
		CASE
			WHEN DATEPART(day, Createdon) = 1 THEN 'First'
			WHEN DATEPART(day, Createdon) = 24 THEN 'TwentyFourth'
			WHEN DATEPART(day, Createdon) = 9 AND DATEPART(MONTH, Createdon) % 2 != 0 THEN 'Ninth-1'
			WHEN DATEPART(day, Createdon) = 9 AND DATEPART(MONTH, Createdon) % 2 = 0 THEN 'Ninth-2'
			WHEN DATEPART(day, Createdon) = 10 AND DATEPART(MONTH, Createdon) % 2 != 0 THEN 'Tenth-1'
			WHEN DATEPART(day, Createdon) = 10 AND DATEPART(MONTH, Createdon) % 2 = 0 THEN 'Tenth-2'
			ELSE 'Normal'
		END as day_of_month,
		CASE
			WHEN DATEPART(WEEKDAY, Createdon) = 1 THEN 'Sun'
			WHEN DATEPART(WEEKDAY, Createdon) = 2 THEN 'Mon'
			WHEN DATEPART(WEEKDAY, Createdon) IN (3,4,5) THEN 'Tues-Thu'
			WHEN DATEPART(WEEKDAY, Createdon) = 6 THEN 'Fri'
			WHEN DATEPART(WEEKDAY, Createdon) = 7 THEN 'Sat'
			ELSE 'NULL'
		END as timespan
	FROM BI_Feed.dbo.BI_PA_Transactions with (nolock)
	WHERE Createdon >= DATEADD(day, -183, GETDATE())
	GROUP BY CAST(Createdon as date), DATEPART(day, Createdon), DATEPART(WEEKDAY, Createdon), DATEPART(MONTH, CreatedOn)
	ORDER BY CAST(Createdon as date) DESC;
	 
	 -- Create temp table for ExpectedCalculator
	 CREATE TABLE #ExpectedCalculator (
	CreatedOn DATE,
	ExpectedResult INT
	);

	INSERT INTO #ExpectedCalculator
	SELECT
		Createdon,
		CASE
			WHEN #DayOfMonthAvgs.day_of_month IN ('First', 'Ninth-1', 'Ninth-2', 'Tenth-1', 'Tenth-2', 'TwentyFourth') THEN payAcctIDCountAvgWeek * 0.01 + payAcctIDCountAvgMonth * 0.99
			ELSE payAcctIDCountAvgWeek * 0.99 + payAcctIDCountAvgMonth * 0.01
		END as ExpectedResult
	FROM #DetailInfo
	FULL OUTER JOIN #WeeklyAverages on #WeeklyAverages.timespan = #DetailInfo.timespan
	FULL OUTER JOIN #DayOfMonthAvgs on #DayOfMonthAvgs.day_of_month = #DetailInfo.day_of_month
	WHERE Createdon >= DATEADD(day, -183, GETDATE())
	GROUP BY Createdon, #DayOfMonthAvgs.day_of_month, #WeeklyAverages.timespan, payAcctIDCountAvgMonth, payAcctIDCountAvgWeek;

	-- run normal query into temp table
	INSERT INTO 
		@temp_BI_PA_Transactions( --temp table name
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
		'Distinct Payment Account' AS TestName,
		ActualResult,
		ExpectedResult,
		ABS(ExpectedResult - ActualResult) as Deviation,
		CAST(GETDATE() AS DATE) AS CreatedOn,
		'[CapstoneDB].[dbo].[BI_Health_BI_PA_Transactions_DistinctPaymentCount]' AS CreatedBy,
		NULL AS ModifiedOn,
		NULL AS ModifiedBy
	FROM #DetailInfo
	FULL OUTER JOIN #DayOfMonthAvgs ON #DetailInfo.day_of_month = #DayOfMonthAvgs.day_of_month
	FULL OUTER JOIN #WeeklyAverages ON #DetailInfo.timespan = #WeeklyAverages.timespan
	FULL OUTER JOIN #ExpectedCalculator ON #ExpectedCalculator.Createdon = #DetailInfo.Createdon
	WHERE #DetailInfo.Createdon >= DATEADD(day, -1, CAST(GETDATE() AS DATE))
	GROUP BY #DetailInfo.Createdon, ExpectedResult, ActualResult
	ORDER BY Createdon DESC;

	--Upload data into CapstoneDB.dbo.BI_HealthResults
	EXEC [dbo].[BI_InsertTestResult] @Table = @temp_BI_PA_Transactions;
	
	-- DROP temp tables
	DROP TABLE #DayOfMonthAvgs;
	DROP TABLE #WeeklyAverages
	DROP TABLE #ExpectedCalculator
	DROP TABLE #DetailInfo;

	SET NOCOUNT OFF;
END