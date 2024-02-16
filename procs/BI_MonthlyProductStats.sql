/************************************************************
	CREATOR:	Collin Cunningham
	CREATED:	20240213
	PURPOSE:	Data health check for BI_MonthlyProductStats
	
	MODIFICATIONS:
	
	None
************************************************************/

CREATE OR ALTER PROCEDURE CHECK_MonthlyProductStats
AS
BEGIN
SET NOCOUNT ON;

drop table if exists #temp_monthlyproductstats;
select MAX(Cast(CreatedOn as DATE)) as tableEntry_Date,
      count(distinct ProductId) as ID_Count
	into #temp_monthlyproductstats
from
      bi_feed.dbo.BI_MonthlyProductStats with (nolock)
group by
      Cast(CreatedOn as DATE)
order by
      Cast(CreatedOn as DATE);
select tableEntry_Date, ID_Count from #temp_monthlyproductstats
order by tableEntry_Date;

SET NOCOUNT OFF;
END

select Cast(CreatedOn as DATE) as tableEntry_Date,
      count(distinct ID)
from
      bi_feed.dbo.BI_MerchantGroupMIDs with (nolock)
group by
      Cast(CreatedOn as DATE);