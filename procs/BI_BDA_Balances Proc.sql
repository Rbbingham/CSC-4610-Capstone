-- TODO: Replace AccountNumber with productId
SELECT 
	CAST(CreatedOn AS DATE) as CreatedOnDate,
	COUNT(productId) as NumProductID
FROM BI_Feed.dbo.BI_BDA_Balances WITH (nolock) 
WHERE CAST(CreatedOn AS DATE) > '2024-01-01'
GROUP BY CAST(CreatedOn AS DATE) 
ORDER BY CAST(CreatedOn AS DATE) ASC;

SELECT CreatedOn, balanceDate, productId, beginningBalance, endingBalance FROM BI_FEED.dbo.BI_BDA_Balances WITH (nolock);