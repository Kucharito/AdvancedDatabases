exec PrintPagesHeap 'OrderItem';

create or alter procedure PrintPagesClusterTable
@tableName varchar(30)
as
    exec PrintPages @tableName, 1

    create clustered index OrderItem on OrderItem(idOrder, idProduct);

    exec PrintPagesClusterTable 'OrderItem';

    exec PrintPagesHeap 'OrderItem';

--------------------------------

SELECT
    t.NAME AS TableName, i.name, i.type_desc, p.rows AS RowCounts,
    a.total_pages AS TotalPages, a.used_pages AS UsedPages
FROM sys.tables t
         INNER JOIN
     sys.indexes i ON t.OBJECT_ID = i.object_id
         INNER JOIN
     sys.partitions p ON i.object_id = p.OBJECT_ID AND
                         i.index_id = p.index_id
         INNER JOIN
     sys.allocation_units a ON p.partition_id = a.container_id
WHERE t.NAME = 'OrderItem' and p.index_id > 1

----------------------------------

select i.name, s.index_level as level, s.page_count, s.record_count,
       s.avg_record_size_in_bytes as avg_record_size,
       round(s.avg_page_space_used_in_percent,1) as page_utilization,
       round(s.avg_fragmentation_in_percent,2) as avg_frag
from sys.dm_db_index_physical_stats(DB_ID(N'kra28'), OBJECT_ID(N'OrderItem'), NULL, NULL , 'DETAILED') s
         join sys.indexes i on s.object_id=i.object_id and s.index_id=i.index_id
-- where name='PK__Customer__D058768742B8AE8D'

    alter table OrderItem rebuild;

    drop index PK__OrderIte__CD443163B0970E7F on OrderItem;

----------------------------------------

    set statistics time on;
    set statistics time off;
    set statistics io on;
    set statistics io off;
    set showplan_text on;
    set showplan_text off;

select * from OrderItem
where idOrder = 1235; -- 11 resp. 20 zaznamu

select * from OrderItem
where unit_price between 10000 and 10001
option (maxdop 1);

----------------------------------------

    create index OrderItem_unitprice on OrderItem(unit_price);

    exec PrintPagesIndex 'OrderItem';

    exec PrintPagesClusterTable 'OrderItem';
    exec PrintPagesIndex 'OrderItem_unitprice';

delete from OrderItem where idOrder % 2 = 0;

    alter table OrderItem rebuild;

----------------------------------------

select * from OrderItem where idOrder=1;

SELECT qs.execution_count,
       SUBSTRING(qt.text,qs.statement_start_offset/2 +1,
                 (CASE WHEN qs.statement_end_offset = -1
                           THEN LEN(CONVERT(nvarchar(max), qt.text)) * 2
                       ELSE qs.statement_end_offset end -
                  qs.statement_start_offset
                     )/2
       ) AS query_text,
       qs.total_worker_time/qs.execution_count AS avg_cpu_time, qp.dbid, qt.text
--   qs.plan_handle, qp.query_plan
FROM sys.dm_exec_query_stats AS qs
         CROSS APPLY sys.dm_exec_query_plan(qs.plan_handle) as qp
         CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) as qt
where qp.dbid=DB_ID() and qs.execution_count > 10
--  and query_text LIKE '%SELECT * FROM [OrderItem]%'
ORDER BY avg_cpu_time DESC;


    -- Prva uloha
--Počet blokov HALDY (Customer)

exec PrintPagesHeap Customer;

--nazov indexu
select name
from sys.indexes
where object_id = object_id('Customer')
    and is_primary_key = 1;

--pocet blokov indexu na pk idc
exec PrintPagesIndex PK__Customer__DC501A0C7F6B410F;

-- Druha uloha
--kontrola ci mam haldu
select name, type_desc
from sys.indexes
where object_id = object_id('Customer')

--vytvorenie clustered index
create clustered index Customer_clustered
ON Customer(idc);


SELECT name, type_desc
FROM sys.indexes
WHERE object_id = OBJECT_ID('Customer');

exec PrintPagesClusterTable 'Customer';
-- halda uz nema zaznamy, vsetko je v indexe
exec PrintPagesHeap 'Customer';

--uloha 3 porovnanie vykonania dotazu s haldou a s clustered indexom

--uloha 4 rebuild , doslo k redukcii poctu stranok ? preco
ALTER TABLE Customer REBUILD;

exec PrintPagesClusterTable 'Customer';

-- 5 uloha
select *
from Customer
where idc = 123;

--cas a io cost
set statistics time on;
set statistics io on;
select *
from Customer
where idc = 123;
set statistics time off;
set statistics io off;

--showplan vykonania dotazu
set showplan_text on;
select *
from Customer
where idc = 123;
set showplan_text off;


--uloha 6
set statistics time on;
set statistics io on;
SELECT lname, fname, residence
FROM Customer
WHERE lname = 'Jones'
  AND fname = 'Milan'
  and residence = 'Berlin';
set statistics time off;
set statistics io off;

set showplan_text on;
SELECT lname, fname, residence
FROM Customer
WHERE lname = 'Jones'
  AND fname = 'Milan'
  and residence = 'Berlin';
set showplan_text off;

--pre clustered
    set statistics time on;
    set statistics io on;
SELECT lname, fname
FROM Customer
WHERE lname = 'Jones'
  AND fname = 'Milan'
    set statistics time off;
    set statistics io off;

    set showplan_text on;
select lname, fname
from Customer
where lname = 'Jones'
  and fname = 'Milan';
    set showplan_text off;

--uloha 7
CREATE INDEX customer_name_res
ON Customer(lname, fname, residence);

CREATE INDEX customer_name_res_ct
ON Customer_Ct(lname, fname, residence);

    set statistics time on;
    set statistics io on;
SELECT *
FROM Customer
WHERE lname = 'Jones'
  AND fname = 'Milan'
  and residence = 'Berlin';
    set statistics time off;
    set statistics io off;

    set showplan_text on;
SELECT *
FROM Customer_Ct
WHERE lname = 'Jones'
  AND fname = 'Milan'
  and residence = 'Berlin';
    set showplan_text off;

    -- pre haldu

--uloha 9
-- uloha 9
    drop index if exists customer_name_idc on Customer;
go

create index customer_name_idc
    on Customer(lname, fname)
    include (idc);
go

set statistics time on;
set statistics io on;

select idc
from Customer
WHERE lname = 'Jones'
  AND fname = 'Milan'
  and residence = 'Berlin';

set statistics io off;
set statistics time off;
go

set showplan_text on;
go

select idc
from Customer_ct
where lname = 'Jones'
  and fname = 'Milan'
    and residence = 'Berlin';

go
set showplan_text off;
go

-- to je pre vytvorenie tabulky a clustered index
select * into customer_ct
from Customer

--
create clustered index idx_customer_idc on customer_ct(idc);