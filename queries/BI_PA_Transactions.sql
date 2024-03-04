select *
from BI_Feed.dbo.BI_PA_Transactions;

select Cast(transactionDate as date) as TransactionDate,
	count(CAST(transactionDate as Date))as TransactionCount,
	count(distinct paymentAccountId)as PaymentAccountId
from BI_Feed.dbo.BI_PA_Transactions
group by Cast(transactionDate as date)
order by Cast(transactionDate as date) desc;