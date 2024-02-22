select top 10 
		id,
		cast (createdOn as date) as CreatedOn,
		tranId,
		adminNumber,
		transactionAmount
From BI_Feed.dbo.BI_BDA_Transactions
order by CAST(CreatedOn as date ) desc;

select count(cast(CreatedOn as Date))as CreatedOn
from BI_Feed.dbo.BI_BDA_Transactions
where CreatedOn > '2024-02-21';

select  top 1 count(distinct CAST(createdOn as date) )as CreatedOn
from BI_Feed.dbo.BI_BDA_Transactions (nolock)
where createdOn > '2024-02-20'
group by CAST(createdOn as date);

select top 1 cast(CreatedOn as date),
			  Count(Cast(CreatedOn as date) )
from BI_Feed.dbo.BI_BDA_Transactions with (nolock)
group by Cast(CreatedOn as date)
order by Cast(CreatedOn as date);

select tranId
from BI_Feed.dbo.BI_BDA_Transactions
where createdOn > '2024-02-21'
order by tranID;
