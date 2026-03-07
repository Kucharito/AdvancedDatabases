select lname, fname, residence, Count(*) as pocet
from Customer
GROUP BY lname, fname, residence

select min(pocet) as min_pocet, max(pocet) as max_pocet
from (
    SELECT COUNT (*) AS pocet
    from Customer
    GROUP BY lname, fname, residence
)t;

select lname, fname, COUNT (*) as pocet
from Customer
GROUP BY lname, fname

select min(pocet) as min_pocet, max(pocet) as max_pocet
from (
    select COUNT(*) as pocet
    from Customer
    GROUP BY lname, fname
)t;

select lname, residence, COUNT(*) as pocet
from Customer
GROUP BY lname, residence

select min(pocet) as min_pocet, max(pocet) as max_pocet
from (
    select COUNT(*) as pocet
    from Customer
    GROUP BY lname, residence
)t;


set statistics time on;
set statistics time off;
set statistics io on;
set statistics io off;
set showplan_text on;
set showplan_text off;

set statistics time on;
set statistics io on;
select *
from Customer
where lname = 'Cooper' and residence = 'Praha' and birthday = '1973-06-15'
option (MAXDOP 1);
set statistics time off;
set statistics io off;

SET SHOWPLAN_TEXT ON;
select *
from Customer
where lname = 'Cooper' and residence = 'Praha' and birthday = '1973-06-15'
option (MAXDOP 1);
SET SHOWPLAN_TEXT OFF;


SET STATISTICS TIME ON;
CREATE INDEX customer_name_res
ON Customer (lname,fname, residence);
SET STATISTICS TIME OFF;

select COUNT(*)
from customer



exec PrintPagesIndex 'customer_name_res';
set statistics time on;
set statistics io on;
select *
from Customer
where lname = 'Cooper' and residence = 'Praha' and birthday = '1973-06-15'
option (MAXDOP 1);
set statistics time off;
set statistics io off;

SET SHOWPLAN_TEXT ON;
select *
from Customer
where lname = 'Cooper' and residence = 'Praha' and birthday = '1973-06-15'
option (MAXDOP 1);
SET SHOWPLAN_TEXT OFF;

SET STATISTICS TIME ON;
CREATE INDEX customer_name_res
    ON Customer (lname,fname, residence);
SET STATISTICS TIME OFF;


select lname, fname, COUNT (*) as pocet
from Customer
GROUP BY lname, fname

select min(pocet) as min_pocet, max(pocet) as max_pocet
from (
         select COUNT(*) as pocet
         from Customer
         GROUP BY lname, fname
     )t;


select lname, fname, COUNT(*) as pocet
from Customer
group by lname, fname
having COUNT(*) = (
    select MIN(pocet)
    from (
             select COUNT(*) pocet
             from Customer
             group by lname, fname
         ) t
);

select lname, fname, COUNT(*) as pocet
from Customer
group by lname, fname
having COUNT(*) = (
    select MAX(pocet)
    from (
             select COUNT(*) pocet
             from Customer
             group by lname, fname
         ) t
);

SET STATISTICS IO ON;
SET STATISTICS TIME ON;

SELECT *
FROM Customer
WHERE lname = 'Weber'
  AND fname = 'Marie'
OPTION (MAXDOP 1);

SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;

SET STATISTICS IO ON;
SET STATISTICS TIME ON;

SELECT *
FROM Customer
WHERE lname = 'Jones'
  AND fname = 'Milan'
OPTION (MAXDOP 1);

SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;

EXEC PrintPagesHeap 'Customer';

EXEC PrintIndexes 'Customer'

EXEC PrintIndexLevelStats 'kuc0396', 'customer', 'customer_name_res';
EXEC PrintPagesIndex 'customer_name_res';

EXEC PrintIndexStats 'kuc0396', 'customer', 'PK__Customer__DC501A0C7F6B410F';

