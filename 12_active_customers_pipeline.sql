-- Portfolio Query 12: Active Customers Pipeline (TPC-H)
-- Identifies customers who have placed at least one order
-- and computes basic order metrics.

WITH active_customers AS (
    SELECT
        c.c_custkey,
        c.c_name,
        c.c_acctbal
    FROM customer c
    WHERE EXISTS (
        SELECT 1
        FROM orders o
        WHERE o.o_custkey = c.c_custkey
    )
),

customer_order_metrics AS (
    SELECT
        o.o_custkey,
        COUNT(*) AS total_orders,
        MIN(o.o_orderdate) AS first_order_date,
        MAX(o.o_orderdate) AS most_recent_order_date
    FROM orders o
    GROUP BY o.o_custkey
)

SELECT
    ac.c_custkey,
    ac.c_name,
    ac.c_acctbal,
    com.total_orders,
    com.first_order_date,
    com.most_recent_order_date
FROM active_customers ac
JOIN customer_order_metrics com
    ON ac.c_custkey = com.o_custkey
ORDER BY total_orders DESC;