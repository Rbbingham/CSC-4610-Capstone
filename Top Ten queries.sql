-- query from top to bottom tables --
--1
select top 10*
from BI_Feed.dbo.BI_BankCore_Funding_Transactions;

--2 truncate and reload it 
select *
from BI_Feed.dbo.BI_BankCore_Products;
-- need a new table(history table)
-- Bankcore_Products_History
-- snapshot of a metric

--3
select top 10*
from BI_Feed.dbo.BI_BankCore_Transactions;

--4 -- access denied
select top 10*
from BI_Feed.dbo.BI_BDA_Balances;

select id,CreatedOn,balanceDate,productId, beginningBalance, endingBalance
from BI_Feed.dbo.BI_BDA_Balances;

--5
select top 10*
from BI_Feed.dbo.BI_BDA_BalancesSummary;

--6
select *
from BI_Feed.dbo.BI_BDA_Institutions;
-- createdOn
-- going to need a history like the other table 
-- every day that 20 insitutions get loaded

--7
select top 10*
from BI_Feed.dbo.BI_BDA_Master;

--8
select top 10*
from BI_Feed.dbo.BI_BDA_Partners;

--9
select top 10*
from BI_Feed.dbo.BI_BDA_ReportDates;

--10 -- access denied
select top 10*
from BI_Feed.dbo.BI_BDA_Transactions;

select id,createdOn,tranId,adminNumber
from BI_Feed.dbo.BI_BDA_Transactions;

--11
select top 10*
from BI_Feed.dbo.BI_BDA_TransactionsSummary;

--12
select top 10*
from BI_Feed.dbo.BI_BDA_UniqueProducts;

--13
select top 10*
from BI_Feed.dbo.BI_Call_Detail;
--multiple records for the same one 

--14
select top 10*
from BI_Feed.dbo.BI_Call_Master;

--15
select top 10*
from BI_Feed.dbo.BI_FinCen314A_LimeBank;

--16
select top 10*
from BI_Feed.dbo.BI_MerchantGroupMIDs;

--17
select top 10*
from BI_Feed.dbo.BI_MonthlyProductStats;

--18 -- access denied 
select top 10*
from BI_Feed.dbo.BI_PA_Balances;

--19
select top 10*
from BI_Feed.dbo.BI_PA_ChecksOutbound;

--20 -- access denied 
select top 10*
from BI_Feed.dbo.BI_PA_PrysymSettlements;

--21
select top 10*
from BI_Feed.dbo.BI_PA_Transactions;

--22
select top 10*
from BI_Feed.dbo.BI_PaymentAccountMemos;

--23
select top 10*
from BI_Feed.dbo.BI_ProductInclusionTables;

--24
select top 10*
from BI_Feed.dbo.BI_Program_CardUsageCounts;

--25 -- access denied 
select top 10*
from BI_Feed.dbo.BI_TPAS_AccountHolders;

select top 10* Except(FirstName,MiddleName,LastName)
from BI_Feed.dbo.BI_TPAS_AccountHolders;

--26
select top 10*
from BI_Feed.dbo.BI_VincentSLAAggregate;

--27 --access denied
select top 10*
from BI_Feed.dbo.Card_Production;

select ProductionID, PrintDate,adminNumber, CreatedOn, ModifiedOn, cardCreateDate
from BI_Feed.dbo.Card_Production;

--28
select top 10*
from BI_Feed.dbo.CardCounts;

--29 --access denied
select top 10*
from BI_Feed.dbo.Toyota_Distribution;

Select CreatedOn,CreatedBy, ModifiedOn, ModifiedBy, CardCreateDate, VIN,AdminNumber, Location, CurrentLimit
from BI_Feed.dbo.Toyota_Distribution;

--30 --access denied -- these columns are what we have access to  
select top 10 CreatedOn, ModifiedOn,Location,VIN,AdminNumber
from BI_Feed.dbo.Toyota_Inventory;
