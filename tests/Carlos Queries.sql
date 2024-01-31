--10 BI_Feed.dbo.BI_BDA_Transactions
select id,createdOn,tranId,adminNumber
from BI_Feed.dbo.BI_BDA_Transactions;

--12 BI_Feed.dbo.BI_BDA_UniqueProducts
select top 10*
from BI_Feed.dbo.BI_BDA_UniqueProducts;

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
SELECT * FROM  #temp_BI_BDA_UniqueProducts; -- Selecting from temporary table
DROP TABLE #temp_BI_BDA_UniqueProducts; -- Final, drop the temporary table



select * from CapstoneDB.dbo.TnTech_RecordCounts;

--29 BI_Feed.dbo.Toyota_Distribution
Select CreatedOn,CreatedBy, ModifiedOn, ModifiedBy, CardCreateDate, VIN,AdminNumber, Location, CurrentLimit
from BI_Feed.dbo.Toyota_Distribution;


select  Cast(CreatedOn as DATE) as CreatedOn,
		count(distinct Vin) as VINCount
from BI_Feed.dbo.Toyota_Distribution with(nolock)
group by Cast(CreatedOn as DATE);

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

SELECT * FROM  #temp_Toyota_Distribution; -- Selecting from temporary table
DROP TABLE #temp_Toyota_Distribution; -- Final, drop the temporary table


--30 BI_Feed.dbo.Toyota_Inventory
select top 10 CreatedOn, ModifiedOn,Location,VIN,AdminNumber
from BI_Feed.dbo.Toyota_Inventory;

-- Imported on we do not have access to 
select  Cast(ImportedOn as DATE) as tableEntry_Date,
		count(distinct AdminNumber) as AdminCount
from BI_Feed.dbo.Toyota_Inventory with (nolock)
group by Cast(ImportedOn as DATE);

-- this checks all adminNumbers over all existence 
Select
		count(distinct AdminNumber) as AdminCount
from BI_Feed.dbo.Toyota_Inventory;

-- Are we free to create tables in Capstone DB in that case 
-- Columns should be --Example for 1/18/23
-- Test Date       Table Name							Test Name			Expected Value			Actual Value           Deviation			Percent Deviation
-- 1/18/2024       BI_Feed.dbo.Toyota_Distribution     Check VIN Count         13000					13023				-23						
-- 1/18/2024       BI_Feed.dbo.Toyota_Inventory        Check Admin Count       21000                    21488               -488					
