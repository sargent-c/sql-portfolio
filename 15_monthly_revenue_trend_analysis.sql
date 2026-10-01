-- Portfolio Query 15: Monthly Revenue Trend Analysis (TPC-H)
-- Aggregates revenue at the monthly level and applies a three month moving
-- average to smooth short-term fluctuations and highlight underlying trends.
-- Demonstrates DATE_TRUNC(), window functions, frame clauses, and a
-- multi-stage analytics pipeline.

WITH monthly_revenue AS (
    SELECT
        DATE_TRUNC('month', o.o_orderdate) AS month,
        SUM(l.l_extendedprice * (1 - l.l_discount)) AS total_revenue
    FROM orders o
    JOIN lineitem l
      ON o.o_orderkey = l.l_orderkey
    GROUP BY DATE_TRUNC('month', o.o_orderdate)
), 

revenue_trends AS (
    SELECT
        mr.month,
        ROUND(mr.total_revenue, 2) AS total_revenue,
        ROUND(
            AVG(mr.total_revenue) OVER (
                ORDER BY mr.month
                ROWS BETWEEN 2 PRECEDING 
                         AND CURRENT ROW
            ),
            2
        ) AS three_month_moving_average
    FROM monthly_revenue mr
)

SELECT
    rt.month,
    rt.total_revenue,
    rt.three_month_moving_average
FROM revenue_trends rt
ORDER BY rt.month;