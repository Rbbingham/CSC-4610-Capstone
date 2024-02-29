select top 5 
		id,
		cast (createdOn as date) as CreatedOn,
		tranId,
		adminNumber,
		transactionAmount
From BI_Feed.dbo.BI_BDA_Transactions with (nolock)
order by CAST(CreatedOn as date ) desc;

select count(cast(CreatedOn as Date))as CreatedOn
from BI_Feed.dbo.BI_BDA_Transactions with (nolock)
where CreatedOn > '2024-02-28';

select  top 1 count(distinct CAST(createdOn as date) )as CreatedOn
from BI_Feed.dbo.BI_BDA_Transactions (nolock)
where createdOn > '2024-02-28'
group by CAST(createdOn as date);

select top 2 cast(CreatedOn as date) as CreatedOn,
			  Count(Cast(CreatedOn as date) )
from BI_Feed.dbo.BI_BDA_Transactions with (nolock)
group by Cast(CreatedOn as date)
order by Cast(CreatedOn as date) Desc;

select Cast(CreatedOn as DATE) as CreatedOn,
		count(distinct tranId) as TransactionCount
from BI_Feed.dbo.BI_BDA_Transactions with (nolock)
where createdOn > '2024-02-28'
group by Cast(createdOn as Date);



