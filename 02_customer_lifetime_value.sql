-- Portfolio Query 02: Customer lifetime value (LTV) analysis
-- Purpose: Calculate total spending and total orders per customer to identify 
--          high-value segments
-- Data source: orders (o_totalprice, o_orderkey) joined to 
--              customer (c_custkey, c_mktsegment)
-- Method: Aggregate total spending and order count per customer using a CTE, then 
--         return the top 10 by lifetime value

WITH customer_orders AS (
    SELECT 
        o_custkey,
        ROUND(SUM(o_totalprice), 2) AS total_spent,
        COUNT(o_orderkey) AS total_orders
    FROM orders
    GROUP BY o_custkey
)
SELECT 
    c.c_name AS customer_name,
    c.c_mktsegment AS market_segment,
    co.total_spent AS lifetime_value,
    co.total_orders
FROM customer c
JOIN customer_orders co ON c.c_custkey = co.o_custkey
ORDER BY lifetime_value DESC
LIMIT 10;
