USE [CapstoneDB]
GO

/******************************************************************************
	
	CREATOR:	Robert Bingham

	CREATED:	02/26/2024

	PURPOSE:	Calculates the risk score.

******************************************************************************/

CREATE OR ALTER FUNCTION [dbo].[CalculateRiskScore] (
	@ActualResult bigint,
	@ExpectedResult bigint
)
RETURNS int
AS
BEGIN
	DECLARE @ret int;

	IF @ExpectedResult = 0
		IF @ActualResult <> 0
			SET @ret = 10;
		ELSE
			SET @ret = 0;
	ELSE
		SET @ret = ABS((CAST(@ActualResult AS float) / CAST(@ExpectedResult AS float)) - 1) * 10;

	IF @ret > 10
		SET @ret = 10;

	RETURN @ret;
END;
GO