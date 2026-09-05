-- Portfolio Query 06: Highest-value countries ranked
-- Purpose: Produce a ranked list of countries based on total customer account value
-- Data source: customer table (c_acctbal, c_nationkey) joined to nation
-- Method: Aggregate customer account balances by country, then apply RANK() to order
--         countries by total value
-- Note: The TPC-H dataset distributes customer balances uniformly across countries,
--       so rankings reflect small variations rather than meaningful business differences

WITH customer_value_by_country AS (
    SELECT
        c_nationkey, 
        SUM(c_acctbal) AS total_customer_value
    FROM customer
    GROUP BY c_nationkey
),
ranked_countries AS (
    SELECT
        n.n_name AS country,
        cv.total_customer_value, 
        RANK() OVER (ORDER BY cv.total_customer_value DESC) AS country_rank
    FROM customer_value_by_country cv
    JOIN nation n
    ON n.n_nationkey = cv.c_nationkey
)
SELECT *
FROM ranked_countries
ORDER BY country_rank;