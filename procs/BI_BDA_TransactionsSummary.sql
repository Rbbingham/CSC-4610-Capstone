USE [CapstoneDB]
GO

/******************************************************************************
	
	CREATOR: Collin Cunningham, Carlos Escudero, Harrison Peloquin

	CREATED: 3/22/24

	PURPOSE: Counts the number of records in the table

******************************************************************************/

CREATE OR ALTER PROCEDURE [dbo].[BI_Health_BI_BDA_TransactionsSummary] --name of procedure
AS 
BEGIN
	SET NOCOUNT ON;

	--Temp Table Creation 
	DECLARE @temp_BI_BDA_TransactionsSummary as [dbo].[TnTech_TableType];

	CREATE TABLE #WeeklyAverages (
	day_of_week NVARCHAR(20),
	weekIDCountAvg INT,
	);

	INSERT INTO #WeeklyAverages
	SELECT 
		day_of_week,
		AVG(IDCount) as weekIDCountAvg
	FROM (
		SELECT
			CAST(CreatedOn as DATE) as CreatedOn,
			COUNT(ID) as IDCount,
			CASE
				WHEN DATEPART(WEEKDAY, createdOn) IN (1,2) THEN 'Sun-Mon'
				WHEN DATEPART(WEEKDAY, createdOn) IN (3,4,5,6) THEN 'Tues-Fri'
				WHEN DATEPART(WEEKDAY, createdOn) = 7 THEN 'Sat'
				ELSE 'NULL'
			END as day_of_week
		FROM [BI_Feed].[dbo].[BI_BDA_TransactionsSummary] with (nolock)
		WHERE CAST(CreatedOn as DATE) >= DATEADD(day, -183, CAST(GETDATE() AS DATE))
		GROUP BY CAST(CreatedOn as DATE), DATEPART(WEEKDAY, createdOn)
	) as subquery
	GROUP BY day_of_week;

	CREATE TABLE #DayOfMonthAverages (
		day_of_month NVARCHAR(20),
		dayofMonthIDCountAvg DECIMAL(18,2)
	);

	INSERT INTO #DayOfMonthAverages
	SELECT day_of_month, AVG(IDCount) as dayofMonthIDCountAvg
	FROM
	(
		SELECT
			CAST(createdOn AS DATE) AS createdOn,
			CASE
				WHEN DATEPART(day, CAST(createdOn as DATE)) = 2 THEN 'Sec'
				ELSE 'NULL'
			END as day_of_month,
			COUNT(ID) as IDCount
		FROM BI_Feed.dbo.BI_BDA_TransactionsSummary WITH (nolock)
		WHERE createdOn >= DATEADD(day, -62, GETDATE())
		GROUP BY CAST(createdOn AS DATE)
	) AS subquery
	GROUP BY day_of_month;

	CREATE TABLE #DetailInfo (
		CreatedOn DATE,
		IDCount INT,
		day_of_week NVARCHAR(20),
		day_of_month NVARCHAR(20)
	);

	INSERT INTO #DetailInfo
	SELECT
		CAST(CreatedOn as DATE) as CreatedOn,
		COUNT(ID) as IDCount,
		CASE
			WHEN DATEPART(WEEKDAY, createdOn) IN (1,2) THEN 'Sun-Mon'
			WHEN DATEPART(WEEKDAY, createdOn) IN (3,4,5,6) THEN 'Tues-Fri'
			WHEN DATEPART(WEEKDAY, createdOn) = 7 THEN 'Sat'
			ELSE 'NULL'
		END as day_of_week,
		CASE
			WHEN DATEPART(day, CAST(createdOn as DATE)) = 2 THEN 'Sec'
			ELSE 'NULL'
		END as day_of_month
	FROM [BI_Feed].[dbo].[BI_BDA_TransactionsSummary] with (nolock)
	WHERE CAST(CreatedOn as DATE) >= DATEADD(day, -183, CAST(GETDATE() AS DATE))
	GROUP BY CAST(CreatedOn as DATE), DATEPART(WEEKDAY, createdOn), DATEPART(day, CAST(createdOn as DATE))
	ORDER BY CAST(CreatedOn as DATE) DESC;

	CREATE TABLE #ExpectedCalculator (
		CreatedOn DATE,
		ExpectedResult INT
	);

	INSERT INTO #ExpectedCalculator
	SELECT
		CreatedOn,
		CASE
			WHEN #DayOfMonthAverages.day_of_month IN ('Sec') THEN CAST((dayofMonthIDCountAvg * 0.99 + weekIDCountAvg * 0.01) AS INT)
			ELSE CAST(weekIDCountAvg AS INT)
		END as ExpectedResult
	FROM #DetailInfo
	FULL OUTER JOIN #WeeklyAverages on #WeeklyAverages.day_of_week = #DetailInfo.day_of_week
	FULL OUTER JOIN #DayOfMonthAverages on #DayOfMonthAverages.day_of_month = #DetailInfo.day_of_month
	WHERE CreatedOn >= DATEADD(day, -183, GETDATE())
	GROUP BY CreatedOn, #DayOfMonthAverages.day_of_month, dayofMonthIDCountAvg, weekIDCountAvg;

	-- run normal query into temp table
	INSERT INTO 
		@temp_BI_BDA_TransactionsSummary( --temp table name
			TableName,
			TestRunDate, 
			TestName,
			ActualResult,
			ExpectedResult,
			Deviation,
			RiskScore,
			CreatedOn,
			CreatedBy,
			ModifiedOn,
			ModifiedBy)
	SELECT
		'BI_BDA_TransactionsSummary' as TableName,
		CAST(GETDATE() AS DATE) as TestRunDate,
		'Record Count' AS TestName,
		IDCount as ActualResult,
		ExpectedResult,
		ABS(IDCount - ExpectedResult) as Deviation,
		NULL AS RiskScore,
		CAST(GETDATE() AS DATETIME) AS CreatedOn,
		'[CapstoneDB].[dbo].[BI_Health_BI_BDA_TransactionsSummary]' AS CreatedBy,
		NULL AS ModifiedOn,
		NULL AS ModifiedBy
	FROM #DetailInfo
	FULL OUTER JOIN #WeeklyAverages ON #DetailInfo.day_of_week = #WeeklyAverages.day_of_week
	FULL OUTER JOIN #DayOfMonthAverages ON #DetailInfo.day_of_month = #DayOfMonthAverages.day_of_month
	FULL OUTER JOIN #ExpectedCalculator ON #DetailInfo.CreatedOn = #ExpectedCalculator.CreatedOn
	WHERE CAST(#DetailInfo.CreatedOn as DATE) = DATEADD(day, -1, CAST(GETDATE() AS DATE))
	GROUP BY CAST(#DetailInfo.CreatedOn as DATE), IDCount, ExpectedResult, weekIDCountAvg
	ORDER BY CAST(#DetailInfo.CreatedOn as DATE) DESC; -- choose table from BI_feed

	--Upload data into CapstoneDB.dbo.BI_HealthResults
	EXEC [dbo].[BI_InsertTestResult]@Table = @temp_BI_BDA_TransactionsSummary  --put temp table here

	DROP TABLE #WeeklyAverages;
	DROP TABLE #DayOfMonthAverages;
	DROP TABLE #DetailInfo;
	DROP TABLE #ExpectedCalculator;

	SET NOCOUNT OFF;
END