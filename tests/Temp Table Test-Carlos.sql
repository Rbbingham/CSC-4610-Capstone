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

SELECT * FROM  #temp_BI_BDA_UniqueProducts; -- Selecting from temporary table
DROP TABLE #temp_BI_BDA_UniqueProducts; -- Final, drop the temporary table

Insert into CapstoneDB.dbo.TnTech_TestResults(TableName,ActualResult, ExpectedResult,Completed)
Select TableName,ActualResult,ExpectedResult,1
from #temp_BI_BDA_UniqueProducts;

select * from CapstoneDB.dbo.TnTech_TestResults;




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

SELECT * FROM  #temp_Toyota_Distribution; -- Selecting from temporary table
DROP TABLE #temp_Toyota_Distribution; -- Final, drop the temporary table

Insert into CapstoneDB.dbo.TnTech_TestResults(TableName,ActualResult, ExpectedResult,Result)
Select TableName,ActualResult,ExpectedResult,1
from #temp_Toyota_Distribution;

select * from CapstoneDB.dbo.TnTech_TestResults;