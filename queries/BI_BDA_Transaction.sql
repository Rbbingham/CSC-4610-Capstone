select  top 1 count(distinct CAST(createdOn as date) )as CreatedOn
from BI_Feed.dbo.BI_BDA_Transactions (nolock)
where createdOn > '2024-02-20'
group by CAST(createdOn as date);

select  top 1 Count(distinct CreatedOn)
from BI_Feed.dbo.BI_BDA_Transactions with (nolock)
where createdOn > '2024-02-20'
group by createdOn;