# Active Customers Pipeline

**Dataset:** TPC-H

This query identifies **active customers** (customers who have placed at least one order) and enriches them with customer-level order metrics. It demonstrates a common analytics engineering pattern using CTEs, a semi-join implemented with `EXISTS`, aggregation, and dimensional enrichment.

---

## Business Question

Which customers have placed orders, and what does their ordering activity look like?

The resulting dataset combines customer attributes with summary metrics describing order volume and activity dates.

---

## Pipeline Structure

## 1. CTE: active_customers

Filters the `customer` table to include only customers who have placed at least one order.

```sql
SELECT
    c.c_custkey,
    c.c_name,
    c.c_acctbal
FROM customer c
WHERE EXISTS (
    SELECT 1
    FROM orders o
    WHERE o.o_custkey = c.c_custkey
)
```

**Purpose:**

Uses the `EXISTS` semi-join pattern to identify active customers without creating duplicate customer rows through a join.

---

## 2. CTE: customer_order_metrics

Aggregates order activity at the customer level.

```sql
SELECT
    o.o_custkey,
    COUNT(*) AS total_orders,
    MIN(o.o_orderdate) AS first_order_date,
    MAX(o.o_orderdate) AS most_recent_order_date
FROM orders o
GROUP BY o.o_custkey
```

**Purpose:**

Creates customer-level metrics describing:
- Total orders placed
- First recorded order date
- Most recent order date

These metrics provide a simple view of customer engagement and purchasing history.

---

## Final Output

The final query joins active customers with aggregated order metrics, producing one row per active customer.

```sql
SELECT
    ac.c_custkey,
    ac.c_name,
    ac.c_acctbal,
    com.total_orders,
    com.first_order_date,
    com.most_recent_order_date
FROM active_customers ac
JOIN customer_order_metrics com
    ON ac.c_custkey = com.o_custkey
ORDER BY com.total_orders DESC;
```

---

## Analytics Engineering Concepts Demonstrated

- Common Table Expressions (CTEs)
- Semi-joins using `EXISTS`
- Customer-level aggregations
- Metric generation with `COUNT()`, `MIN()`, and `MAX()`
- Joining dimensional and aggregated data
- Building modular SQL transformation pipelines

---

## Business Value

The resulting dataset provides a customer-centric view of ordering activity that can support:
- Customer segmentation
- Retention analysis
- Identification of highly engaged customers
- Operational reporting
- Downstream analytical models

By combining customer attributes with behavioural metrics, the model creates an analysis-ready dataset suitable for further exploration or reporting.

---

## Summary

This pipeline demonstrates a practical analytics engineering pattern: filtering a business entity using a semi-join (`EXISTS`), generating aggregate metrics, and combining those metrics into a final analytical dataset. The approach produces a concise, reusable customer model while keeping each transformation step focused and easy to understand.

