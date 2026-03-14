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

SELECT lname, fname, residence, COUNT(*) AS pocet
FROM Customer
GROUP BY lname, fname, residence
ORDER BY pocet;

------ulohy 1,2,3

set statistics time on;
set statistics time off;
set statistics io on;
set statistics io off;
set showplan_text on;
set showplan_text off;

--Pro Oracle i SQL Server napište dotaz nad tabulkou Customer s
--projekcí * a selekcí na atributy lname and fname and residence
--vracející minimální počet záznamů výsledku. Pokud je to nutné,
--vypněte paralelizaci dotazu.

set statistics time on;
set statistics io on;
select *
from Customer
where fname='Pavel' and lname = 'Svoboda' and residence = 'Barcelona'
option (MAXDOP 1);
set statistics time off;
set statistics io off;

SET SHOWPLAN_TEXT ON;
select *
from Customer
where fname='Pavel' and lname = 'Svoboda' and residence = 'Barcelona'
option (MAXDOP 1);
SET SHOWPLAN_TEXT OFF;

--6 uloha
SET STATISTICS TIME ON;
CREATE INDEX idx_customer_ln_fn_rs
ON Customer (lname,fname, residence);
SET STATISTICS TIME OFF;

--pocet poloziek
select COUNT(*)
from customer
--pocet blokov indexu
EXEC PrintPagesIndex 'idx_customer_ln_fn_rs';

--zopakovanie
set statistics time on;
set statistics io on;
select *
from Customer
where fname='Pavel' and lname = 'Svoboda' and residence = 'Barcelona'
option (MAXDOP 1);
set statistics time off;
set statistics io off;

SET SHOWPLAN_TEXT ON;
select *
from Customer
where fname='Pavel' and lname = 'Svoboda' and residence = 'Barcelona'
option (MAXDOP 1);
SET SHOWPLAN_TEXT OFF;

--ulhoa 7 s maximalnym poctom záznamov
SELECT lname, fname, residence, COUNT(*) AS pocet
FROM Customer
GROUP BY lname, fname, residence
ORDER BY pocet DESC;

SET STATISTICS TIME ON;
SET STATISTICS IO ON;

SELECT *
FROM Customer
WHERE lname = 'Nováková'
  AND fname = 'Jana'
  AND residence = 'Beroun'
OPTION (MAXDOP 1);

SET STATISTICS TIME OFF;
SET STATISTICS IO OFF;

SET SHOWPLAN_TEXT ON;

SELECT *
FROM Customer
WHERE lname = 'Nováková'
  AND fname = 'Jana'
  AND residence = 'Beroun'
OPTION (MAXDOP 1);

SET SHOWPLAN_TEXT OFF;




--8 ukol
SELECT lname, fname, COUNT(*) AS pocet
FROM Customer
GROUP BY lname, fname
ORDER BY pocet ASC;

SET STATISTICS TIME ON;
SET STATISTICS IO ON;

SELECT *
FROM Customer
WHERE lname = 'Jones'
  AND fname = 'Milan'
OPTION (MAXDOP 1);

SET STATISTICS TIME OFF;
SET STATISTICS IO OFF;

SET SHOWPLAN_TEXT ON;

SELECT *
FROM Customer
WHERE lname = 'Jones'
  AND fname = 'Milan'
OPTION (MAXDOP 1);

SET SHOWPLAN_TEXT OFF;


--ukol 9
SET STATISTICS TIME ON;
SET STATISTICS IO ON;

SELECT lname, fname
FROM Customer
WHERE lname = 'Cooper'
  AND fname = 'John'
OPTION (MAXDOP 1);

SET STATISTICS TIME OFF;
SET STATISTICS IO OFF;

SET SHOWPLAN_TEXT ON;

SELECT lname, fname
FROM Customer
WHERE lname = 'Cooper'
  AND fname = 'John'
OPTION (MAXDOP 1);

SET SHOWPLAN_TEXT OFF;


--10 ukol
SELECT lname, residence, COUNT(*) AS pocet
FROM Customer
GROUP BY lname, residence
ORDER BY pocet ASC;

SET STATISTICS TIME ON;
SET STATISTICS IO ON;

SELECT *
FROM Customer
WHERE lname = 'Nováková'
  AND residence = 'Bratislava'
OPTION (MAXDOP 1);

SET STATISTICS TIME OFF;
SET STATISTICS IO OFF;

SET SHOWPLAN_TEXT ON;

SELECT *
FROM Customer
WHERE lname = 'Nováková'
  AND residence = 'Bratislava'
OPTION (MAXDOP 1);

SET SHOWPLAN_TEXT OFF;

--ukol 11
--velksot tabulky
EXEC PrintPagesHeap 'Customer';

--vsetky index
EXEC PrintIndexes 'Customer';

EXEC PrintPagesIndex 'idx_customer_ln_fn_rs';
EXEC PrintPagesIndex 'PK__Customer__DC501A0C7F6B410F';

EXEC PrintIndexStats 'kuc0396', 'customer', 'idx_customer_ln_fn_rs';
EXEC PrintIndexStats 'kuc0396', 'customer', 'PK__Customer__DC501A0C7F6B410F';















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

