-- Portfolio Query 18: Active Customers Pipeline (TPC-H)
-- Identifies customers who have placed at least one order
-- and computes basic order metrics.

WITH customers AS (
    SELECT
        c_custkey,
        c_name,
        c_acctbal
    FROM customer
),

active_customers AS (
    SELECT
        c.c_custkey,
        c.c_name,
        c.c_acctbal
    FROM customers c
    WHERE EXISTS (
        SELECT 1
        FROM orders o
        WHERE o.o_custkey = c.c_custkey
    )
),

customer_order_metrics AS (
    -- Compute order-level metrics for active customers
    SELECT
        o.o_custkey,
        COUNT(*) AS total_orders,
        MIN(o.o_orderdate) AS first_order_date,
        MAX(o.o_orderdate) AS most_recent_order_date
    FROM orders o
    GROUP BY o.o_custkey
),

final AS (
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
)

SELECT *
FROM final
ORDER BY total_orders DESC;
