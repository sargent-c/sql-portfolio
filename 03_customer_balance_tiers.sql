-- Portfolio Query 03: Customer account balance tiering
-- Purpose: Categorize customers into high, medium, and low balance tiers for targeted marketing
-- Data source: customer table (c_acctbal, c_mktsegment)
-- Method: Use CASE logic to assign each customer to a balance tier, then sort by account balance

SELECT 
    c_name AS customer_name,
    c_mktsegment AS market_segment,
    round(c_acctbal, 2) AS account_balance,
    CASE 
        WHEN c_acctbal > 7000 THEN 'High Balance'
        WHEN c_acctbal BETWEEN 2000 AND 7000 THEN 'Medium Balance'
        ELSE 'Low Balance'
    END AS customer_tier
FROM customer
ORDER BY account_balance DESC
LIMIT 20;
