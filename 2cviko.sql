-- ============================================
-- PROCEDURE DEFINITIONS
-- ============================================

------------------------------
-- PrintIndexes
------------------------------
create or alter procedure PrintIndexes
    @table VARCHAR(30)
    as
select i.name as indexName
from sys.indexes i
         inner join sys.tables t on t.object_id = i.object_id
where T.Name = @table and i.name is not null;
go

------------------------------
-- PrintPagesIndex
------------------------------
create or alter procedure PrintPagesIndex
    @index varchar(30)
    as
select
    i.name as IndexName,
    p.rows as ItemCounts,
    sum(a.total_pages) as TotalPages,
    round(cast(sum(a.total_pages) * 8 as float) / 1024, 1)
        as TotalPages_MB,
    sum(a.used_pages) as UsedPages,
    round(cast(sum(a.used_pages) * 8 as float) / 1024, 1)
        as UsedPages_MB
from sys.indexes i
         inner join sys.partitions p
                    on i.object_id = p.OBJECT_ID and i.index_id = p.index_id
         inner join sys.allocation_units a
                    on p.partition_id = a.container_id
where i.name = @index
group by i.name, p.Rows
order by i.name
    go

------------------------------
-- PrintIndexStats
------------------------------
create or alter procedure PrintIndexStats @user varchar(30), @table varchar(30), @index varchar(30)
    as
select i.name, s.index_depth - 1 as height,
       sum(s.page_count) as page_count
from sys.dm_db_index_physical_stats(DB_ID(@user),
                                    OBJECT_ID(@table), NULL, NULL , 'DETAILED') s
         join sys.indexes i
              on s.object_id=i.object_id and s.index_id=i.index_id
where name=@index
group by i.name, s.index_depth
    go

------------------------------
-- PrintIndexLevelStats
------------------------------
create or alter procedure PrintIndexLevelStats @user varchar(30), @table varchar(30), @index varchar(30)
    as
select s.index_level as level, s.page_count,
       s.record_count, s.avg_record_size_in_bytes
                     as avg_record_size,
       round(s.avg_page_space_used_in_percent,1)
                     as page_utilization,
       round(s.avg_fragmentation_in_percent,2) as avg_frag
from sys.dm_db_index_physical_stats(DB_ID(@user),
                                    OBJECT_ID(@table), NULL, NULL , 'DETAILED') s
         join sys.indexes i
              on s.object_id=i.object_id and s.index_id=i.index_id
where name=@index
    go

-- ============================================
-- PROCEDURE EXECUTIONS
-- ============================================

exec PrintIndexes 'Customer';

exec PrintPagesIndex 'PK__Customer__DC501A0CEB937419';

exec PrintIndexStats 'kra28', 'Customer', 'PK__Customer__DC501A0CBAEBDD6E'
exec PrintIndexLevelStats 'kra28', 'Customer', 'PK__Customer__DC501A0CBAEBDD6E'

--zistenie automaticky vytvorenych indexov pre tabulky
exec PrintIndexes 'Store';
exec PrintIndexes 'Customer';
exec PrintIndexes'OrderItem';


exec PrintPagesIndex 'PK__Store__9DBB2CF2D5C7E9F9';
exec PrintPagesIndex 'PK__Customer__DC501A0CEB937419';
exec PrintPagesIndex 'pk_orderitem';



