/******************************************************************************
	
	CREATOR: Harrison Peloquin

	CREATED: February 24, 2024

	PURPOSE: For each day (using ConnectTimeStamp), calculate the count of calls
	(use count distinct CallID) and compare against and expected value. About 
	4k-8k calls a day

******************************************************************************/

Use [CapstoneDB]
GO

CREATE OR ALTER PROCEDURE [dbo].[BI_Health_BI_Call_Detail] -- name of the procedure
AS 
BEGIN
    SET NOCOUNT ON;

    IF OBJECT_ID('tempdb.dbo.temp_BI_Call_Detail') IS NOT NULL
    BEGIN
        DROP TABLE #temp_BI_Call_Detail; -- temp table
    END;

    -- Create temp table 
    CREATE TABLE #temp_BI_Call_Detail (
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

    -- CTE
    WITH WeeklyAverages AS (
        SELECT 
            timespan, 
            AVG(ActualResult) as AverageResult
        FROM (
            SELECT 
                CAST(connectTime AS DATE) AS connectTime,
                DATEPART(WEEKDAY, connectTime) AS day_of_week,
                CASE
                    WHEN DATEPART(WEEKDAY, connectTime) IN (1,7) THEN 'Sat-Sun'
                    WHEN DATEPART(WEEKDAY, connectTime) IN (2,3,4,5) THEN 'Mon-Thu'
                    WHEN DATEPART(WEEKDAY, connectTime) = 6 THEN 'Fri'
                    ELSE 'NULL'
                END as timespan,
                COUNT(distinct callID) AS ActualResult
            FROM BI_Feed.dbo.BI_Call_Detail WITH (nolock)
            WHERE connectTime >= DATEADD(day, -365, GETDATE())
            GROUP BY DATEPART(WEEKDAY, connectTime), CAST(connectTime AS DATE)
        ) AS subquery
        GROUP BY timespan
    ),
    DetailInfo AS (
        SELECT 
            CAST(connectTime AS DATE) AS connectTime,
            DATEPART(WEEKDAY, connectTime) AS day_of_week,
            COUNT(distinct callID) AS ActualResult,
            CASE
                WHEN DATEPART(WEEKDAY, connectTime) IN (1,7) THEN 'Sat-Sun'
                WHEN DATEPART(WEEKDAY, connectTime) IN (2,3,4,5) THEN 'Mon-Thu'
                WHEN DATEPART(WEEKDAY, connectTime) = 6 THEN 'Fri'
                ELSE 'NULL'
            END as timespan
        FROM BI_Feed.dbo.BI_Call_Detail WITH (nolock)
        GROUP BY DATEPART(WEEKDAY, connectTime), CAST(connectTime AS DATE)
    )

    -- Insert into temp table from the CTE and subsequent SELECT statement
    INSERT INTO #temp_BI_Call_Detail (
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
    )
    SELECT
        'BI_Call_Detail' AS TableName,
        CAST(GETDATE() AS DATE) AS TestRunDate,
        'Expected Call Count' AS TestName,
		ActualResult,
        AverageResult as ExpectedResult,
        CASE
            WHEN ActualResult <= AverageResult THEN AverageResult - ActualResult
            WHEN ActualResult > AverageResult THEN ActualResult - AverageResult
        END as Deviation,
        GETDATE() AS CreatedOn,
        '[CapstoneDB].[dbo].[BI_Health_BI_Call_Detail]' AS CreatedBy,
        NULL AS ModifiedOn,
        NULL AS ModifiedBy
    FROM WeeklyAverages
    FULL OUTER JOIN DetailInfo ON WeeklyAverages.timespan = DetailInfo.timespan
    WHERE connectTime = DATEADD(day, -1, CAST(GETDATE() AS DATE))
    GROUP BY connectTime, DetailInfo.timespan, day_of_week, AverageResult, ActualResult
    ORDER BY connectTime DESC;

	

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
		#temp_BI_Call_Detail; --temp table 

	DROP TABLE #temp_BI_Call_Detail;

	SET NOCOUNT OFF;
END;