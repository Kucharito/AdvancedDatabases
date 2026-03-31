select * from
    (
        SELECT qs.execution_count,
               SUBSTRING(qt.text,qs.statement_start_offset/2 +1,
                         (CASE WHEN qs.statement_end_offset = -1
                                   THEN LEN(CONVERT(nvarchar(max), qt.text)) * 2
                               ELSE qs.statement_end_offset end -
                          qs.statement_start_offset
                             )/2
               ) AS query_text,
               qs.total_worker_time/qs.execution_count AS avg_cpu_time, qp.dbid
        --, qt.text, qs.plan_handle, qp.query_plan
        FROM sys.dm_exec_query_stats AS qs
                 CROSS APPLY sys.dm_exec_query_plan(qs.plan_handle) as qp
                 CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) as qt
        where qp.dbid=DB_ID() and qs.execution_count > 5
    ) t
where query_text like 'select * from%'
order by avg_cpu_time desc;

set statistics io on;
set statistics time on;
set showplan_text on;

set statistics io off;
set statistics time off;
set showplan_text off;

select *
from OrderItem
inner join Product on OrderItem.idp = Product.idp
where Product.unit_price between 20000000 and 20002000
option (maxdop 1);


--1. iteracia
    -- 1.cast Selekcia na product
select *
from Product
where unit_price between 20000000 and 20002000;
--logical reads: 507
--Table Scan(OBJECT:([KUC0396].[dbo].[Product]), WHERE:([KUC0396].[dbo].[Product].[unit_price]>=(20000000) AND [KUC0396].[dbo].[Product].[unit_price]<=(20002000)))
--cpu time 16 ms, elapsed time 17ms

    --2. cast samotny join
select *
from OrderItem
inner join Product on OrderItem.idp = Product.idp;
--Hash Match(Inner Join, HASH:([KUC0396].[dbo].[Product].[idp])=([KUC0396].[dbo].[OrderItem].[idp]))
--Table Scan(OBJECT:([KUC0396].[dbo].[Product]))
--Table Scan(OBJECT:([KUC0396].[dbo].[OrderItem]))
--logical reads Product 1534	logical reads OrderItem 2
--16 ms cpu time, 5 ms elapsed time


    --3. cast cely dotaz
select *
from OrderItem
inner join Product on OrderItem.idp = Product.idp
where Product.unit_price between 20000000 and 20002000
option (maxdop 1);
--Hash Match(Inner Join, HASH:([KUC0396].[dbo].[Product].[idp])=([KUC0396].[dbo].[OrderItem].[idp])DEFINE:([Opt_Bitmap1007]))
--Table Scan(OBJECT:([KUC0396].[dbo].[Product]),  WHERE:([KUC0396].[dbo].[Product].[unit_price]>=(20000000) AND [KUC0396].[dbo].[Product].[unit_price]<=(20002000)))
--Table Scan(OBJECT:([KUC0396].[dbo].[OrderItem]),  WHERE:(PROBE([Opt_Bitmap1007],[KUC0396].[dbo].[OrderItem].[idp])))
-- IO cost	logical reads Product 507	Logical Reads Orderitem 17922
--CPU time	375 ms	elapsed time 377 ms

--selektivita
select
    cast(count(case when Product.unit_price between 20000000 and 20002000 then 1 end) as float)
        / count(*) * 100
from Product;
--0.002



------------------------------------------------------------
-- Iteracia 2 - index na Product(price, idp)
------------------------------------------------------------
set statistics io on;
set statistics time on;
set showplan_text on;

set statistics io off;
set statistics time off;
set showplan_text off;
CREATE INDEX product_price_idp on Product(unit_price, idp);


select *
from OrderItem
inner join Product on OrderItem.idp = Product.idp
where Product.unit_price between 20000000 and 20002000
option (maxdop 1);

select
    count(*) as result_rows,
    (select count(*) from OrderItem) as total_orderitems,
    cast(count(*) as float) / (select count(*) from OrderItem) * 100 as result_selectivity_percent
from OrderItem oi
         inner join Product p on oi.idp = p.idp
where p.unit_price between 20000000 and 20002000;
--0.0025

