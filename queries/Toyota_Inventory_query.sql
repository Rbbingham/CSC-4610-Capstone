select CreatedOn, ModifiedOn, Location, VIN, AdminNumber
from BI_Feed.dbo.Toyota_Inventory with (nolock);

-- gets number that is over 21000
Select count(distinct AdminNumber) as ActualResult
from BI_Feed.dbo.Toyota_Inventory with (nolock);

-- CreatedOn does not have all dates that we need 
select distinct CAST(CreatedOn as DATE)
from BI_Feed.dbo.Toyota_Inventory with (nolock)
order by CAST(CreatedOn as DATE)DESC;

--ModifiedOn Gives us all the dates 
select distinct CAST(ModifiedOn as DATE)
from BI_Feed.dbo.Toyota_Inventory with (nolock)
order by CAST(ModifiedOn as DATE) DESC;


select distinct CAST(ModifiedOn as DATE), 
count(distinct AdminNumber)
from BI_Feed.dbo.Toyota_Inventory with (nolock)
group by CAST(ModifiedOn as DATE) 
order by CAST(ModifiedOn as DATE)Desc;

use CapstoneDB;
EXEC BI_Health_Toyota_Inventory;
EXEC BI_Health_


select * from CapstoneDB.dbo.BI_HealthResults;