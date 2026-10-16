# Customer Lifetime Value Segmentation and Benchmarking

**Dataset:** TPC-H

This model calculates customer lifetime value (LTV), segments customers into lifetime-value quartiles within their market segment, and provides benchmarking metrics that compare each customer against the top performer in the segment.

## Business Question

Which lifetime-value quartile does each customer belong to within their market segment, and how does their performance compare with the highest-value customer in that segment?

##  Pipeline Structure

## 1. CTE: customer_lifetime_value

Calculates customer lifetime value and total order count for each customer.

```sql
SELECT
    c.c_mktsegment,
    o.o_custkey,
    SUM(o.o_totalprice) AS lifetime_value,
    COUNT(o.o_orderkey) AS total_orders
FROM orders o
JOIN customer c
  ON o.o_custkey = c.c_custkey
GROUP BY 
    c.c_mktsegment,
    o.o_custkey
```

**Output grain:** One row per customer.

**Purpose:**

The `orders` table is joined to the `customer` table to retrieve market segment information. Rows are grouped by `o_custkey` and `c_mktsegment`, allowing `SUM()` to calculate customer lifetime value and `COUNT()` to calculate the total number of orders. The resulting dataset is maintained at customer grain (one row per customer) while retaining market-segment information for later segmentation and benchmarking.

---

## 2. CTE: segment_top_metrics

Produces benchmarking metrics for each market segment, including the highest-value customer and the highest lifetime value. This CTE transforms the customer-level lifetime-value dataset into a market-segment-level benchmarking dataset.

```sql
SELECT DISTINCT
        clv.c_mktsegment,
        FIRST_VALUE(clv.o_custkey) OVER (
            PARTITION BY clv.c_mktsegment
            ORDER BY clv.lifetime_value DESC
            ROWS BETWEEN UNBOUNDED PRECEDING
                     AND UNBOUNDED FOLLOWING
        ) AS top_customer_in_segment,
        MAX(clv.lifetime_value) OVER (
            PARTITION BY clv.c_mktsegment
        ) AS top_lifetime_value_in_segment
    FROM customer_lifetime_value clv
```

**Output grain:** One row per market segment.

**Purpose:**

The window function `FIRST_VALUE() OVER (...)` is used to identify the highest-value customer in each market segment. The frame clause `ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING` ensures that the function evaluates the entire partition and consistently returns the true first value. `MAX() OVER (...)` is then used to determine the highest lifetime value within each segment.

The output of these window functions initially produces repeated values for every customer in a segment. `SELECT DISTINCT` is therefore used to reduce the dataset to one row per market segment. The resulting dataset is maintained at market-segment grain (one row per market segment).

---

## Final Output

The outer `SELECT` statement returns the segmented customer lifetime values and total orders, along with the benchmarking metrics for `top_customer_in_segment` and `top_lifetime_value_in_segment`. `NTILE() OVER(...)` is used to divide customers into lifetime value quartiles within each market segment. The difference in lifetime value between each customer and the highest segment lifetime value is calculated and returned as `gap_to_top_ltv`.

```sql
SELECT
    clv.c_mktsegment,
    clv.o_custkey,
    clv.lifetime_value,
    clv.total_orders,
    NTILE(4) OVER (
        PARTITION BY clv.c_mktsegment
        ORDER BY clv.lifetime_value DESC
    ) AS segment_quartile,
    stm.top_customer_in_segment,
    stm.top_lifetime_value_in_segment,
    stm.top_lifetime_value_in_segment
        - clv.lifetime_value
        AS gap_to_top_ltv
FROM customer_lifetime_value clv
JOIN segment_top_metrics stm
  ON clv.c_mktsegment = stm.c_mktsegment
ORDER BY
    clv.c_mktsegment,
    clv.lifetime_value DESC
```

**Example Output:**

|c_mktsegment|o_custkey|lifetime_value|total_orders|segment_quartile|top_customer_in_segment|top_lifetime_value_in_segment|gap_to_top_ltv|
| ------------ | --------- | -------------- | ------------ | ----- | ---|--- | ------|
| AUTOMOBILE   | 87115     | 6457526.26     | 34           | 1     | 87115    | 6457526.26 |0 |
| AUTOMOBILE   | 69682     | 6287149.42     | 39           | 1     | 87115    | 6457526.26 |170376.84 |
| AUTOMOBILE   | 102022    | 6273788.41     | 41           | 1     | 87115    | 6457526.26 |183737.85 |
| AUTOMOBILE   | 85102     | 6135483.63     | 34           | 1     | 87115    | 6457526.26 |322042.63 |
| AUTOMOBILE   | 56317     | 6117381.16     | 34           | 1     | 87115    | 6457526.26 |340145.1 |

---

## Analytics Engineering Concepts Demonstrated

- Common Table Expressions (CTEs)
- Customer lifetime value (LTV) modelling
- Customer segmentation using `NTILE()`
- Window functions with `FIRST_VALUE()`, `MAX() OVER()`, and `NTILE() OVER()`
- Window frame clauses (`UNBOUNDED PRECEDING ... UNBOUNDED FOLLOWING`)
- Transformations at multiple data grains
- Market-segment-level benchmarking
- Gap analysis using derived metrics
- Joining customer-grain and market-segment-grain datasets
- Multi-stage analytics pipeline design

---

## Business Value

Customer lifetime value segmentation and benchmarking help businesses understand how customers compare with others in their market segment. Dividing customers into quartiles provides a structured view of customer value, making it easier to identify high-value customers, mid-tier customers, and customers with growth potential.

The benchmarking metrics extend this analysis by showing the top-performing customer and highest lifetime value within each market segment. The `gap_to_top_ltv` metric highlights how far each customer is from the segment leader, providing a useful measure of relative performance and helping to identify customers that may warrant additional marketing, retention, or account-management attention.

---

## Summary

This model combines three related analytical layers: customer lifetime value calculation, customer segmentation, and market-segment benchmarking. Customer lifetime value and total order counts are first calculated at customer grain. Customers are then segmented into lifetime-value quartiles within their market segment, before benchmarking metrics are added at market-segment grain and joined back to the customer-level dataset.

The final output shows each customer's lifetime value, total number of orders, market-segment quartile, and relative performance compared with the highest-value customer in their segment. The resulting dataset can support customer analytics, segmentation strategies, and business intelligence reporting.


