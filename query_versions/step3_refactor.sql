use assignment2;

explain analyze
with orders_with_large_items as (
    select distinct order_id 
    from order_items use index (idx_order_items_order_id_quantity)
    where quantity >= 5
),
low_stock_count as (
    select count(*) as count 
    from products use index (idx_products_stock)
    where stock < 10
),
order_totals as (
    select order_id, sum(quantity * price) as order_total
    from order_items
    group by order_id
)
select 
    users.name as customer_name,
    users.email,
    count(distinct orders.order_id) as total_orders,
    sum(order_totals.order_total) as total_spent,
    low_stock_count.count as low_stock_products
from users
join orders on users.user_id = orders.user_id
join orders_with_large_items on orders.order_id = orders_with_large_items.order_id
join order_totals on orders.order_id = order_totals.order_id
cross join low_stock_count
where orders.order_date >= '2024-01-01'
group by users.user_id, users.name, users.email, low_stock_count.count
having total_spent > 500
order by total_spent desc;

-- -> Sort: total_spent DESC  (actual time=0.55..0.55 rows=1 loops=1)
--     -> Filter: (total_spent > 500)  (actual time=0.509..0.524 rows=1 loops=1)
--         -> Stream results  (actual time=0.507..0.52 rows=3 loops=1)
--             -> Group aggregate: count(distinct orders.order_id), sum(order_totals.order_total)  (actual time=0.501..0.508 rows=3 loops=1)
--                 -> Sort: users.user_id, users.`name`, users.email  (actual time=0.487..0.488 rows=3 loops=1)
--                     -> Stream results  (cost=5.64 rows=9) (actual time=0.353..0.44 rows=3 loops=1)
--                         -> Nested loop inner join  (cost=5.64 rows=9) (actual time=0.345..0.426 rows=3 loops=1)
--                             -> Nested loop inner join  (cost=4.24 rows=1) (actual time=0.177..0.247 rows=3 loops=1)
--                                 -> Nested loop inner join  (cost=3.89 rows=1) (actual time=0.154..0.192 rows=3 loops=1)
--                                     -> Filter: (orders_with_large_items.order_id is not null)  (cost=2.22..2.84 rows=3) (actual time=0.118..0.121 rows=3 loops=1)
--                                         -> Table scan on orders_with_large_items  (cost=3.22..4.42 rows=1.91) (actual time=0.117..0.12 rows=3 loops=1)
--                                             -> Materialize CTE orders_with_large_items  (cost=1.91..1.91 rows=1.91) (actual time=0.116..0.116 rows=3 loops=1)
--                                                 -> Group (no aggregates)  (cost=1.72 rows=1.91) (actual time=0.0776..0.0964 rows=3 loops=1)
--                                                     -> Filter: (order_items.quantity >= 5)  (cost=1.35 rows=3.67) (actual time=0.0653..0.0915 rows=3 loops=1)
--                                                         -> Covering index scan on order_items using idx_order_items_order_id_quantity  (cost=1.35 rows=11) (actual time=0.0561..0.0854 rows=11 loops=1)
--                                     -> Filter: ((orders.order_date >= DATE'2024-01-01') and (orders.user_id is not null))  (cost=0.261 rows=0.333) (actual time=0.0198..0.0226 rows=1 loops=3)
--                                         -> Index lookup on orders using idx_orders_order_id (order_id=orders_with_large_items.order_id)  (cost=0.261 rows=1) (actual time=0.018..0.0206 rows=1 loops=3)
--                                 -> Index lookup on users using idx_users_user_id (user_id=orders.user_id)  (cost=0.35 rows=1) (actual time=0.0134..0.0175 rows=1 loops=3)
--                             -> Index lookup on order_totals using <auto_key0> (order_id=orders_with_large_items.order_id)  (cost=3.7..4.05 rows=2) (actual time=0.0574..0.0584 rows=1 loops=3)
--                                 -> Materialize CTE order_totals  (cost=3.35..3.35 rows=9) (actual time=0.163..0.163 rows=9 loops=1)
--                                     -> Group aggregate: sum((order_items.quantity * order_items.price))  (cost=2.45 rows=9) (actual time=0.0527..0.127 rows=9 loops=1)
--                                         -> Index scan on order_items using idx_order_items_order_id  (cost=1.35 rows=11) (actual time=0.0267..0.0995 rows=11 loops=1)
