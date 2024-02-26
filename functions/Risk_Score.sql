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
	

	RETURN @ret;
END;
GO