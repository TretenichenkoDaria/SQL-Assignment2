use assignment2;

create index idx_orders_user_id_order_date on orders(user_id, order_date);
create index idx_order_items_order_id_quantity on order_items(order_id, quantity);
create index idx_products_stock on products(stock);
create index idx_users_user_id on users(user_id);
create index idx_orders_order_id on orders(order_id);
create index idx_order_items_order_id on order_items(order_id);
create index idx_products_product_id on products(product_id);

explain analyze
with orders_with_large_items as (
    select distinct order_id 
    from order_items 
    where quantity >= 5
),
low_stock_count as (
    select count(*) as count 
    from products 
    where stock < 10
)
select 
    users.name as customer_name,
    users.email,
    count(distinct orders.order_id) as total_orders,
    sum(order_items.quantity * order_items.price) as total_spent,
    low_stock_count.count as low_stock_products
from users
join orders on users.user_id = orders.user_id
join orders_with_large_items on orders.order_id = orders_with_large_items.order_id
join order_items on orders.order_id = order_items.order_id
cross join low_stock_count
where orders.order_date >= '2024-01-01'
group by users.user_id, users.name, users.email, low_stock_count.count
having total_spent > 500
order by total_spent desc;

-- -> Sort: total_spent DESC  (actual time=0.374..0.374 rows=1 loops=1)
--     -> Filter: (total_spent > 500)  (actual time=0.327..0.34 rows=1 loops=1)
--         -> Stream results  (actual time=0.325..0.336 rows=3 loops=1)
--             -> Group aggregate: count(distinct orders.order_id), sum(tmp_field)  (actual time=0.319..0.326 rows=3 loops=1)
--                 -> Sort: users.user_id, users.`name`, users.email  (actual time=0.304..0.306 rows=4 loops=1)
--                     -> Stream results  (cost=4.67 rows=1.22) (actual time=0.175..0.273 rows=4 loops=1)
--                         -> Nested loop inner join  (cost=4.67 rows=1.22) (actual time=0.167..0.254 rows=4 loops=1)
--                             -> Nested loop inner join  (cost=4.24 rows=1) (actual time=0.152..0.204 rows=3 loops=1)
--                                 -> Nested loop inner join  (cost=3.89 rows=1) (actual time=0.133..0.162 rows=3 loops=1)
--                                     -> Filter: (orders_with_large_items.order_id is not null)  (cost=2.22..2.84 rows=3) (actual time=0.102..0.105 rows=3 loops=1)
--                                         -> Table scan on orders_with_large_items  (cost=3.22..4.42 rows=1.91) (actual time=0.101..0.103 rows=3 loops=1)
--                                             -> Materialize CTE orders_with_large_items  (cost=1.91..1.91 rows=1.91) (actual time=0.0999..0.0999 rows=3 loops=1)
--                                                 -> Group (no aggregates)  (cost=1.72 rows=1.91) (actual time=0.0552..0.0749 rows=3 loops=1)
--                                                     -> Filter: (order_items.quantity >= 5)  (cost=1.35 rows=3.67) (actual time=0.0453..0.0713 rows=3 loops=1)
--                                                         -> Covering index scan on order_items using idx_order_items_order_id_quantity  (cost=1.35 rows=11) (actual time=0.0371..0.066 rows=11 loops=1)
--                                     -> Filter: ((orders.order_date >= DATE'2024-01-01') and (orders.user_id is not null))  (cost=0.261 rows=0.333) (actual time=0.0163..0.0186 rows=1 loops=3)
--                                         -> Index lookup on orders using idx_orders_order_id (order_id=orders_with_large_items.order_id)  (cost=0.261 rows=1) (actual time=0.0147..0.0168 rows=1 loops=3)
--                                 -> Index lookup on users using idx_users_user_id (user_id=orders.user_id)  (cost=0.35 rows=1) (actual time=0.011..0.0132 rows=1 loops=3)
--                             -> Index lookup on order_items using idx_order_items_order_id_quantity (order_id=orders_with_large_items.order_id)  (cost=0.428 rows=1.22) (actual time=0.0095..0.0157 rows=1.33 loops=3)
