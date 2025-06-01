use assignment2;

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


-- -> Sort: total_spent DESC  (actual time=3253..3255 rows=9502 loops=1)
--     -> Filter: (total_spent > 500)  (actual time=3067..3241 rows=9502 loops=1)
--         -> Stream results  (actual time=3067..3239 rows=9505 loops=1)
--             -> Group aggregate: count(distinct orders.order_id), sum(tmp_field)  (actual time=3067..3231 rows=9505 loops=1)
--                 -> Sort: users.user_id, users.`name`, users.email  (actual time=3067..3095 rows=166254 loops=1)
--                     -> Stream results  (cost=906e+12 rows=9.01e+15) (actual time=983..2757 rows=166254 loops=1)
--                         -> Nested loop inner join  (cost=906e+12 rows=9.01e+15) (actual time=983..2587 rows=166254 loops=1)
--                             -> Inner hash join (order_items.order_id = orders.order_id)  (cost=54.3e+9 rows=54.2e+9) (actual time=303..1450 rows=235899 loops=1)
--                                 -> Table scan on order_items  (cost=1.23 rows=498780) (actual time=0.043..630 rows=500011 loops=1)
--                                 -> Hash
--                                     -> Inner hash join (orders.user_id = users.user_id)  (cost=3.47e+6 rows=1.09e+6) (actual time=24.5..211 rows=47108 loops=1)
--                                         -> Filter: ((orders.order_date >= DATE'2024-01-01') and (orders.order_id is not null))  (cost=21.2 rows=3291) (actual time=0.0434..140 rows=47059 loops=1)
--                                             -> Table scan on orders  (cost=21.2 rows=98749) (actual time=0.0383..118 rows=100009 loops=1)
--                                         -> Hash
--                                             -> Table scan on users  (cost=1015 rows=9910) (actual time=0.0351..15.6 rows=10008 loops=1)
--                             -> Covering index lookup on orders_with_large_items using <auto_key0> (order_id=orders.order_id)  (cost=85600..85603 rows=10) (actual time=0.00435..0.00455 rows=0.705 loops=235899)
--                                 -> Materialize CTE orders_with_large_items  (cost=85600..85600 rows=166243) (actual time=680..680 rows=62961 loops=1)
--                                     -> Table scan on <temporary>  (cost=66895..68976 rows=166243) (actual time=612..618 rows=62961 loops=1)
--                                         -> Temporary table with deduplication  (cost=66895..66895 rows=166243) (actual time=611..611 rows=62961 loops=1)
--                                             -> Filter: (order_items.quantity >= 5)  (cost=50271 rows=166243) (actual time=0.0198..542 rows=99546 loops=1)
--                                                 -> Table scan on order_items  (cost=50271 rows=498780) (actual time=0.0118..473 rows=500011 loops=1)
