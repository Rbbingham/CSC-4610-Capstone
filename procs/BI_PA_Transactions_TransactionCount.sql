/******************************************************************************
	
	CREATOR:Carlos Escudero & Harrison Peloquin

	CREATED: 3/17/24

	PURPOSE: Checks that the threshold of expected Transaction Counts are met daily

******************************************************************************/

Use [CapstoneDB]
GO

CREATE OR ALTER PROCEDURE [dbo].[BI_Health_BI_PA_Transactions_TransactionCount] --name of procedure
AS 
BEGIN
	SET NOCOUNT ON;

	--Create Temp Table 
	DECLARE @temp_BI_PA_Transactions AS [dbo].[TnTech_TableType];

	--Temp table for query use later
	CREATE TABLE #DayOfMonthAvgs (
	day_of_month NVARCHAR(20),
	transCountAvgMonth INT
	);

	INSERT INTO #DayOfMonthAvgs
	SELECT 
		day_of_month, 
		AVG(TransactionCount) as transCountAvg
	FROM 
	(
		SELECT 
			CAST(transactionDate as date) as transactionDate,
			COUNT(transactionReferenceId) as transactionCount,
			CASE
				WHEN DATEPART(day, transactionDate) = 1 THEN 'First'
				WHEN DATEPART(day, transactionDate) = 9 THEN 'Ninth'
				ELSE 'Normal'
			END as day_of_month
		FROM BI_Feed.dbo.BI_PA_Transactions with (nolock)
		WHERE TransactionDate >= DATEADD(day, -62, GETDATE())
		GROUP BY CAST(transactionDate as date), DATEPART(day, transactionDate)
		--ORDER BY CAST(transactionDate as date)
	) AS subquery
	GROUP BY day_of_month;

	--WeeklyAverages Temp table
	CREATE TABLE #WeeklyAverages (
	timespan NVARCHAR(20),
	transCountAvgWeek INT
	);

	INSERT INTO #WeeklyAverages
	SELECT 
		timespan, 
		AVG(TransactionCount) as transCountAvgWeek
	FROM 
	(
		SELECT 
			CAST(transactionDate as date) as transactionDate,
			COUNT(transactionReferenceId) as transactionCount,
			DATEPART(WEEKDAY, transactionDate) AS day_of_week,
			CASE
				WHEN DATEPART(WEEKDAY, transactionDate) IN (1,7) THEN 'Sat-Sun'
				WHEN DATEPART(WEEKDAY, transactionDate) IN (2,6) THEN 'Mon,Fri'
				WHEN DATEPART(WEEKDAY, transactionDate) IN (3,4,5) THEN 'Tues-Thu'
				ELSE 'NULL'
			END as timespan
		FROM BI_Feed.dbo.BI_PA_Transactions with (nolock)
		WHERE TransactionDate >= DATEADD(day, -183, GETDATE())
		GROUP BY CAST(transactionDate as date), DATEPART(WEEKDAY, transactionDate)
		--ORDER BY CAST(transactionDate as date) DESC
	) AS subquery
	GROUP BY timespan;

	--DetailInfo Temp Table
	CREATE TABLE #DetailInfo (
	transactionDate DATE,
	ActualResult INT,
	day_of_month NVARCHAR(20),
	timespan NVARCHAR(20)
	);

	INSERT INTO #DetailInfo
	SELECT 
		CAST(transactionDate as date) as transactionDate,
		COUNT(transactionReferenceId) as ActualResult,
		CASE
			WHEN DATEPART(day, transactionDate) = 1 THEN 'First'
			WHEN DATEPART(day, transactionDate) = 9 THEN 'Ninth'
			ELSE 'Normal'
		END as day_of_month,
		CASE
			WHEN DATEPART(WEEKDAY, transactionDate) IN (1,7) THEN 'Sat-Sun'
			WHEN DATEPART(WEEKDAY, transactionDate) IN (2,6) THEN 'Mon,Fri'
			WHEN DATEPART(WEEKDAY, transactionDate) IN (3,4,5) THEN 'Tues-Thu'
			ELSE 'NULL'
		END as timespan
	FROM BI_Feed.dbo.BI_PA_Transactions with (nolock)
	WHERE TransactionDate >= DATEADD(day, -183, GETDATE())
	GROUP BY CAST(transactionDate as date), DATEPART(day, transactionDate), DATEPART(WEEKDAY, transactionDate)
	ORDER BY CAST(transactionDate as date) DESC;

	--ExpectedCalculator Temp Table
	CREATE TABLE #ExpectedCalculator (
	transactionDate DATE,
	ExpectedResult INT
	);

	INSERT INTO #ExpectedCalculator
	SELECT
		transactionDate,
	CASE
		WHEN #DayOfMonthAvgs.day_of_month IN ('First', 'Ninth') THEN transCountAvgWeek * 0.01 + transCountAvgMonth * 0.99
		ELSE transCountAvgWeek * 0.99 + transCountAvgMonth * 0.01
	END as ExpectedResult
	FROM #DetailInfo
	FULL OUTER JOIN #WeeklyAverages on #WeeklyAverages.timespan = #DetailInfo.timespan
	FULL OUTER JOIN #DayOfMonthAvgs on #DayOfMonthAvgs.day_of_month = #DetailInfo.day_of_month
	WHERE transactionDate >= DATEADD(day, -183, GETDATE())
	GROUP BY transactionDate, #DayOfMonthAvgs.day_of_month, #WeeklyAverages.timespan, transCountAvgMonth, transCountAvgWeek;

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
		'Transaction Count' AS TestName,
		ActualResult,
		ExpectedResult,
		ABS(ExpectedResult - ActualResult) Deviation,
		CAST(GETDATE() AS DATE) AS CreatedOn,
		'[CapstoneDB].[dbo].[BI_Health_BI_PA_Transactions_TransactionCount]' AS CreatedBy,
		NULL AS ModifiedOn,
		NULL AS ModifiedBy
	FROM 
		#DetailInfo
	FULL OUTER JOIN #DayOfMonthAvgs ON #DetailInfo.day_of_month = #DayOfMonthAvgs.day_of_month
	FULL OUTER JOIN #WeeklyAverages ON #DetailInfo.timespan = #WeeklyAverages.timespan
	FULL OUTER JOIN #ExpectedCalculator ON #ExpectedCalculator.transactionDate = #DetailInfo.transactionDate
	WHERE #DetailInfo.transactionDate = DATEADD(day, -1, CAST(GETDATE() AS DATE))
	GROUP BY #DetailInfo.transactionDate, ExpectedResult, ActualResult
	ORDER BY #DetailInfo.transactionDate DESC; -- choose table from BI_feed

	--Upload data into CapstoneDB.dbo.BI_HealthResults
	EXEC [dbo].[BI_InsertTestResult] @Table = @temp_BI_PA_Transactions;

	--Drop Temporary Tables
	DROP TABLE #WeeklyAverages;
	DROP TABLE #DayOfMonthAvgs;
	DROP TABLE #DetailInfo;
	DROP TABLE #ExpectedCalculator;

	SET NOCOUNT OFF;
END;
GO