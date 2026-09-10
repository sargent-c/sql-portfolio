-- Portfolio Query 05: Highest-value countries by customer account balance
-- Purpose: Identify countries with the highest total customer account value
-- Data source: customer table (c_acctbal, c_nationkey) joined to nation
-- Method: Aggregate customer account balances by country, then sort by total value
-- Note: The TPC-H sample dataset distributes customer balances uniformly across 
--       countries, so total values fall within a narrow range. This query 
--       demonstrates aggregation logic rather than meaningful business variation.

WITH customer_value_by_country AS (
    SELECT
        c_nationkey, 
        SUM(c_acctbal) AS total_customer_value
    FROM customer
    GROUP BY c_nationkey
)
SELECT  
    n.n_name AS Country, 
    cv.total_customer_value
FROM customer_value_by_country cv
JOIN nation n 
  ON n.n_nationkey = cv.c_nationkey
WHERE cv.total_customer_value > 10000000
ORDER BY cv.total_customer_value DESC LIMIT 10;