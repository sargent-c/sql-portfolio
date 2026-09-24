-- Portfolio Query 20: Customer Cohort Retention Analysis (TPC-H)
-- Groups customers into monthly cohorts and measures customer retention
-- over time using cohort size and retention rate metrics.

WITH customer_cohorts AS (
    SELECT
        o_custkey,
        DATE_TRUNC('month', MIN(o_orderdate)) AS cohort_month
    FROM orders
    GROUP BY o_custkey
),

customer_activity_months AS (
    SELECT DISTINCT
        o_custkey,
        DATE_TRUNC('month', o_orderdate) AS activity_month
    FROM orders
),

customer_retention AS (
    SELECT
        cc.o_custkey,
        cc.cohort_month,
        DATE_DIFF(
            'month',
            cc.cohort_month,
            cam.activity_month
        ) AS months_since_first_order
    FROM customer_cohorts cc
    JOIN customer_activity_months cam
      ON cc.o_custkey = cam.o_custkey
),

cohort_sizes AS (
    SELECT
        cc.cohort_month,
        COUNT(*) AS cohort_size
    FROM customer_cohorts cc
    GROUP BY cc.cohort_month
)

SELECT
    cr.cohort_month,
    cr.months_since_first_order,
    COUNT(DISTINCT cr.o_custkey) AS active_customers,
    cs.cohort_size,
    ROUND(
        COUNT(DISTINCT cr.o_custkey)::DECIMAL
        / cs.cohort_size,
        4
) AS retention_rate
FROM customer_retention cr
JOIN cohort_sizes cs
  ON cr.cohort_month = cs.cohort_month
GROUP BY
    cr.cohort_month,
    cr.months_since_first_order,
    cs.cohort_size
ORDER BY
    cr.cohort_month,
    cr.months_since_first_order;





