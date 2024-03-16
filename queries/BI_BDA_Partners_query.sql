SELECT *
FROM BI_Feed.dbo.BI_BDA_Partners
ORDER BY id DESC;

select * from BI_BDA_Partners order by id Desc;

select Count(partnerId) from BI_BDA_Partners
select Count(Distinct partnerId) from BI_BDA_Partners

select Count(partnerName) from BI_BDA_Partners
select Count(Distinct partnerName) from BI_BDA_Partners

select Count(*) from BI_BDA_Partners

Select Count(productId) from BI_BDA_Partners with(nolock)
Select Count(Distinct productId) from BI_BDA_Partners with(nolock)

SELECT COUNT(ID)from BI_BDA_Partners with(nolock)
SELECT COUNT(DISTINCT ID)from BI_BDA_Partners with (nolock)