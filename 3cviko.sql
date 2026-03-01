
SET STATISTICS IO ON;
SET SHOWPLAN_TEXT ON;
SET SHOWPLAN_TEXT OFF;
SET SHOWPLAN_ALL ON;
SET SHOWPLAN_ALL OFF;

select * from Customer
where birthday =  '2000-01-01';

exec PrintPagesHeap 'Customer';

---------------------------------------

SET STATISTICS IO ON;
SET STATISTICS TIME ON;
SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;

select * from Product
where unit_price between 1300000 and 1800000;

select * from OrderItem
where orderitem.unit_price between 1 and 300;

select * from OrderItem
where orderitem.unit_price between 1 and 300
    OPTION (MAXDOP 1);

exec PrintPagesHeap 'OrderItem';

-----------------------------

SET STATISTICS IO ON;
SET STATISTICS TIME ON;
SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;

select * from Customer
where fname = 'Jana' and lname='Pokorná' and residence = 'Berlin';
-- 67

exec PrintPagesHeap 'Customer';


--
SELECT top (100) *
from OrderItem;

--overenie  ze ide o heap scan
SET SHOWPLAN_ALL ON;
SELECT top (100) *
from OrderItem
SET SHOWPLAN_ALL OFF;

--zistit pocet zaznamov vysledku dotazu
select count(*)
from(
    select top (100) *
    from OrderItem
)t;

select count(*)
from OrderItem

-- ====================================================================
-- SERIAL VERSION (MAXDOP 1) - Vynutene seriove vykonavanie
-- ====================================================================

--textovy QEP a graficky vraj cez explain plan
SET SHOWPLAN_TEXT ON;
SELECT TOP(100)*
FROM OrderItem
OPTION (MAXDOP 1);
SET SHOWPLAN_TEXT OFF;

-- zistit IO cost a porovnat s poctom blokov haldy
SET STATISTICS IO ON;
SELECT TOP(100)*
FROM OrderItem
OPTION (MAXDOP 1);
SET STATISTICS IO OFF;

EXEC PrintPagesHeap 'OrderItem';

--zistit cas provedeni dotazu
SET STATISTICS TIME ON;
SELECT TOP (100) *
FROM OrderItem
OPTION (MAXDOP 1);
SET STATISTICS TIME OFF;

-- ====================================================================
-- PARALLEL VERSION (MAXDOP 8) - Vynutene paralelne vykonavanie
-- ====================================================================

--textovy QEP a graficky vraj cez explain plan
SET SHOWPLAN_TEXT ON;
SELECT TOP(100)*
FROM OrderItem
OPTION (MAXDOP 8);
SET SHOWPLAN_TEXT OFF;

-- zistit IO cost a porovnat s poctom blokov haldy
SET STATISTICS IO ON;
SELECT TOP(100)*
FROM OrderItem
OPTION (MAXDOP 8);
SET STATISTICS IO OFF;

EXEC PrintPagesHeap 'OrderItem';

--zistit cas provedeni dotazu
SET STATISTICS TIME ON;
SELECT TOP (100) *
FROM OrderItem
OPTION (MAXDOP 8);
SET STATISTICS TIME OFF;

-- ====================================================================
-- ÚLOHA: Zmazať každý štvrtý záznam z tabuľky OrderItem
-- ====================================================================

WITH NumberedRows AS (
    SELECT *, ROW_NUMBER() OVER (ORDER BY ido, idp) AS RowNum
    FROM OrderItem
)
DELETE FROM NumberedRows
WHERE RowNum % 4 = 0;
-- ====================================================================
-- Krok 2: Zistiť počet záznamov výsledku dotazu
-- ====================================================================

-- Dotaz na TOP 100 záznamov
SELECT TOP (100) *
FROM OrderItem;

-- Počet záznamov výsledku dotazu (TOP 100)
SELECT COUNT(*) AS PocetZaznamovVysledku
FROM (
    SELECT TOP (100) *
    FROM OrderItem
) AS Vysledok;