-- Hash Match(Inner Join, HASH:([KUC0396].[dbo].[Product].[idp])=([KUC0396].[dbo].[OrderItem].[idp])DEFINE:([Opt_Bitmap1007]))
--Nested Loops(Inner Join, OUTER REFERENCES:([Bmk1003]))
--|    --Index Seek(OBJECT:([KUC0396].[dbo].[Product].[product_price_idp]), SEEK:([KUC0396].[dbo].[Product].[unit_price] >= (20000000) AND [KUC0396].[dbo].[Product].[unit_price] <= (20002000)) ORDERED FORWARD)
--|    |--RID Lookup(OBJECT:([KUC0396].[dbo].[Product]), SEEK:([Bmk1003]=[Bmk1003]) LOOKUP ORDERED FORWARD)
--|--Table Scan(OBJECT:([KUC0396].[dbo].[OrderItem]),  WHERE:(PROBE([Opt_Bitmap1007],[KUC0396].[dbo].[OrderItem].[idp])))
--IO cost		logical reads 4	logical reads 17922
--CPU time		375 ms	384 ms



------------------------------------------------------------
-- Iteracia 3 - index na OrderItem(idp)
------------------------------------------------------------

set statistics io on;
set statistics time on;
set showplan_text on;

set statistics io off;
set statistics time off;
set showplan_text off;
create index orderitem_idp on OrderItem(idp);
go
select *
from OrderItem
         inner join Product on OrderItem.idp = Product.idp
where Product.unit_price between 20000000 and 20002000
option (maxdop 1);


/*|--Nested Loops(Inner Join, OUTER REFERENCES:([Bmk1000], [Expr1008]) WITH UNORDERED PREFETCH)
       |--Nested Loops(Inner Join, OUTER REFERENCES:([KUC0396].[dbo].[Product].[idp]))
       |    |--Nested Loops(Inner Join, OUTER REFERENCES:([Bmk1003]))
       |    |    |--Index Seek(OBJECT:([KUC0396].[dbo].[Product].[product_price_idp]), SEEK:([KUC0396].[dbo].[Product].[unit_price] >= (20000000) AND [KUC0396].[dbo].[Product].[unit_price] <= (20002000)) ORDERED FORWARD)
       |    |    |--RID Lookup(OBJECT:([KUC0396].[dbo].[Product]), SEEK:([Bmk1003]=[Bmk1003]) LOOKUP ORDERED FORWARD)
       |    |--Index Seek(OBJECT:([KUC0396].[dbo].[OrderItem].[orderitem_idp]), SEEK:([KUC0396].[dbo].[OrderItem].[idp]=[KUC0396].[dbo].[Product].[idp]) ORDERED FORWARD)
       |--RID Lookup(OBJECT:([KUC0396].[dbo].[OrderItem]), SEEK:([Bmk1000]=[Bmk1000]) LOOKUP ORDERED FORWARD)
*/

--IO cost		Logical reads Product 4	logical reads OrderItem 110
-- CPU time		0 ms	1 ms

--AVG CPU time 0.685 ms


----------------------------------------------------------------
-- ULOHA 2
-- count(*) a sum(OrderItem.quantity)
----------------------------------------------------------------

------------------------------------------------------------
-- Iteracia 1 - bez dalsich zmien
------------------------------------------------------------

set statistics io on;
set statistics time on;
set showplan_text on;

set statistics io off;
set statistics time off;
set showplan_text off;

select count(*) as item_count,
       sum(oi.quantity) as total_quantity
from OrderItem oi
         inner join Product p on oi.idp = p.idp
where p.unit_price between 20000000 and 20002000
option (maxdop 1);

select
    count(*) as selected_products,
    (select count(*) from Product) as total_products,
    cast(count(*) as float) / (select count(*) from Product) * 100 as selectivity_percent
from Product
where unit_price between 20000000 and 20002000;
-- 0.002
--  |--Compute Scalar(DEFINE:([Expr1004]=CONVERT_IMPLICIT(int,[Expr1015],0), [Expr1005]=CASE WHEN [Expr1015]=(0) THEN NULL ELSE [Expr1016] END))
--|--Stream Aggregate(DEFINE:([Expr1015]=Count(*), [Expr1016]=SUM([KUC0396].[dbo].[OrderItem].[quantity] as [oi].[quantity])))
--            |--Nested Loops(Inner Join, OUTER REFERENCES:([Bmk1000], [Expr1014]) WITH UNORDERED PREFETCH)
--                 |--Nested Loops(Inner Join, OUTER REFERENCES:([p].[idp]))
--                 |    |--Index Seek(OBJECT:([KUC0396].[dbo].[Product].[product_price_idp] AS [p]), SEEK:([p].[unit_price] >= (20000000) AND [p].[unit_price] <= (20002000)) ORDERED FORWARD)
--                 |    |--Index Seek(OBJECT:([KUC0396].[dbo].[OrderItem].[orderitem_idp] AS [oi]), SEEK:([oi].[idp]=[KUC0396].[dbo].[Product].[idp] as [p].[idp]) ORDERED FORWARD)
--                 |--RID Lookup(OBJECT:([KUC0396].[dbo].[OrderItem] AS [oi]), SEEK:([Bmk1000]=[Bmk1000]) LOOKUP ORDERED FORWARD)
--       IO cost	logical reads orderitem 110	logical reads prodcut 2
--CPU time	0 ms	0ms

