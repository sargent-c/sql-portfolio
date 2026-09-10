-- Portfolio Query 10: Top product categories by revenue
-- Purpose: Identify the highest-revenue product categories across all orders
-- Data source: lineitem (transaction-level revenue) joined to part (product category)
-- Method: Aggregate revenue by product category, then apply DENSE_RANK() to 
--         produce a gapless leaderboard of top categories

WITH category_revenue AS (
    SELECT 
        p.p_type AS product_category,
        ROUND(SUM(l.l_extendedprice * (1 - l.l_discount)), 2) AS total_revenue
    FROM lineitem l
    JOIN part p
    ON l.l_partkey = p.p_partkey
    GROUP BY p.p_type
),
ranked_categories AS (
    SELECT 
        cr.product_category,
        cr.total_revenue,
        DENSE_RANK() OVER (ORDER BY cr.total_revenue DESC) AS category_rank
    FROM category_revenue cr
)
SELECT 
    rc.product_category,
    rc.total_revenue,
    category_rank
FROM ranked_categories rc
WHERE rc.category_rank <= 10;
