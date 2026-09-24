# Customer Cohort Retention Analysis

**Dataset:** TPC-H

This pipeline model performs customer cohort retention analysis by grouping customers into monthly acquisition cohorts and measuring retention over time. It demonstrates a common analytics engineering pattern using date-based transformations, aggregations, and a multi-stage CTE pipeline.

# Business Question

How effectively are customer cohorts retained over time after their initial acquisition?

The resulting dataset yields monthly customer cohorts and shows what percentage of customers were
retained over time for each cohort.

---

##  Pipeline Structure

## 1. CTE: customer_cohorts

Refers to the `orders` table to determine when each customer was first acquired and assign them to a monthly cohort.

```sql
SELECT
    o_custkey,
    DATE_TRUNC('month', MIN(o_orderdate)) AS cohort_month
FROM orders
GROUP BY o_custkey
```

**Purpose:**

Uses the MIN() function to identify the first recorded order date for each customer. The resulting date is truncated to month level using DATE_TRUNC(), assigning each customer to an acquisition cohort.

---

## 2. CTE: customer_activity_months

Filters the `orders` table to find every month in which each customer placed at least one order.

```sql
SELECT DISTINCT
    o_custkey,
    DATE_TRUNC('month', o_orderdate) AS activity_month
FROM orders
```

**Purpose:**

Uses SELECT DISTINCT with DATE_TRUNC() to return a unique list of months in which each customer placed at least one order. This removes duplicate activity records within the same month.

---

## 3. CTE: customer_retention

Combines cohort assignments with customer activity months to calculate how long customers remain active after their initial acquisition.

```sql
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
```

**Purpose:**

Uses the DATE_DIFF() function to compare `cohort_month` with `activity_month` and returns the result as `months_since_first_order`.

---

# 4. CTE: cohort_sizes

Counts the number of customers in each original cohort to provide cohort sizes which will be fed into the final query.

```sql
SELECT
    cc.cohort_month,
    COUNT(*) AS cohort_size
FROM customer_cohorts cc
GROUP BY cc.cohort_month
```
**Purpose:**

Uses COUNT() to calculate the original population size of each cohort. The resulting dataset acts as a lookup table that is later used to calculate retention rates.

# Final Output

The final query provides a summary of the percentage of customers retained from each cohort.  The initial cohort month and number of months since the first order are displayed, along with a count of the active customers in following months, using `DISTINCT` to ensure that the count is not inflated by customers with multiple orders in any given month. The final column shows retention as a rate, allowing for fair comparison between cohorts of very different sizes.

**Note:** 

`retention_rate` is stored as a decimal fraction (0.7520 = 75.20%) for compatibility with downstream BI tools and dashboards.

```sql
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
```

---

## Analytics Engineering Concepts Demonstrated

- Common Table Expressions (CTEs)
- Multi-stage analytics pipeline design
- Date functions: `DATE_TRUNC()` and `DATE_DIFF()`
- Cohort modelling and retention analysis
- Aggregations using `COUNT()`
- Deduplication using `SELECT DISTINCT`
- Joining analytical datasets
- Calculation of retention metrics suitable for downstream BI tools

---

## Business Value

Cohort retention analysis tracks how groups of customers remain active over time. Analysing specific customer cohorts rather than the entire customer base can reveal patterns that may be hidden by aggregate metrics and can highlight differences in retention between acquisition periods.

The type of acquisition cohort analysis demonstrated in this model can be used to evaluate marketing campaigns, product updates, onboarding processes, and other significant business initiatives. By comparing retention rates across cohorts, organisations can gain a deeper understanding of long-term customer engagement and customer lifecycle performance.


---

## Summary

This pipeline demonstrates a complete customer cohort retention analysis workflow. Customers are first assigned to acquisition cohorts, their subsequent activity is tracked over time, and retention periods are calculated using date-based transformations. Cohort sizes are then combined with customer activity counts to produce retention metrics suitable for reporting and dashboarding tools.

The resulting dataset provides a reusable analytical model for monitoring customer retention trends, comparing cohort performance, and evaluating long-term customer engagement. By combining date functions, aggregations, and a structured CTE pipeline, the model illustrates a common analytics engineering pattern used in customer lifecycle and retention analysis.

