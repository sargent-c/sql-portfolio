-- Portfolio Query 09: Date of highest transaction per customer
-- Purpose: Identify each customer's highest-value order and the date it occurred
-- Data source: orders table (o_totalprice, o_orderdate, o_custkey)
-- Method: Use ROW_NUMBER() with PARTITION BY to select each customer's single
--         highest-value transaction, using order date as a tie-breaker
-- Note: ROW_NUMBER() ensures exactly one transaction per customer; RANK() would
--       return all tied highest-value transactions

WITH ranked_transactions AS (
    SELECT
        o_custkey AS customer_id,
        o_totalprice AS amount,
        o_orderdate AS transaction_date,
        ROW_NUMBER() OVER (
            PARTITION BY o_custkey
            ORDER BY o_totalprice DESC, o_orderdate DESC
        ) AS transaction_rank
    FROM orders
)
SELECT 
    customer_id,
    amount,
    transaction_date
FROM ranked_transactions
WHERE transaction_rank = 1;
