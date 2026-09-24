-- Portfolio Query 03: Countries by revenue
-- Purpose: rank all countries by total revenue generated
-- Revenue source: lineitem (l_extendedprice * (1 - l_discount))
-- Join path: lineitem → orders → customer → nation
-- Method: Aggregate revenue by country, then apply RANK() to rank 
--         countries by revenue

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
ranked_revenue AS (
    SELECT
        n.n_name AS country,
        r.total_revenue,
        RANK() OVER (ORDER BY r.total_revenue DESC) AS revenue_rank
    FROM revenue_by_country r
    JOIN nation n
      ON n.n_nationkey = r.c_nationkey
)
SELECT *
FROM ranked_revenue
ORDER BY revenue_rank;