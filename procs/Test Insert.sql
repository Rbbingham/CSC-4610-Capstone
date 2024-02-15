CREATE OR ALTER PROCEDURE [dbo].[InsertTestResult]
	@CreatedOn DATETIME,
	@CreatedBy VARCHAR(256),
	@ModifiedOn DATETIME,
	@ModifiedBy VARCHAR(256),
	@TableName VARCHAR(256),
	@ActualResult BIGINT,
	@ExpectedResult BIGINT,
	@TestRunDate DATE,
	@TestName VARCHAR(256)
AS
BEGIN
	SET NOCOUNT ON;

	IF EXISTS ( SELECT * FROM CapstoneDB.dbo.TnTech_TestResults WHERE TableName = @TableName AND TestName = @TestName AND TestRunDate = @TestRunDate)
	BEGIN
		UPDATE CapstoneDB.dbo.TnTech_TestResults
		SET [CreatedOn] = @CreatedOn,
			[CreatedBy] = @CreatedBy,
			[ModifiedOn] = @ModifiedOn,
			[ModifiedBy] = @ModifiedBy,
			[ActualResult] = @ActualResult,
			[ExpectedResult] = @ExpectedResult,
			[TestRunDate] = @TestRunDate,
		WHERE [TableName] = @TableName AND [TestName] = @TestName AND [TestRunDate] = @TestRunDate;
	END

	ELSE

	BEGIN
		INSERT INTO CapstoneDB.dbo.TnTech_TestResults (CreatedOn, CreatedBy, ModifiedOn, ModifiedBy, TableName, ActualResult, ExpectedResult, TestRunDate, TestName)
		VALUES (
			@CreatedOn,
			@CreatedBy,
			@ModifiedOn,
			@ModifiedBy,
			@TableName,
		    @ActualResult,
			@ExpectedResult,
			@TestRunDate,
			@TestName
			);
	END
END;