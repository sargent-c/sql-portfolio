-- Portfolio Query 13: Days until next order per customer
-- Purpose: Measure the time gap between consecutive orders for each customer to
--          understand purchase frequency and identify retention patterns. Also
--          flag the final order in each customer's sequence.
-- Data source: orders table (o_orderdate, o_custkey)
-- Method: Use LEAD() in a CTE to retrieve each customer's next order date, then
--         calculate the number of days until that next order and mark rows where
--         no subsequent order exists.

WITH ordered AS (
    SELECT
        o_custkey,
        o_orderdate,
        LEAD(o_orderdate) OVER (
            PARTITION BY o_custkey
            ORDER BY o_orderdate
        ) AS next_order_date
    FROM orders
)
SELECT
    o_custkey AS customer_id,
    o_orderdate AS order_date,
    next_order_date,
    next_order_date - o_orderdate AS days_until_next_order,
    CASE 
        WHEN next_order_date IS NULL THEN 'last order'
        ELSE 'not last'
    END AS order_position
FROM ordered
ORDER BY o_custkey, o_orderdate;


