----BI_FinCen314A_LimeBank Query----
select * from BI_Feed.dbo.BI_FinCen314A_LimeBank;

Select Cast(CreatedOn as Date)as CreatedOn,
	COUNT(Cast(CreatedOn as Date)) RecordCount
from BI_Feed.dbo.BI_FinCen314A_LimeBank with (nolock)
Group by Cast(CreatedOn as Date)
order by Cast(CreatedOn as Date) DESC
-------------------------------------------
-- Check for the beginning of the month (from 27th of the previous month to the 9th of the current month)
IF (SELECT COUNT(*)
    FROM BI_Feed.dbo.BI_FinCen314A_LimeBank with (nolock)
    WHERE 
        (CreatedOn BETWEEN DATEADD(DAY, -3, DATEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE()), 1)) 
                             AND DATEADD(DAY, 8, DATEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE()), 1)))
        
    ) < 2
 
-- Check for the middle of the month (from the 10th to the 21th)
IF (SELECT COUNT(*)
    FROM BI_Feed.dbo.BI_FinCen314A_LimeBank with (nolock)
    WHERE CreatedOn BETWEEN DATEADD(DAY, 9, DATEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE()), 1))
                             AND DATEADD(DAY, 21, DATEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE()), 1))
    ) < 2
--------------------------------------------------------------------
select Year(GETDATE()) as Year, Month(GetDate()) as Month
SELECT DATEFROMPARTS(YEAR(GETDATE()),MONTH(GETDATE()),1) 

-- Dates between the 27 and 9
SELECT DATEADD(DAY, -3, DATEFROMPARTS(Year(GETDATE()),Month(GETDATE()),1))
SELECT DATEADD(DAY, 8, DATEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE()), 1))
--Dates between 29 and 1 do we need this?
SELECT DATEADD(MONTH, -1, DATEADD(DAY, 28, DATEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE()), 1)))
SELECT DATEADD(MONTH, -1, DATEADD(DAY, 31, DATEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE()), 1)))
--Dates between the 10 and 21
select DATEADD(DAY, 9, DATEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE()), 1))
Select DATEADD(DAY, 20, DATEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE()), 1))

------------------------------------------------------------------------
----Unused code from being section 
OR 
        (CreatedOn BETWEEN DATEADD(MONTH, -1, DATEADD(DAY, 28, DATEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE()), 1))) 
                             AND DATEADD(MONTH, -1, DATEADD(DAY, 31, DATEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE()), 1))))