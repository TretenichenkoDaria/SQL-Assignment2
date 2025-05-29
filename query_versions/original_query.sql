use assignment2;

explain analyze
SELECT 
    u.name AS customer_name,
    u.email,
    COUNT(DISTINCT o.order_id) AS total_orders,
    SUM(oi.quantity * oi.price) AS total_spent,
    (
        SELECT COUNT(*) 
        FROM products p 
        WHERE p.stock < 10
    ) AS low_stock_products
FROM users u
JOIN orders o ON u.user_id = o.user_id
JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.order_date >= '2024-01-01'
  AND o.order_id IN (
      SELECT order_id FROM order_items WHERE quantity >= 5
  )
GROUP BY u.user_id, u.name, u.email
HAVING total_spent > 500
ORDER BY total_spent DESC;

-- -> Sort: total_spent DESC  (actual time=0.574..0.574 rows=1 loops=1)
--     -> Filter: (total_spent > 500)  (actual time=0.543..0.556 rows=1 loops=1)
--         -> Stream results  (actual time=0.54..0.551 rows=3 loops=1)
--             -> Group aggregate: count(distinct orders.order_id), sum(tmp_field)  (actual time=0.531..0.538 rows=3 loops=1)
--                 -> Sort: u.user_id, u.`name`, u.email  (actual time=0.507..0.509 rows=4 loops=1)
--                     -> Stream results  (cost=2.68 rows=0.3) (actual time=0.407..0.464 rows=4 loops=1)
--                         -> Inner hash join (oi.order_id = o.order_id)  (cost=2.68 rows=0.3) (actual time=0.384..0.429 rows=4 loops=1)
--                             -> Table scan on oi  (cost=0.121 rows=11) (actual time=0.0175..0.0531 rows=11 loops=1)
--                             -> Hash
--                                 -> Inner hash join (u.user_id = o.user_id)  (cost=2.12 rows=0.273) (actual time=0.274..0.321 rows=3 loops=1)
--                                     -> Table scan on u  (cost=0.117 rows=8) (actual time=0.0232..0.0603 rows=8 loops=1)
--                                     -> Hash
--                                         -> Hash semijoin (order_items.order_id = o.order_id)  (cost=1.66 rows=0.273) (actual time=0.165..0.219 rows=3 loops=1)
--                                             -> Filter: (o.order_date >= DATE'2024-01-01')  (cost=1.15 rows=3) (actual time=0.0189..0.0642 rows=9 loops=1)
--                                                 -> Table scan on o  (cost=1.15 rows=9) (actual time=0.0156..0.0537 rows=9 loops=1)
--                                             -> Hash
--                                                 -> Filter: (order_items.quantity >= 5)  (cost=0.364 rows=1) (actual time=0.0789..0.106 rows=3 loops=1)
--                                                     -> Table scan on order_items  (cost=0.364 rows=11) (actual time=0.063..0.0984 rows=11 loops=1)
-- -> Select #2 (subquery in projection; run only once)
--     -> Aggregate: count(0)  (cost=1.58 rows=1) (actual time=0.0522..0.0523 rows=1 loops=1)
--         -> Filter: (p.stock < 10)  (cost=1.25 rows=3.33) (actual time=0.0187..0.0483 rows=6 loops=1)
--             -> Table scan on p  (cost=1.25 rows=10) (actual time=0.0171..0.0429 rows=10 loops=1)
