-- Portfolio Query 07: Percentage change in order value per customer
-- Purpose: Measure how each customer's spending changes from one order to the next,
--          expressed as a percentage to capture relative growth or decline
-- Data source: orders table (o_totalprice, o_orderdate, o_custkey)
-- Method: Use LAG() to retrieve each customer's previous order amount in a CTE,
--         then compute the percentage change between consecutive orders

WITH ordered AS (
    SELECT
        o_custkey,
        o_orderdate,
        o_totalprice,
        LAG(o_totalprice) OVER (
            PARTITION BY o_custkey 
            ORDER BY o_orderdate
        ) AS prev_amount
    FROM orders
)
SELECT
    o_custkey AS customer_id,
    o_orderdate AS order_date,
    o_totalprice AS order_amount,
    (o_totalprice - prev_amount) / NULLIF(prev_amount, 0) AS pct_change_fraction
FROM ordered
ORDER BY o_custkey, o_orderdate;
