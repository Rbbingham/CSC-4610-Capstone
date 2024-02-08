--3 BI_Feed.dbo.BI_BankCore_Products

SELECT -- Check expected 5 productID recorded
	'BI_BankCore_Products' as TableName, 
	'Expected Products Amount' as TestName, 
	cast(GETDATE() AS DATE) as TestDate, 
	COUNT(*) as ActualResult,  -- What happens when a duplicate occurs?
	5 as ExpectedResult -- Will always be 5
	into #temp_bankcore_products
FROM BI_Feed.dbo.BI_BankCore_Products with (nolock);

ALTER TABLE #temp_bankcore_products ADD Deviation Int; -- Adding Deviation to the temporary table
UPDATE #temp_bankcore_products
SET Deviation = ActualResult - ExpectedResult; -- Updating Deviation to the deviation

-- insert your result into the CapstoneDB.dbo.TnTech_TestResults
Insert into CapstoneDB.dbo.TnTech_TestResults(CreatedBy,TableName,ActualResult, ExpectedResult,Completed)
Select TestName,TableName,ActualResult,ExpectedResult,1
from #temp_bankcore_products;


DROP TABLE #temp_bankcore_products; -- Final, drop the temporary table


--6 BI_Feed.dbo.BI_BDA_Institutions
SELECT -- Ensuring that 20 institutions are available in the table.
	'BI_BDA_Institutions' as TableName, 
	'Expected Institution IDs' as TestName, 
	cast(GETDATE() AS DATE) as TestDate, 
	COUNT(distinct institutionId) as ActualResult,
	20 as ExpectedResult
	into #temp_institutions
FROM BI_Feed.dbo.BI_BDA_Institutions with (nolock);

ALTER TABLE #temp_institutions ADD Deviation Int; -- Adding Deviation to the temporary table
UPDATE #temp_institutions
SET Deviation = ActualResult - ExpectedResult; -- Updating Deviation to the deviation


Insert into CapstoneDB.dbo.TnTech_TestResults(CreatedBy,TableName,ActualResult, ExpectedResult,Completed)
Select TestName,TableName,ActualResult,ExpectedResult,1
from #temp_institutions;


DROP TABLE #temp_institutions; -- Final, drop the temporary table


--12 BI_Feed.dbo.BI_BDA_UniqueProducts
select Cast(GETDATE() AS DATE) as TestDate,
		'BI_BDA_UniqueProducts' as TableName,
		'Record Count' as TestName,
		count(distinct id) as ActualResult,
		3850 as ExpectedResult
into #temp_BI_BDA_UniqueProducts
from BI_Feed.dbo.BI_BDA_UniqueProducts with (nolock);

ALTER TABLE #temp_BI_BDA_UniqueProducts ADD Deviation Int; -- Adding Deviation to the temporary table

UPDATE  #temp_BI_BDA_UniqueProducts
SET Deviation = ActualResult - ExpectedResult; -- Updating Deviation to the actual deviation


Insert into CapstoneDB.dbo.TnTech_TestResults(CreatedBy,TableName,ActualResult, ExpectedResult,Completed)
Select TestName,TableName,ActualResult,ExpectedResult,1
from #temp_BI_BDA_UniqueProducts;


DROP TABLE #temp_BI_BDA_UniqueProducts; -- Final, drop the temporary table

-- 23 BI_Feed.dbo.BI_ProductInclusionTables

--Merchant Group Test
SELECT 
	cast(GETDATE() AS DATE)as TestDate,
	'BI_ProductInclusionTables'as TableName,
	'Check merchant groups' as TestName,
	COUNT(DISTINCT MerchantGroup) as ActualResult,
	60 as ExpectedResult
into #temp_BI_ProductInclusionTables
FROM BI_Feed.dbo.BI_ProductInclusionTables with (nolock);

ALTER TABLE #temp_BI_ProductInclusionTables ADD Deviation Int;

-- Distinct Products
Insert into #temp_BI_ProductInclusionTables(TestDate,TableName,TestName, ActualResult,ExpectedResult)
SELECT 
	cast(GETDATE() AS DATE)as TestDate,
	'BI_ProductInclusionTables' as TableName,
	'Check Product IDs' as TestName,
	COUNT(DISTINCT ProductID) as ActualResult,
	275 as ExpectedResult
FROM BI_Feed.dbo.BI_ProductInclusionTables with (nolock);

UPDATE  #temp_BI_ProductInclusionTables
SET Deviation = ActualResult - ExpectedResult;

insert into CapstoneDB.dbo.TnTech_TestResults(CreatedBy,TableName,ActualResult, ExpectedResult,Completed)
Select TestName,TableName,ActualResult,ExpectedResult,1
from #temp_BI_ProductInclusionTables;

Drop table #temp_BI_ProductInclusionTables;

--24 BI_Feed.dbo.BI_Program_CardUsageCounts
select 
	CAST(GETDATE() as DATE) as TestDate,
	'BI_Program_CardUsageCounts' as TableName,
	'Program ID Count' as TestName,
	Count(Distinct ProgramId) as ActualResult,
	3200 as ExpectedResult
into #temp_BI_Program_CardUsageCounts
From BI_feed.dbo.BI_Program_CardUsageCounts with (nolock);

ALTER TABLE #temp_BI_Program_CardUsageCounts ADD Deviation Int;

Insert into CapstoneDB.dbo.TnTech_TestResults(CreatedBy,TableName,ActualResult, ExpectedResult,Completed)
Select TestName,TableName,ActualResult,ExpectedResult,1
from #temp_BI_Program_CardUsageCounts;

drop table #temp_BI_Program_CardUsageCounts;


--29 BI_Feed.dbo.Toyota_Distribution
select  Cast(GETDATE() AS DATE) as TestDate,
		'Toyota_Distribution' as TableName,
		'VIN Count' as TestName,
		count(distinct Vin) as ActualResult,
		13000 as ExpectedResult 
into #temp_Toyota_Distribution
from BI_Feed.dbo.Toyota_Distribution with(nolock);

ALTER TABLE #temp_Toyota_Distribution ADD Deviation Int; -- Adding Deviation to the temporary table

UPDATE  #temp_Toyota_Distribution
SET Deviation = ActualResult - ExpectedResult; -- Updating Deviation to the actual deviation

Insert into CapstoneDB.dbo.TnTech_TestResults(CreatedBy,TableName,ActualResult, ExpectedResult,Completed)
Select TestName,TableName,ActualResult,ExpectedResult,1
from #temp_Toyota_Distribution;

DROP TABLE #temp_Toyota_Distribution; -- Final, drop the temporary table

-- See our results after running
select * from CapstoneDB.dbo.TnTech_TestResults;
