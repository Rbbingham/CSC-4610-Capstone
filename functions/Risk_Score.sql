/******************************************************************************
	
	CREATOR:	Robert Bingham

	CREATED:	02/26/2024

	PURPOSE:	Calculates the risk score.

******************************************************************************/

USE [CapstoneDB]
GO

CREATE OR ALTER FUNCTION [dbo].[CalculateRiskScore] (
	@ActualResult bigint,
	@ExpectedResult bigint
)
RETURNS int
AS
BEGIN
	DECLARE @ret int;

	IF @ExpectedResult = 0 AND @ActualResult > 0
		SET @ret = 10;
	ELSE
		SET @ret = ABS((@ActualResult / @ExpectedResult) - 1) * 10;

	IF @ret > 10
		SET @ret = 10;

	RETURN @ret;
END;
GO
