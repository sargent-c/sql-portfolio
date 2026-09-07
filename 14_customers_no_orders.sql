-- Portfolio Query 14: Customers who have never placed an order
-- Purpose: Identify customers with no associated orders so sales teams can
--          target outreach and understand gaps in customer engagement.
-- Data source: customer table (c_custkey, c_name, c_address, c_phone)
--              orders table (o_custkey)
-- Method: LEFT JOIN customers to orders and filter for rows where no matching
--         order exists (o_custkey IS NULL)
SELECT
    c.c_custkey AS customer_id,
    c.c_name AS customer_name,
    c.c_address AS customer_address,
    c.c_phone AS customer_phone
FROM customer c
LEFT JOIN orders o
    ON c.c_custkey = o.o_custkey
WHERE o.o_custkey IS NULL
ORDER BY c.c_custkey;
