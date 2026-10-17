# Customer Acquisition Growth Model

**Dataset:** TPC-H

This model generates customer acquisition growth metrics using a multi-stage CTE pipeline with date transformations, aggregations, window functions, running totals, and month-on-month growth calculations.

## Business Question

How many customers are acquired each month? Is customer acquisition accelerating or slowing, and how large is the cumulative customer base over time?

##  Pipeline Structure

## 1. CTE: customer_acquisition_month

Calculates the month of first purchase for each customer using the `orders` table.

```sql
SELECT
    o_custkey,
    DATE_TRUNC('month', MIN(o_orderdate)) AS acquisition_month
FROM orders
GROUP BY o_custkey
```

**Output grain:** One row per customer.

**Purpose:**

Uses `MIN()` on `o_orderdate` to determine the date of first purchase for each customer. Applies `DATE_TRUNC()` to the date of first purchase to round it down to the month level and assign each customer to an `acquisition_month`.

---

## 2. CTE: new_customers_per_month

Calculates the number of new customers acquired each month.

```sql
SELECT
    acquisition_month,
    COUNT(*) AS new_customers
FROM customer_acquisition_month
GROUP BY acquisition_month
```

**Output grain:** One row per month.

**Purpose:**

Takes the `acquisition_month` data from the first CTE and applies `COUNT(*)` with `GROUP BY acquisition_month` to calculate the number of new customers for each month.

---

## 3. CTE: customer_acquisition_history

Adds a column showing the number of customers acquired in the previous month alongside each acquisition month.

```sql
SELECT
    acquisition_month,
    new_customers,
    LAG(new_customers) OVER (
        ORDER BY acquisition_month
    ) AS previous_month_customers
FROM new_customers_per_month
```

**Output grain:** One row per month.

**Purpose:**

Uses `LAG()` to retrieve the number of customers acquired in the previous month and stores the result in `previous_month_customers`. This value is used in the next stage to calculate month-on-month acquisition growth.

---

## 4. CTE: customer_growth_metrics

Takes the `new_customers` data and calculates the month-on-month percentage growth and a running monthly total for new customers acquired to date.

```sql
SELECT
    acquisition_month,
    new_customers,
    ROUND((new_customers - previous_month_customers)
    / previous_month_customers,
    4
    ) AS mom_growth,
    SUM(new_customers) OVER (
        ORDER BY acquisition_month
        ROWS BETWEEN UNBOUNDED PRECEDING
                         AND CURRENT ROW
    ) AS total_new_customers_to_date
FROM customer_acquisition_history
```

**Output grain:** One row per month.

**Purpose:**

The amounts in the `previous_month_customers` column are subtracted from the `new_customers` column and divided by `previous_month_customers` to calculate the monthly percentage growth (shown as a positive or negative decimal fraction, rounded to 4 decimal places). The window function `SUM() OVER (...)` is applied to `new_customers` using the frame clause `ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW` to calculate a running total of all new customers acquired between the start of the time series and the current row. Although the running-total window function references multiple months, the dataset remains at monthly grain because each row still represents a single acquisition month.

---

## Final Output

The outer SELECT statement returns the data from the final `customer_growth_metrics` CTE, ordered by `acquisition_month`.

```sql
SELECT
    acquisition_month,
    new_customers,
    mom_growth,
    total_new_customers_to_date
FROM customer_growth_metrics
ORDER BY acquisition_month
```

**Example Output:**


| acquisition_month | new_customers | mom_growth | total_new_customers_to_date |
| ----------------- | ------------- | ---------- | --------------------------- |
| 1992-01-01T00:00:00.000Z | 17409 |     NULL     | 17409 | 
| 1992-02-01T00:00:00.000Z | 13214 |    -0.241    | 30623 |
| 1992-03-01T00:00:00.000Z | 11624 |    -0.1203   | 42247 |
| 1992-04-01T00:00:00.000Z | 9128  |    -0.2147   | 51375 |
| 1992-05-01T00:00:00.000Z | 7713  |    -0.155    | 59088 |
| 1992-06-01T00:00:00.000Z | 6227  |    -0.1927   | 65315 |
| 1992-07-01T00:00:00.000Z | 5359  |    -0.1394   | 70674 |
| 1992-08-01T00:00:00.000Z | 4403  |    -0.1784   | 75077 |

**Note:**
The first acquisition month contains `NULL` for `mom_growth` because no prior period exists for comparison.

---

## Analytics Engineering Concepts Demonstrated

- Common Table Expressions (CTEs)
- Date transformation with `DATE_TRUNC()`
- Transformations at multiple data grains
- Customer acquisition modelling
- Aggregations with `COUNT()` and `SUM()`
- Window functions with `LAG() OVER()` and `SUM() OVER()`
- Window frame clauses (`UNBOUNDED PRECEDING ... CURRENT ROW`)
- Running totals
- Month-on-month (MoM) growth calculations
- Multi-stage analytics pipeline design

---

## Business Value

Customer acquisition growth modelling helps organisations track how the customer base changes over time, whether acquisition is accelerating or slowing, and how much cumulative growth has occurred.

---

## Summary

This model tracks customer acquisition over time by assigning customers to an acquisition month and calculating the number of new customers acquired in each period. Month-on-month growth rates and cumulative acquisition totals are then derived using window functions.

The resulting dataset provides a reusable KPI model suitable for dashboards, BI tools, and analytics pipelines. Together, the monthly acquisition, growth, and cumulative metrics provide a clear view of how the customer base is evolving over time.