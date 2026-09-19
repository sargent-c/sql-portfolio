# Monthly Product Rank Change

**Dataset:** TPC-H

This query computes **monthly product rankings** based on units sold and measures **rank change over time**. It demonstrates a classic analytics engineering pattern using chained CTEs, window functions, and time-series logic.

---

## Business Question

Which products are the top sellers each month, and how does their ranking change compared to the previous month?

The resulting dataset highlights monthly leaders while capturing upward or downward movement in product performance over time.

---

## Pipeline Structure

## 1. CTE: `monthly_sales`

Aggregates product sales at the monthly level.

```sql
SELECT
    l_partkey,
    DATE_TRUNC('month', l_shipdate) AS month,
    SUM(l_quantity) AS units_sold
    FROM lineitem
GROUP BY l_partkey, month
```

**Purpose:** 
Creates a monthly sales summary for each product by rolling transaction-level data into a time-series dataset. This establishes the foundation for ranking and trend analysis.

---

## 2. CTE: `monthly_rank`
Ranks products within each month based on units sold.

```sql
SELECT
    l_partkey,
    month,
    units_sold,
    RANK() OVER (
        PARTITION BY month
        ORDER BY units_sold DESC
    ) AS month_rank
FROM monthly_sales
```

**Purpose:** 
Uses the RANK() window function to assign a sales rank to each product within a given month, allowing direct comparison between products during the same reporting period.

---

## 3. CTE: `rank_change`
Calculates ranking changes relative to the previous month.

```sql
SELECT
    l_partkey,
    month,
    month_rank,
    LAG(month_rank) OVER (
        PARTITION BY l_partkey
        ORDER BY month
    ) AS previous_rank
FROM monthly_rank
```

**Purpose:** 
Uses the LAG() window function to retrieve each product's rank from the previous month. This enables month-over-month trend analysis and identifies products that are gaining or losing position in the rankings. Products appearing for the first time in the time series will have a NULL previous rank, indicating that no prior monthly comparison exists.

---

## Final Output
The final query joins ranking information to product names and filters to the top 10 products per month.

```sql
SELECT
    p.p_name,
    rc.month,
    rc.month_rank,
    rc.previous_rank,
    (rc.previous_rank - rc.month_rank) AS rank_change
FROM rank_change rc
JOIN part p
    ON p.p_partkey = rc.l_partkey
WHERE rc.month_rank <= 10
ORDER BY rc.month, rc.month_rank;
```
The output focuses on the top 10 ranked products for each month while showing how their positions have changed compared to the previous month.

---

## Analytics Engineering Concepts Demonstrated
- Common Table Expressions (CTEs)
- Multi-stage SQL transformation pipelines
- Time-series aggregation
- Window functions
- RANK() for within-group ranking
- LAG() for period-over-period comparison
- Dimensional enrichment through joins
- Trend and performance analysis

---

## Business Value
Ranking analysis is commonly used to monitor product performance, identify emerging best sellers, and detect declining products before they become operational concerns. By tracking month-over-month ranking changes, analysts can identify products experiencing growth in demand, sudden drops in performance, or sustained leadership within a product portfolio.

This type of analysis supports merchandising decisions, inventory planning, demand forecasting, and executive performance reporting.

---

## Summary
This pipeline demonstrates how analytical datasets can be built progressively using CTEs and window functions. Monthly sales are first aggregated, then ranked within each reporting period, and finally compared against prior periods to measure rank movement. The resulting dataset provides clear insight into which products consistently perform well and which experience significant changes in ranking over time. This pattern is widely applicable in analytics workflows involving month-over-month trend analysis, leaderboard-style reporting, and product performance monitoring.

