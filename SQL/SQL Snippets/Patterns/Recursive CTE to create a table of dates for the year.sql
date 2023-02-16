with x (start_date,end_date)
as (
select 
 [start_date]
,[end_date] =
	dateadd(year,1,start_date) 
from (
	select TOP 1 
	start_date =
		cast(
			cast(year(getdate()) as varchar) 
			+ '-01-01'
			as datetime) 
	--from wea_EDW.DIM.DATE_DIM
 ) tmp

 union all
 
 select 
  dateadd(day,1,start_date)
 ,end_date
 from x
 where
 dateadd(day,1,start_date) < end_date
 )

--SELECT * FROM x
--OPTION (MAXRECURSION 366)

select 
 datename(dw,start_date)
,count(*)
from x
group by
datename(dw,start_date)
OPTION (MAXRECURSION 366)