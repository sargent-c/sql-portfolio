# Customer Activity Segmentation

**Dataset:** TPC-H

This query segments customers into **Active** and **Dormant** categories and adds customer order metrics. It uses a chained CTE pipeline, semi-join and anti-join patterns implemented with EXISTS and NOT EXISTS, UNION ALL, and aggregation to enrich the final customer dataset.

---

## Business Question

Which customers are active or dormant, and what does their ordering activity look like?

The resulting dataset combines customer attributes and active / dormant status with summary metrics describing order volume and activity dates.

---

##  Pipeline Structure

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

## 2. CTE: dormant_customers

Filters the `customer` table to find those customers who have never placed an order.

```sql
SELECT
        c.c_custkey,
        c.c_name,
        c.c_acctbal
    FROM customer c        
    WHERE NOT EXISTS (
        SELECT 1
        FROM orders o
        WHERE c.c_custkey = o.o_custkey)
```

**Purpose:** 

Uses the `NOT EXISTS` anti-join pattern to identify dormant customers by returning those who do not appear in the `orders` table.

---

## 3. CTE: all_customers

Combines the output from the previous two CTEs to show all customers according to status segment.

```sql
SELECT
        ac.c_custkey,
        ac.c_name,
        ac.c_acctbal,
        'Active' AS customer_status
    FROM active_customers ac
        
    UNION ALL

    SELECT
        dc.c_custkey,
        dc.c_name,
        dc.c_acctbal,
        'Dormant' AS customer_status
    FROM dormant_customers dc
```
**Purpose:**

Uses UNION ALL to combine the active and dormant customer populations into a single dataset, adding a status column to classify each customer as "Active" or "Dormant".

---

## 4. CTE: customer_order_metrics

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

The final query joins active and dormant customers with aggregated order metrics. The use of a `LEFT JOIN` ensures that dormant customers who do not appear in the `orders` table are included in the output. The `COALESCE()` function is applied to the output for the `total_orders` column in order to display NULL values as 0.

```sql
SELECT
    cust.c_custkey,
    cust.c_name,
    cust.c_acctbal,
    cust.customer_status,
    COALESCE(com.total_orders, 0) AS total_orders,
    com.first_order_date,
    com.most_recent_order_date
FROM all_customers cust
LEFT JOIN customer_order_metrics com
    ON cust.c_custkey = com.o_custkey
ORDER BY COALESCE(com.total_orders, 0) DESC;
```

## Analytics Engineering Concepts Demonstrated

- Common Table Expressions (CTEs)
- Semi and anti-joins using `EXISTS` and `NOT EXISTS`
- `UNION ALL` for combining customer populations
- Customer-level aggregations
- Metric generation with `COUNT()`, `MIN()`, and `MAX()`
- Joining dimensional and aggregated data
- Building modular SQL transformation pipelines

---

## Business Value

Customer segmentation is a common analytical workflow used to identify differences in customer engagement and behaviour. Distinguishing between active customers and those who have never placed an order can help organisations understand customer adoption, evaluate marketing effectiveness, and identify opportunities for re-engagement.

By combining customer status with order metrics, the resulting dataset supports customer reporting, retention analysis, sales outreach initiatives, and the development of downstream analytical models. The approach provides a simple but effective framework for monitoring customer activity across the customer base.

---

## Summary

This pipeline demonstrates how customer populations can be segmented using both semi-join (`EXISTS`) and anti-join (`NOT EXISTS`) patterns. Active and dormant customers are first identified separately, then combined using `UNION ALL` before being enriched with customer-level order metrics.

The resulting dataset provides a unified view of customer status and ordering behaviour, illustrating a common analytics engineering pattern for customer segmentation, activity monitoring, and reporting. The model combines business-oriented classification with reusable analytical metrics while maintaining a clear and modular CTE structure.