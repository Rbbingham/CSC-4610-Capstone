USE [CapstoneDB]
GO

/******************************************************************************
	
	CREATOR:	Grant Tarver

	CREATED:	February 16, 2024

	PURPOSE:	Inserts a new record into [CapstoneDB].[dbo].[BI_HealthResults]
	if record doesn't already exist. Updated the record otherwise.

	MODIFICATIONS:
	2024/02/26	Rbbingham	Updated procedure to use table type 
							[CapstoneDB].[dbo].[TnTech_TableType]

******************************************************************************/

CREATE OR ALTER PROCEDURE [dbo].[BI_InsertTestResult](
	@Table [dbo].[TnTech_TableType] READONLY
	)
AS
BEGIN
	SET NOCOUNT ON;

	IF EXISTS ( 
		SELECT 
			* 
		FROM 
			[CapstoneDB].[dbo].[BI_HealthResults] AS T1
		INNER JOIN
			@Table AS T2
		ON 
			T1.TableName = T2.TableName AND 
			T1.TestName = T2.TestName)
	BEGIN
		PRINT N'Record Updated'
		UPDATE T1
			SET
				T1.TestRunDate = GETDATE(),
				T1.ActualResult = T2.ActualResult,
				T1.ExpectedResult = T2.ExpectedResult,
				T1.Deviation = T2.Deviation,
				T1.RiskScore = T2.RiskScore,
				T1.ModifiedOn = GETDATE(),
				T1.ModifiedBy = T1.TestName
			FROM
				[CapstoneDB].[dbo].[BI_HealthResults] AS T1
			INNER JOIN
				@Table AS T2
			ON 
				T1.TableName = T2.TableName AND 
				T1.TestName = T2.TestName;
	END

	ELSE

	BEGIN
		PRINT N'Record Inserted'
		INSERT INTO 
			[CapstoneDB].[dbo].[BI_HealthResults](
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
			ModifiedBy
		FROM
			@Table
	END

	SET NOCOUNT OFF;
END
GO