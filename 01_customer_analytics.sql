-- Portfolio Query 01: High-value customer segmentation
-- Purpose: Identify customers with account balances over $5,000 and highlight 
--          their market segments
-- Data source: customer table (c_acctbal, c_mktsegment)
-- Method: Filter high-value customers, sort by account balance, 
-- and return the top 10

SELECT 
    c_name AS customer_name,
    c_mktsegment AS market_segment,
    round(c_acctbal, 2) AS account_balance
FROM customer
WHERE c_acctbal > 5000
ORDER BY c_acctbal DESC
LIMIT 10;
