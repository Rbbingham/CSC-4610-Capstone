USE [CapstoneDB]
GO

CREATE OR ALTER PROCEDURE [dbo].[test]
AS
BEGIN
	SET NOCOUNT ON;

	CREATE TABLE #BI_Tables (
		TableName varchar(256) NOT NULL,
	)

	INSERT INTO 
		#BI_Tables(TableName)
	SELECT
		DISTINCT 'BI_Feed.dbo.' + [BI_Feed].[sys].[tables].name
	FROM
		[BI_Feed].[sys].[tables] INNER JOIN [BI_Feed].[sys].[columns]
		ON (OBJECT_ID('BI_Feed.dbo.' + [BI_Feed].[sys].[tables].name) = [BI_Feed].[sys].[columns].object_id
		AND [BI_Feed].[sys].[columns].name = 'CreatedOn');

	WHILE EXISTS(SELECT * FROM #BI_Tables)
	BEGIN
		DECLARE @TableName varchar(256);
		SET @TableName = (SELECT TOP(1) TableName FROM #BI_Tables);

		SELECT @TableName;

		DECLARE @Command varchar(max) = '
			SELECT
				CreatedOn
			FROM ' +
				@TableName + '
			WHERE
				CAST(CreatedOn AS DATE) = CAST(GETDATE() AS DATE);'

		EXEC(@Command);

		DELETE TOP(1) FROM #BI_Tables;
	END

	DROP TABLE #BI_Tables;

	SET NOCOUNT OFF;
END;
GO