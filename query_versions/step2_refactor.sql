use assignment2;

create index index_orders_user_id_order_date on orders(user_id, order_date);
create index index_order_items_order_id_quantity on order_items(order_id, quantity);
create index index_products_stock on products(stock);
create index index_users_user_id on users(user_id);
create index index_orders_order_id on orders(order_id);
create index index_order_items_order_id on order_items(order_id);
create index index_products_product_id on products(product_id);

explain
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

-- -> Sort: total_spent DESC  (actual time=3063..3064 rows=9502 loops=1)
--     -> Filter: (total_spent > 500)  (actual time=2873..3050 rows=9502 loops=1)
--         -> Stream results  (actual time=2873..3048 rows=9505 loops=1)
--             -> Group aggregate: count(distinct orders.order_id), sum(tmp_field)  (actual time=2873..3040 rows=9505 loops=1)
--                 -> Sort: users.user_id, users.`name`, users.email  (actual time=2873..2901 rows=166254 loops=1)
--                     -> Stream results  (cost=193029 rows=276418) (actual time=734..2540 rows=166254 loops=1)
--                         -> Nested loop inner join  (cost=193029 rows=276418) (actual time=734..2300 rows=166254 loops=1)
--                             -> Nested loop inner join  (cost=96283 rows=55409) (actual time=734..1410 rows=29735 loops=1)
--                                 -> Nested loop inner join  (cost=76890 rows=55409) (actual time=734..1222 rows=29706 loops=1)
--                                     -> Filter: (orders_with_large_items.order_id is not null)  (cost=76893..18705 rows=166243) (actual time=734..757 rows=62961 loops=1)
--                                         -> Table scan on orders_with_large_items  (cost=76894..78146 rows=99982) (actual time=734..747 rows=62961 loops=1)
--                                             -> Materialize CTE orders_with_large_items  (cost=76894..76894 rows=99982) (actual time=734..734 rows=62961 loops=1)
--                                                 -> Group (no aggregates)  (cost=66895 rows=99982) (actual time=0.445..718 rows=62961 loops=1)
--                                                     -> Filter: (order_items.quantity >= 5)  (cost=50271 rows=166243) (actual time=0.434..701 rows=99546 loops=1)
--                                                         -> Covering index scan on order_items using index_order_items_order_id_quantity  (cost=50271 rows=498780) (actual time=0.419..625 rows=500011 loops=1)
--                                     -> Filter: ((orders.order_date >= DATE'2024-01-01') and (orders.user_id is not null))  (cost=0.25 rows=0.333) (actual time=0.00651..0.00714 rows=0.472 loops=62961)
--                                         -> Index lookup on orders using index_orders_order_id (order_id=orders_with_large_items.order_id)  (cost=0.25 rows=1) (actual time=0.00514..0.00652 rows=1 loops=62961)
--                                 -> Index lookup on users using index_users_user_id (user_id=orders.user_id)  (cost=0.25 rows=1) (actual time=0.00498..0.00609 rows=1 loops=29706)
--                             -> Index lookup on order_items using index_order_items_order_id_quantity (order_id=orders_with_large_items.order_id)  (cost=1.25 rows=4.99) (actual time=0.00757..0.029 rows=5.59 loops=29735)
