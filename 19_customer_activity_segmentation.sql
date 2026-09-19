-- Portfolio Query 19: Customer Activity Segmentation (TPC-H)
-- Segments customers as Active or Dormant using EXISTS and NOT EXISTS
-- and enriches the results with customer-level order metrics.

WITH active_customers AS (
    SELECT
        c.c_custkey,
        c.c_name,
        c.c_acctbal
    FROM customer c        
    WHERE EXISTS (
        SELECT 1
        FROM orders o
        WHERE c.c_custkey = o.o_custkey)
),

dormant_customers AS (
    SELECT
        c.c_custkey,
        c.c_name,
        c.c_acctbal
    FROM customer c        
    WHERE NOT EXISTS (
        SELECT 1
        FROM orders o
        WHERE c.c_custkey = o.o_custkey)
),

all_customers AS (
    SELECT
        ac.c_custkey,
        ac.c_name,
        ac.c_acctbal,
        'Active' AS customer_status
    FROM active_customers ac
        
    UNION ALL

    SELECT
        dc.c_custkey,
        dc.c_name,
        dc.c_acctbal,
        'Dormant' AS customer_status
    FROM dormant_customers dc
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
    cust.c_custkey,
    cust.c_name,
    cust.c_acctbal,
    cust.customer_status,
    COALESCE(com.total_orders, 0) AS total_orders,
    com.first_order_date,
    com.most_recent_order_date
FROM all_customers cust
LEFT JOIN customer_order_metrics com
    ON cust.c_custkey = com.o_custkey
ORDER BY COALESCE(com.total_orders, 0) DESC;