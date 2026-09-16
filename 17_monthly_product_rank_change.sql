-- Portfolio Query 17: Monthly Product Rank Change (TPC-H)
-- Description:
-- Computes monthly product sales, ranks products within each month,
-- and calculates rank change compared to the previous month.
-- This pipeline demonstrates chained CTEs, window functions,
-- and time-series ranking analysis.

WITH monthly_sales AS (
    SELECT
        l_partkey,
        DATE_TRUNC('month', l_shipdate) AS month,
        SUM(l_quantity) AS units_sold
    FROM lineitem
    GROUP BY l_partkey, month
),

monthly_rank AS (
    SELECT
        l_partkey,
        month,
        units_sold,
        RANK() OVER (
            PARTITION BY month
            ORDER BY units_sold DESC
        ) AS month_rank
    FROM monthly_sales
),

rank_change AS (
    SELECT
        l_partkey,
        month,
        month_rank,
        LAG(month_rank) OVER (
            PARTITION BY l_partkey
            ORDER BY month
        ) AS previous_rank
    FROM monthly_rank
)

SELECT
    p.p_name,
    rc.month,
    rc.month_rank,
    rc.previous_rank,
    (rc.previous_rank - rc.month_rank) AS rank_change
FROM rank_change rc
JOIN part p ON p.p_partkey = rc.l_partkey
WHERE rc.month_rank <= 10
ORDER BY rc.month, rc.month_rank;
