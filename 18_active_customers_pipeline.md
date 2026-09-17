# Active Customers Pipeline (TPC-H)

This portfolio query identifies **active customers** — customers who have placed at least one order — and computes basic order‑level metrics. It demonstrates a common analytics engineering pattern using CTE structuring, a semi‑join with `EXISTS`, and simple aggregation.

---

## 1. CTE: `customers`

A staging CTE that selects core customer attributes used throughout the pipeline.

```sql
SELECT
    c_custkey,
    c_name,
    c_acctbal
FROM customer
```

**Purpose:**  
Provides a clean, minimal customer dataset containing only the fields required for downstream logic. This avoids carrying unused columns through the pipeline and keeps the transformation focused.

---

## 2. CTE: `active_customers`

Filters the customer dataset to include only customers who have placed at least one order, using the `EXISTS` semi‑join pattern.

```sql
SELECT
    c.c_custkey,
    c.c_name,
    c.c_acctbal
FROM customers c
WHERE EXISTS (
    SELECT 1
    FROM orders o
    WHERE o.o_custkey = c.c_custkey
)
```

**Purpose:**  
Identifies active customers by checking for the existence of at least one matching order. Using `EXISTS` avoids unnecessary joins and ensures efficient filtering without duplicating customer rows.

---

## 3. CTE: `customer_order_metrics`

Computes basic order‑level metrics for each active customer, including total number of orders and the date range of their ordering activity.

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
Aggregates order data at the customer level, producing metrics that describe customer activity over time. These values enrich the active customer list with meaningful business information such as order volume and recency.

---

## 4. CTE: `final`

Combines the active customer list with their computed order metrics to produce the final enriched dataset.

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
```

**Purpose:**  
Brings together customer attributes and order‑level metrics, producing a complete view of each active customer’s engagement. This final dataset is suitable for reporting, segmentation, or further downstream modeling.

---

## Final Output

The final query returns each active customer along with their aggregated order metrics, producing a clean, analysis‑ready dataset.

**Columns**
- `c_custkey` — customer identifier  
- `c_name` — customer name  
- `c_acctbal` — account balance  
- `total_orders` — number of orders placed  
- `first_order_date` — earliest order date  
- `most_recent_order_date` — latest order date  

**Purpose:**  
Provides a consolidated customer‑level output suitable for reporting, segmentation, or downstream modeling. This dataset represents the final stage of the pipeline, combining customer attributes with meaningful order activity metrics.

---

## Business Value

This pipeline provides a clear view of customer engagement by identifying which customers are actively placing orders and summarizing their ordering behavior. These insights support a range of analytical needs, including customer segmentation, retention analysis, revenue forecasting, and operational reporting. By combining customer attributes with order activity metrics, the model helps highlight high‑value customers and informs data‑driven decision‑making across sales and customer management workflows.

---

## Summary

This pipeline provides a structured approach to identifying active customers and enriching them with meaningful order‑level metrics. By combining semi‑join filtering with aggregation and a final consolidation step, the model produces a clean, analysis‑ready dataset suitable for customer segmentation, retention analysis, and operational reporting. The CTE structure keeps each transformation focused and readable, illustrating a clear analytics engineering pattern for building modular SQL pipelines.
