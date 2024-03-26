----BI_FinCen314A_LimeBank Query----
select * from BI_Feed.dbo.BI_FinCen314A_LimeBank;

Select Cast(CreatedOn as Date)as CreatedOn,
	COUNT(Cast(CreatedOn as Date)) RecordCount
from BI_Feed.dbo.BI_FinCen314A_LimeBank
Group by Cast(CreatedOn as Date)
order by Cast(CreatedOn as Date) DESC