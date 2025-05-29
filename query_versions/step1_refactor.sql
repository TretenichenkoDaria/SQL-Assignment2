use assignment2;

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


-- -> Sort: total_spent DESC  (actual time=1.02..1.02 rows=1 loops=1)
--     -> Filter: (total_spent > 500)  (actual time=0.824..0.842 rows=1 loops=1)
--         -> Stream results  (actual time=0.821..0.836 rows=3 loops=1)
--             -> Group aggregate: count(distinct orders.order_id), sum(tmp_field)  (actual time=0.813..0.822 rows=3 loops=1)
--                 -> Sort: users.user_id, users.`name`, users.email  (actual time=0.791..0.792 rows=4 loops=1)
--                     -> Stream results  (cost=10.2 rows=12.1) (actual time=0.543..0.664 rows=4 loops=1)
--                         -> Nested loop inner join  (cost=10.2 rows=12.1) (actual time=0.532..0.639 rows=4 loops=1)
--                             -> Inner hash join (order_items.order_id = orders.order_id)  (cost=7.35 rows=3.3) (actual time=0.409..0.48 rows=11 loops=1)
--                                 -> Table scan on order_items  (cost=0.121 rows=11) (actual time=0.0296..0.0832 rows=11 loops=1)
--                                 -> Hash
--                                     -> Inner hash join (users.user_id = orders.user_id)  (cost=3.8 rows=3) (actual time=0.229..0.271 rows=9 loops=1)
--                                         -> Table scan on users  (cost=0.117 rows=8) (actual time=0.0188..0.0504 rows=8 loops=1)
--                                         -> Hash
--                                             -> Filter: ((orders.order_date >= DATE'2024-01-01') and (orders.order_id is not null))  (cost=1.15 rows=3) (actual time=0.0394..0.0856 rows=9 loops=1)
--                                                 -> Table scan on orders  (cost=1.15 rows=9) (actual time=0.0361..0.0742 rows=9 loops=1)
--                             -> Covering index lookup on orders_with_large_items using <auto_key0> (order_id=orders.order_id)  (cost=4.9..5.18 rows=2) (actual time=0.0129..0.0133 rows=0.364 loops=11)
--                                 -> Materialize CTE orders_with_large_items  (cost=4.62..4.62 rows=3.67) (actual time=0.114..0.114 rows=3 loops=1)
--                                     -> Table scan on <temporary>  (cost=2.41..4.25 rows=3.67) (actual time=0.0889..0.09 rows=3 loops=1)
--                                         -> Temporary table with deduplication  (cost=1.72..1.72 rows=3.67) (actual time=0.0873..0.0873 rows=3 loops=1)
--                                             -> Filter: (order_items.quantity >= 5)  (cost=1.35 rows=3.67) (actual time=0.0214..0.0525 rows=3 loops=1)
--                                                 -> Table scan on order_items  (cost=1.35 rows=11) (actual time=0.0152..0.0468 rows=11 loops=1)
