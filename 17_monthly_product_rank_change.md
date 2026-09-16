# Monthly Product Rank Change (TPC-H)

This query computes **monthly product rankings** based on units sold and measures **rank change over time**. It demonstrates a classic analytics engineering pattern using chained CTEs, window functions, and time-series logic.

---

## 1. CTE: `monthly_sales`
Aggregates total units sold per product per month.

```sql
SELECT
    l_partkey,
    DATE_TRUNC('month', l_shipdate) AS month,
    SUM(l_quantity) AS units_sold
```

**Purpose:** Creates the foundational monthly sales dataset used for ranking.

---

## 2. CTE: `monthly_rank`
Ranks products within each month based on units sold.

```sql
RANK() OVER (
    PARTITION BY month
    ORDER BY units_sold DESC
)
```

**Purpose:** Identifies the top-performing products for each month.

**Notes**
- RANK() allows ties.
- Ranking is reset for each month via PARTITION BY.

---

## 3. CTE: `rank_change`
Computes rank change compared to the previous month.

```sql
LAG(month_rank) OVER (
    PARTITION BY l_partkey
    ORDER BY month
)
```
**Purpose:** Tracks how each product’s ranking moves over time.

**Notes**
- LAG() retrieves the previous month’s rank.
- Products with no previous month appear with NULL for previous_rank.

---

## Final Output
The final query joins product names and filters to the top 10 products per month.

**Columns**
- `p_name` — product name
- `month` — month of ranking
- `month_rank` — rank within the month
- `previous_rank` — rank in the previous month
- `rank_change` — movement in rank (positive = improvement)

---

## Business Value
This pattern is widely used for:
- product performance tracking
- trend analysis
- category management
- sales reporting
- dashboard metrics

It demonstrates a realistic analytics workflow using window functions and chained CTEs.

---

## Summary
This analysis combines monthly aggregation, ranking, and time‑series comparison to highlight how product performance evolves over time. By chaining multiple CTEs and applying window functions such as RANK() and LAG(), the model produces clear insights into which products consistently perform well and which experience significant rank movement. This pattern is widely applicable in analytics workflows where month‑over‑month trends, leaderboard-style reporting, or product performance monitoring are required.

