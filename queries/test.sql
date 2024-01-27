USE [CapstoneDB];

DECLARE @Table AS [dbo].[TnTech_TableType];

INSERT INTO
	@Table(CreatedOn, CreatedBy, ModifiedOn, ModifiedBy)
SELECT
	CreatedOn,
	NULL AS CreatedBy,
	NULL AS ModifiedOn,
	NULL AS ModifiedBy
FROM
	[BI_Feed].[dbo].[Toyota_Distribution]
WHERE
	CAST(CreatedOn AS DATE) = CAST(GETDATE() AS DATE);

EXEC [dbo].[TnTech_CountRecords] @Records = @Table, @TableName = 'dbo.Toyota_Distribution';