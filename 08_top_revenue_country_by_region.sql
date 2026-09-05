-- Portfolio query 08: Top performing country by region
-- Purpose: Identify the highest-revenue country within each global region
-- Revenue source: lineitem (l_extendedprice * (1 - l_discount))
-- Join path: lineitem → orders → customer → nation → region
-- Method: Aggregate revenue by country, then rank countries within each region 
--         using ROW_NUMBER()

WITH revenue_by_country AS (
    SELECT
        c.c_nationkey,
        ROUND(SUM(l.l_extendedprice * (1 - l.l_discount)), 2) AS total_revenue
    FROM lineitem l
    JOIN orders o
      ON l.l_orderkey = o.o_orderkey
    JOIN customer c
      ON o.o_custkey = c.c_custkey
    GROUP BY c.c_nationkey
),
ranked_countries AS (
    SELECT
        rg.r_name AS region,
        n.n_name AS country,
        r.total_revenue,
        ROW_NUMBER() OVER (
            PARTITION BY rg.r_name
            ORDER BY r.total_revenue DESC) AS country_rank
    FROM revenue_by_country r
    JOIN nation n
      ON n.n_nationkey = r.c_nationkey
    JOIN region rg
      ON n.n_regionkey = rg.r_regionkey
)
SELECT 
    rc.region,
    rc.country AS top_country,
    rc.total_revenue
FROM ranked_countries rc
WHERE rc.country_rank = 1
ORDER BY rc.region;