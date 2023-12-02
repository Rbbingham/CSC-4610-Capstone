select Cast(CreatedOn as DATE) as CreatedOn , 
	   sum(amount) as AmountSum
from BI_Feed.dbo.BI_BankCore_Funding_Transactions with(nolock)
where CreatedOn > '2023-10-01'
group by Cast(CreatedOn as date)
order by CAST(CreatedOn as Date);

select Cast(CreatedOn as DATE) as CreatedOn , 
		sum(amount) as AmountSum,
	   count(FundingTransactionId) as TransID,
	   count (distinct TargetPaymentAccountId) as CountDistinct
from BI_Feed.dbo.BI_BankCore_Funding_Transactions with(nolock)
where CreatedOn > '2023-10-01'
group by Cast(CreatedOn as date)
order by CAST(CreatedOn as Date);

select *
from BI_Feed.dbo.BI_BDA_Master with(nolock)
where reportDate = '2023-11-16' and productId = 44903;

select top 10*
from BI_Feed.dbo.BI_BDA_Partners with(nolock);

select count(productID), count(distinct productID)
from BI_Feed.dbo.BI_BDA_UniqueProducts with (nolock);

select  CAST(callDate as DATE) as callDate,
		count(callID)
from BI_Feed.dbo.BI_Call_Master with(nolock)
where CAST(callDate as DATE) > '2023-10-01'
group by CAST(callDate as DATE)
order by CAST(callDate as DATE);

select *
from BI_Feed.dbo.BI_FinCen314A_LimeBank
order by CreatedOn desc;