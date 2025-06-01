use assignment2;

explain
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

-- -> Sort: total_spent DESC  (actual time=2675..2676 rows=9502 loops=1)
--     -> Filter: (total_spent > 500)  (actual time=2489..2663 rows=9502 loops=1)
--         -> Stream results  (actual time=2489..2661 rows=9505 loops=1)
--             -> Group aggregate: count(distinct orders.order_id), sum(tmp_field)  (actual time=2489..2654 rows=9505 loops=1)
--                 -> Sort: u.user_id, u.`name`, u.email  (actual time=2489..2517 rows=166254 loops=1)
--                     -> Stream results  (cost=9.01e+15 rows=9.01e+15) (actual time=1006..2203 rows=166254 loops=1)
--                         -> Inner hash join (oi.order_id = o.order_id)  (cost=9.01e+15 rows=9.01e+15) (actual time=1006..2074 rows=166254 loops=1)
--                             -> Table scan on oi  (cost=1.24 rows=498780) (actual time=0.0441..598 rows=500011 loops=1)
--                             -> Hash
--                                 -> Nested loop inner join  (cost=18.1e+9 rows=181e+9) (actual time=662..903 rows=29735 loops=1)
--                                     -> Inner hash join (o.user_id = u.user_id)  (cost=3.47e+6 rows=1.09e+6) (actual time=25.5..216 rows=47108 loops=1)
--                                         -> Filter: ((o.order_date >= DATE'2024-01-01') and (o.order_id is not null))  (cost=21.2 rows=3291) (actual time=0.0373..144 rows=47059 loops=1)
--                                             -> Table scan on o  (cost=21.2 rows=98749) (actual time=0.0328..121 rows=100009 loops=1)
--                                         -> Hash
--                                             -> Table scan on u  (cost=1015 rows=9910) (actual time=0.042..15.4 rows=10008 loops=1)
--                                     -> Single-row index lookup on <subquery3> using <auto_distinct_key> (order_id=o.order_id)  (cost=66895..66895 rows=1) (actual time=0.0144..0.0144 rows=0.631 loops=47108)
--                                         -> Materialize with deduplication  (cost=66895..66895 rows=166243) (actual time=637..637 rows=62961 loops=1)
--                                             -> Filter: (order_items.order_id is not null)  (cost=50271 rows=166243) (actual time=0.017..567 rows=99546 loops=1)
--                                                 -> Filter: (order_items.quantity >= 5)  (cost=50271 rows=166243) (actual time=0.0162..556 rows=99546 loops=1)
--                                                     -> Table scan on order_items  (cost=50271 rows=498780) (actual time=0.0115..485 rows=500011 loops=1)
-- -> Select #2 (subquery in projection; run only once)
--     -> Aggregate: count(0)  (cost=6582 rows=1) (actual time=47.9..47.9 rows=1 loops=1)
--         -> Filter: (p.stock < 10)  (cost=4951 rows=16313) (actual time=0.0458..47.8 rows=526 loops=1)
--             -> Table scan on p  (cost=4951 rows=48943) (actual time=0.0438..41.6 rows=50010 loops=1)