-- ====================================================================
-- Krok 3: Zistiť počet záznamov v tabulke a počet blokov haldy
-- ====================================================================

-- Celkový počet záznamov v tabulke OrderItem
SELECT COUNT(*) AS CelkovyPocetZaznamov
FROM OrderItem;

-- Počet blokov (pages) haldy
EXEC PrintPagesHeap 'OrderItem';

-- ====================================================================
-- Krok 4: Zistiť IO cost
-- ====================================================================

SET STATISTICS IO ON;
SELECT TOP (100) *
FROM OrderItem;
SET STATISTICS IO OFF;

-- ====================================================================
-- Krok 5: Zistiť čas vykonania dotazu (CPU time, elapsed time) v ms
-- ====================================================================

SET STATISTICS TIME ON;
SELECT TOP (100) *
FROM OrderItem;
SET STATISTICS TIME OFF;

-- ====================================================================
-- KOMPLETNÉ MERANIE - Všetko naraz
-- ====================================================================

SET STATISTICS IO ON;
SET STATISTICS TIME ON;

SELECT TOP (100) *
FROM OrderItem;

SET STATISTICS TIME OFF;
SET STATISTICS IO OFF;

-- ====================================================================
-- FYZICKÉ MAZANIE ZÁZNAMOV (Physical Delete)
-- ====================================================================
-- Po DELETE zostávajú v tabuľke prázdne bloky (fragmentácia)
-- Fyzické mazanie = odstránenie fragmentácie a uvoľnenie priestoru

-- REBUILD haldy (odporúčané pre haldy)
ALTER TABLE OrderItem REBUILD;

-- ====================================================================
-- PO FYZICKOM MAZANÍ - Opätovné meranie všetkých údajov
-- ====================================================================

-- Krok 1: Počet záznamov výsledku dotazu (TOP 100)
SELECT TOP (100) *
FROM OrderItem;

SELECT COUNT(*) AS PocetZaznamovVysledku_PoFyzickejDelete
FROM (
    SELECT TOP (100) *
    FROM OrderItem
) AS Vysledok;

-- Krok 2: Celkový počet záznamov v tabulke
SELECT COUNT(*) AS CelkovyPocetZaznamov_PoFyzickejDelete
FROM OrderItem;

-- Krok 3: Počet blokov haldy PO fyzickom mazaní
EXEC PrintPagesHeap 'OrderItem';


-- Krok 4: IO cost PO fyzickom mazaní
SET STATISTICS IO ON;
SELECT TOP (100) *
FROM OrderItem;
SET STATISTICS IO OFF;

-- Krok 5: Čas vykonania PO fyzickom mazaní (CPU time, elapsed time)
SET STATISTICS TIME ON;
SELECT TOP (100) *
FROM OrderItem;
SET STATISTICS TIME OFF;

-- ====================================================================
-- KOMPLETNÉ MERANIE PO FYZICKOM MAZANÍ - Všetko naraz
-- ====================================================================

SET STATISTICS IO ON;
SET STATISTICS TIME ON;

SELECT TOP (100) *
FROM OrderItem;

SET STATISTICS TIME OFF;
SET STATISTICS IO OFF;

-- ====================================================================
-- POROVNANIE PRED a PO fyzickom mazaní:
-- ====================================================================
-- PRED fyzickým mazaním:
--   - Viac blokov (pages) kvôli fragmentácii
--   - Vyššie IO cost (logical reads)
--   - Dlhší čas vykonania
--   - Nižšie avg_page_space_used_in_percent
--
-- PO fyzickom mazaní (REBUILD):
--   - Menej blokov - kompaktnejšia tabuľka
--   - Nižšie IO cost
--   - Kratší čas vykonania
--   - Vyššie avg_page_space_used_in_percent (lepšie využitie blokov)
-- ====================================================================
