-- Portfolio Query 16: Customer Acquisition Growth Model (TPC-H)
-- Tracks customer acquisition over time by calculating monthly new customers,
-- month-on-month growth rates, and cumulative customer growth.
-- Demonstrates transformations at multiple data grains, DATE_TRUNC(),
-- window functions, frame clauses, and a multi-stage analytics pipeline.

WITH customer_acquisition_month AS (
    SELECT
        o_custkey,
        DATE_TRUNC('month', MIN(o_orderdate)) AS acquisition_month
    FROM orders
    GROUP BY o_custkey
),

new_customers_per_month AS (
    SELECT
        acquisition_month,
        COUNT(*) AS new_customers
    FROM customer_acquisition_month
    GROUP BY acquisition_month
),

customer_acquisition_history AS (
    SELECT
        acquisition_month,
        new_customers,
        LAG(new_customers) OVER (
            ORDER BY acquisition_month
        ) AS previous_month_customers
    FROM new_customers_per_month
),

customer_growth_metrics AS (
    SELECT
        acquisition_month,
        new_customers,
        ROUND(
            (new_customers - previous_month_customers)
            / previous_month_customers,
            4
        ) AS mom_growth,
        SUM(new_customers) OVER (
            ORDER BY acquisition_month
            ROWS BETWEEN UNBOUNDED PRECEDING
                     AND CURRENT ROW
        ) AS total_new_customers_to_date
    FROM customer_acquisition_history
)

SELECT
    acquisition_month,
    new_customers,
    mom_growth,
    total_new_customers_to_date
FROM customer_growth_metrics
ORDER BY acquisition_month;