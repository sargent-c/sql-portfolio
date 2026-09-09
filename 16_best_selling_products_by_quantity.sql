-- Portfolio Query 16: Top 10 best-selling products by quantity sold
-- Purpose: Identify the products that sell the most units, supporting inventory
--          planning, demand forecasting, and product strategy.
-- Data source: lineitem (l_quantity, l_partkey), part (p_partkey, p_name)
-- Method: Aggregate units sold per product in a subquery, then join to part to
--         enrich the results with product names.

SELECT
    p.p_partkey AS product_id,
    p.p_name    AS product_name,
    agg.total_units_sold
FROM (
    SELECT
        l_partkey,
        SUM(l_quantity) AS total_units_sold
    FROM lineitem
    GROUP BY l_partkey
) AS agg
JOIN part p
    ON p.p_partkey = agg.l_partkey
ORDER BY agg.total_units_sold DESC
LIMIT 10;