--AVG CPU time po 1 iteracii 		0.685 ms


------------------------------------------------------------
-- Iteracia 2 - pokryvajuci index pre OrderItem
------------------------------------------------------------
create index orderitem_idp_include_quantity
    on OrderItem(idp) include(quantity);
go


select count(*) as item_count,
       sum(oi.quantity) as total_quantity
from OrderItem oi
         inner join Product p on oi.idp = p.idp
where p.unit_price between 20000000 and 20002000
option (maxdop 1);

select
    count(*) as result_rows,
    (select count(*) from OrderItem) as total_orderitems,
    cast(count(*) as float) / (select count(*) from OrderItem) * 100 as selectivity_percent
from OrderItem oi
         inner join Product p on oi.idp = p.idp
where p.unit_price between 20000000 and 20002000;
--0.00205

/*QEP	  |--Compute Scalar(DEFINE:([Expr1004]=CONVERT_IMPLICIT(int,[Expr1013],0), [Expr1005]=CASE WHEN [Expr1013]=(0) THEN NULL ELSE [Expr1014] END))
|--Stream Aggregate(DEFINE:([Expr1013]=Count(*), [Expr1014]=SUM([KUC0396].[dbo].[OrderItem].[quantity] as [oi].[quantity])))
	            |--Nested Loops(Inner Join, OUTER REFERENCES:([p].[idp]))
	                 |--Index Seek(OBJECT:([KUC0396].[dbo].[Product].[product_price_idp] AS [p]), SEEK:([p].[unit_price] >= (20000000) AND [p].[unit_price] <= (20002000)) ORDERED FORWARD)
	                 |--Index Seek(OBJECT:([KUC0396].[dbo].[OrderItem].[orderitem_idp_include_quantity] AS [oi]), SEEK:([oi].[idp]=[KUC0396].[dbo].[Product].[idp] as [p].[idp]) ORDERED FORWARD)
*/
/*
 IO cost	6	2
CPU time	0	0

AVG CPU time po 1 iteracii 		0,117 ms


 */

go

declare @i int = 0;
while @i < 10
    begin
        select count(*) as item_count,
               sum(oi.quantity) as total_quantity
        from OrderItem oi
                 inner join Product p on oi.idp = p.idp
        where p.unit_price between 20000000 and 20002000
        option (maxdop 1);

        set @i = @i + 1;
    end
go

select *
from
    (
        SELECT qs.execution_count,
               SUBSTRING(qt.text,qs.statement_start_offset/2 +1,
                         (CASE WHEN qs.statement_end_offset = -1
                                   THEN LEN(CONVERT(nvarchar(max), qt.text)) * 2
                               ELSE qs.statement_end_offset end -
                          qs.statement_start_offset
                             )/2
               ) AS query_text,
               qs.total_worker_time / qs.execution_count AS avg_cpu_time,
               qp.dbid
        FROM sys.dm_exec_query_stats AS qs
                 CROSS APPLY sys.dm_exec_query_plan(qs.plan_handle) as qp
                 CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) as qt
        WHERE qp.dbid = DB_ID()
          AND qs.execution_count > 5
    ) t
where query_text like '%count(*)%'
  and query_text like '%sum(oi.quantity)%'
  and query_text like '%from OrderItem oi%'
  and query_text like '%inner join Product p%'
  and query_text like '%unit_price between 20000000 and 20002000%'
order by avg_cpu_time desc;




----------------------------------------------------------------
-- Cleanup
----------------------------------------------------------------

drop index orderitem_idp_include_quantity on OrderItem;
drop index orderitem_idp on OrderItem;
drop index product_price_idp on Product;
go

select count(*) from Product as p

select count(*) from Product as p
where p.unit_price between 20000000 AND 20002000
--2/100000

SELECT count(*) FROM OrderItem oi
                        JOIN Product p ON oi.idp = p.idp
WHERE p.unit_price BETWEEN 20000000 AND 20002000
option (maxdop 1);

SELECT count(*) FROM OrderItem oi
                        JOIN Product p ON oi.idp = p.idp
option (maxdop 1);
--103/5000000