-- Portfolio Query 02: Top 3 wealthiest customers per market segment
-- Purpose: Identify the highest-balance customers within each market segment
-- Data source: customer table (c_acctbal, c_mktsegment)
-- Method: Use RANK() with PARTITION BY to rank customers within each segment, 
--         then filter with QUALIFY

SELECT 
    c_mktsegment AS market_segment,
    c_name AS customer_name,
    ROUND(c_acctbal, 2) AS account_balance,
    RANK() OVER (
        PARTITION BY c_mktsegment 
        ORDER BY c_acctbal DESC
    ) AS segment_rank
FROM customer
QUALIFY segment_rank <= 3;
