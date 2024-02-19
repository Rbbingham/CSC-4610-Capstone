CREATE OR ALTER PROCEDURE [dbo].[BI_InsertTestResult]
	@TableName VARCHAR(256),
	@TestRunDate DATE,
	@TestName VARCHAR(256),
	@ActualResult BIGINT,
	@ExpectedResult BIGINT,
	@Deviation BIGINT,
	@CreatedOn DATETIME,
	@CreatedBy VARCHAR(256),
	@ModifiedOn DATETIME,
	@ModifiedBy VARCHAR(256)
AS
BEGIN
	SET NOCOUNT ON;

	IF EXISTS ( SELECT * FROM CapstoneDB.dbo.BI_HealthResults WHERE TableName = @TableName AND TestName = @TestName AND TestRunDate = @TestRunDate)
	BEGIN
		UPDATE CapstoneDB.dbo.BI_HealthResults
		SET
			[ActualResult] = @ActualResult,
			[ExpectedResult] = @ExpectedResult,
			[Deviation] = @Deviation,
			[CreatedOn] = @CreatedOn,
			[CreatedBy] = @CreatedBy,
			[ModifiedOn] = @ModifiedOn,
			[ModifiedBy] = @ModifiedBy
		WHERE [TableName] = @TableName AND [TestName] = @TestName AND [TestRunDate] = @TestRunDate;
	END

	ELSE

	BEGIN
		INSERT INTO CapstoneDB.dbo.BI_HealthResults (TableName, TestRunDate, TestName, ActualResult, ExpectedResult, Deviation, CreatedOn, CreatedBy, ModifiedOn, ModifiedBy)
		VALUES (
			@TableName,
			@TestRunDate,
			@TestName,
			@ActualResult,
			@ExpectedResult,
			@Deviation,
			@CreatedOn,
			@CreatedBy,
			@ModifiedOn,
			@ModifiedBy
			);
	END

	SET NOCOUNT OFF;
END;
