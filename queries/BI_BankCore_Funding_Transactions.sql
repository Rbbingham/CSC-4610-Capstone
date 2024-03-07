use BI_Feed;

select Count(ModifedOnDate) as Amount from dbo.BI_BankCore_Funding_Transactions with (nolock)
--where ModifedOnDate = CAST(DATEADD(day, -1, GETDATE()) as DATE);

select CAST(createdOn as DATE), count(ModifedOnDate) from dbo.BI_BankCore_Funding_Transactions with (nolock)
group by CAST(CreatedOn as DATE)
order by CAST(CreatedOn as DATE) DESC;