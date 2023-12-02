Use BI_Feed;

--1
select Distinct count( FundingTransactionId)
from BI_Feed.dbo.BI_BankCore_Funding_Transactions with(nolock);

select Cast(CreatedOn as DATE) as CreatedOn , 
	   sum(amount) as AmountSum
from BI_Feed.dbo.BI_BankCore_Funding_Transactions with(nolock)
where CreatedOn > '2023-10-01'
group by Cast(CreatedOn as date)
order by CAST(CreatedOn as Date);

select count(BillingType) as BillingCount, BillingType -- count of which Billing Type
from BI_Feed.dbo.BI_BankCore_Funding_Transactions
group by BillingType;

--2

--3
select count(TransactionID) as Transaction_Count
from BI_Feed.dbo.BI_BankCore_Transactions;

select  Sum(TransactionAmount)as TransactionAmount, 
		CAST( transactiondate as DATE) as TransactionDate 
from BI_Feed.dbo.BI_BankCore_Transactions with (nolock)
where transactiondate > '2023-10-01'
group by CAST( transactiondate as DATE)
order by CAST( transactiondate as DATE);

--4
select id,CreatedOn,balanceDate,productId, beginningBalance, endingBalance
from BI_Feed.dbo.BI_BDA_Balances;

select  count(productId) as IDCount, productId -- returns unique productId on a given day 
from BI_Feed.dbo.BI_BDA_Balances
where CreatedOn >'2023-10-01'
group by productId
order by productId;

--7
select CAST(createdOn as date) as CreatedOn, 
	   SUM(beginningBalance) as BeginBalance, -- sum of beginning balances
	   SUM(endingBalance) as EndingBalance, -- sum of ending balances
	   SUM(beginningBalance - endingBalance) as DifferenceBalance -- difference of the 2 columns
from BI_Feed.dbo.BI_BDA_Master with (nolock)
where createdOn > '2023-10-01'
group by CAST(createdOn as date)
order by CAST(createdOn as date);

--8

select top 10 *
 from BI_Feed.dbo.BI_BDA_Partners with(nolock)
 order by createdOn desc;

select  distinct count(masterPartnerId), -- unique count
		masterPartnerID
from BI_Feed.dbo.BI_BDA_Partners with(nolock)
where createdOn > '2023-10-01'
group by masterPartnerId
order by masterPartnerId;

--9 
select count(CAST(reportDate as Date) )as ReportDate,
		CAST(reportDate as Date)
from BI_Feed.dbo.BI_BDA_ReportDates with(nolock)
where reportDate >'2023-10-01'
group by CAST(reportDate as Date)
order by CAST(reportDate as Date);

--10 -- large query 
select count(id), CAST(createdOn as date) 
from BI_Feed.dbo.BI_BDA_Transactions with(nolock)
where createdOn > '2023-10-01' and createdOn <'2023-11-01'
group by  CAST(createdOn as date)
order by  CAST(createdOn as date);

--30
select top 10 CreatedOn, ModifiedOn,Location,VIN,AdminNumber
from BI_Feed.dbo.Toyota_Inventory;

select count(Cast(CreatedOn as DATE)) as CreatedOnCount, Cast(CreatedOn as DATE)
from BI_Feed.dbo.Toyota_Inventory
where CreatedOn > '2023-10-01'
group by Cast(CreatedOn as DATE)
order by Cast(CreatedOn as DATE);

select Count(AdminNumber) AdminNumber
from BI_Feed.dbo.Toyota_Inventory
group by AdminNumber
order by AdminNumber;

