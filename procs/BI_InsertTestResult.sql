USE [CapstoneDB]
GO

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
			T1.TestName = T2.TestName AND 
			T1.TestRunDate = T2.TestRunDate)
	BEGIN
		PRINT N'1'
		UPDATE T1
			SET
				T1.TestRunDate = GETDATE(),
				T1.ActualResult = T2.ActualResult,
				T1.ExpectedResult = T2.ExpectedResult,
				T1.Deviation = T2.Deviation,
				T1.ModifiedOn = GETDATE(),
				T1.ModifiedBy = T1.TestName
			FROM
				[CapstoneDB].[dbo].[BI_HealthResults] AS T1
			INNER JOIN
				@Table AS T2
			ON 
				T1.TableName = T2.TableName AND 
				T1.TestName = T2.TestName AND 
				T1.TestRunDate = T2.TestRunDate;
	END

	ELSE

	BEGIN
		PRINT N'0'
		INSERT INTO 
			[CapstoneDB].[dbo].[BI_HealthResults](
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
			@Table
	END

	SET NOCOUNT OFF;
END
GO