-- Portfolio Query 15: Products that have never been sold (with supplier info)
-- Purpose: Identify parts with no sales activity and list their suppliers for
--          inventory review and supplier outreach.
-- Data source: part, lineitem, partsupp, supplier
-- Method: LEFT JOIN part to lineitem and filter for parts with no matching
--         lineitem rows (l_partkey IS NULL). Then enrich with supplier info
--         via partsupp and supplier.
-- Note: TPC‑H guarantees that every part appears in at least one lineitem, so 
--       this query returns zero rows. The logic is correct and demonstrates the 
--       standard LEFT JOIN anti‑join pattern.

SELECT
    p.p_partkey AS product_id,
    p.p_name AS product_name,
    s.s_name AS supplier_name,
    s.s_address AS supplier_address,
    s.s_phone AS supplier_phone
FROM part p
LEFT JOIN lineitem l
    ON p.p_partkey = l.l_partkey
LEFT JOIN partsupp ps
    ON p.p_partkey = ps.ps_partkey
LEFT JOIN supplier s
    ON ps.ps_suppkey = s.s_suppkey
WHERE l.l_partkey IS NULL
ORDER BY p.p_partkey;
