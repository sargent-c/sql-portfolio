-- Portfolio Query 17: Lifetime Value Segmentation and Benchmarking (TPC-H)
-- Calculates customer lifetime value (LTV), segments customers into
-- market-segment quartiles, and benchmarks each customer against the
-- highest-value customer in their segment.
-- Demonstrates NTILE(), FIRST_VALUE(), window frame clauses,
-- transformations at multiple data grains, and customer benchmarking.

WITH customer_lifetime_value AS (
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
),

segment_top_metrics AS (
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
)

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
    clv.lifetime_value DESC;
