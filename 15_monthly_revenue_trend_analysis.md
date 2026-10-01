# Monthly Revenue Trend Analysis

**Dataset:** TPC-H

This query provides the dataset for a three-month moving average revenue trend analysis. It demonstrates a typical data-smoothing technique using a window function, date truncation, aggregation steps, and CTEs.

## Business Question

What is the revenue trend over time after short-term fluctuations are filtered out?

The resulting dataset provides a clearer signal for assessing whether revenue is trending up or down over time.

---

##  Pipeline Structure

## 1. CTE: monthly_revenue

Calculates total revenue per month by referring to the `orders` table, joined to `lineitem`.

```sql
SELECT
    DATE_TRUNC('month', o.o_orderdate) AS month,
    SUM(l.l_extendedprice * (1 - l.l_discount)) AS total_revenue
FROM orders o
JOIN lineitem l
  ON o.o_orderkey = l.l_orderkey
GROUP BY DATE_TRUNC('month', o.o_orderdate)
```

**Purpose:**

Applies `DATE_TRUNC()` to the `o_orderdate` column in the `orders` table to round each date down to the month level. The resulting dates are joined to individual order items in the `lineitem` table (the "fact" table) and the standard revenue calculation is applied with `SUM()` to calculate `total_revenue`.

---

## 2. CTE: revenue_trends

Takes the revenue totals produced by the first CTE and calculates a three-month moving average of monthly revenue.

```sql
SELECT
    mr.month,
    ROUND(mr.total_revenue, 2) AS total_revenue,
    ROUND(
        AVG(mr.total_revenue) OVER (
            ORDER BY mr.month
            ROWS BETWEEN 2 PRECEDING
                     AND CURRENT ROW
        ),
        2
    ) AS three_month_moving_average
FROM monthly_revenue mr
```

**Purpose:**

Applies a window function to the monthly revenue data and calculates a moving average using the current month and the two preceding months as a "sliding" frame. The frame clause `ROWS BETWEEN 2 PRECEDING AND CURRENT ROW` ensures that the averages are only calculated for three month sets and do not include rows going further back in time. The outupt from `AVG()` is rounded to two decimal places with `ROUND()` for readability.

This calculation uses the usual three-month moving average formula:

Moving Average = (Revenue<sub>t</sub> + Revenue<sub>t-1</sub> + Revenue<sub>t-2</sub>) / 3


---

## Final Output

The final query takes the output from the last CTE and returns three columns showing the month, the total revenue for each month, and the three-month moving averages.

```sql
SELECT
    rt.month,
    rt.total_revenue,
    rt.three_month_moving_average
FROM revenue_trends rt
ORDER BY rt.month;
```

**Example output:**

|   month   |   total_revenue   | three_month_moving_average |
| --------- | ----------------- | -------------------------- |
| 1992-01-01T00:00:00.000Z | 2812229777.73 | 2812229777.73 |
| 1992-02-01T00:00:00.000Z | 2618065218.41 | 2715147498.07 |
| 1992-03-01T00:00:00.000Z | 2804113927.98 | 2744802974.71 |
| 1992-04-01T00:00:00.000Z | 2702383581.75 | 2708187576.05 |
| 1992-05-01T00:00:00.000Z | 2778628995.65 | 2761708835.13 |
| 1992-06-01T00:00:00.000Z | 2710824011.13 | 2730612196.18 |
| 1992-07-01T00:00:00.000Z | 2790269094.04 | 2759907366.94 |
| 1992-08-01T00:00:00.000Z | 2779379369.22 | 2760157491.46 |
| 1992-09-01T00:00:00.000Z | 2713597534.2  | 2761081999.15 |

**Note:** 
The first two moving average values are based on fewer than three months of data because there are not yet enough prior months available for a full three-month calculation.

---

## Analytics Engineering Concepts Demonstrated

- Common Table Expressions (CTEs)
- Date transformation with `DATE_TRUNC()`
- Revenue aggregation with `SUM()`
- Window functions using `AVG() OVER (...)`
- Three-month moving averages using a sliding frame
- Separation of aggregation and analytical calculations into distinct pipeline stages

---

## Business Value

Raw monthly or weekly revenue numbers can often be erratic. Moving average revenue trend analysis filters out short-term noise and seasonal fluctuations to isolate underlying sales growth and reveal whether revenue performance is genuinely expanding or contracting. It also has a wide range of applications in other areas such as health analytics and disease reporting, where statistics for significant illnesses such as influenza are often reported with a seven-day moving average to provide a clearer picture of changing trends in disease prevalence.

---

## Summary

This model implements a standard three-month moving average pipeline. Revenue is aggregated by month and a three-month moving average is then calculated using the current month and the two preceding months. The resulting dataset is suitable for output to business metrics dashboards and BI reporting tools. By showing total monthly revenue and moving average values together, the underlying sales trends can be made clearer which helps to separate the "signal" from the "noise".
