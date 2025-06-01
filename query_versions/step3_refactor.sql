use assignment2;

explain
with orders_with_large_items as (
    select distinct order_id 
    from order_items use index (index_order_items_order_id_quantity)
    where quantity >= 5
),
low_stock_count as (
    select count(*) as count 
    from products use index (index_products_stock)
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

-- -> Sort: total_spent DESC  (actual time=3703..3705 rows=9502 loops=1)
--     -> Filter: (total_spent > 500)  (actual time=3651..3691 rows=9502 loops=1)
--         -> Stream results  (actual time=3651..3689 rows=9505 loops=1)
--             -> Group aggregate: count(distinct orders.order_id), sum(order_totals.order_total)  (actual time=3651..3682 rows=9505 loops=1)
--                 -> Sort: users.user_id, users.`name`, users.email  (actual time=3651..3656 rows=29735 loops=1)
--                     -> Stream results  (cost=554e+6 rows=5.54e+9) (actual time=2922..3589 rows=29735 loops=1)
--                         -> Nested loop inner join  (cost=554e+6 rows=5.54e+9) (actual time=2922..3566 rows=29735 loops=1)
--                             -> Nested loop inner join  (cost=96283 rows=55409) (actual time=606..1178 rows=29735 loops=1)
--                                 -> Nested loop inner join  (cost=76890 rows=55409) (actual time=606..996 rows=29706 loops=1)
--                                     -> Filter: (orders_with_large_items.order_id is not null)  (cost=76893..18705 rows=166243) (actual time=606..625 rows=62961 loops=1)
--                                         -> Table scan on orders_with_large_items  (cost=76894..78146 rows=99982) (actual time=606..617 rows=62961 loops=1)
--                                             -> Materialize CTE orders_with_large_items  (cost=76894..76894 rows=99982) (actual time=606..606 rows=62961 loops=1)
--                                                 -> Group (no aggregates)  (cost=66895 rows=99982) (actual time=0.0324..591 rows=62961 loops=1)
--                                                     -> Filter: (order_items.quantity >= 5)  (cost=50271 rows=166243) (actual time=0.027..573 rows=99546 loops=1)
--                                                         -> Covering index scan on order_items using index_order_items_order_id_quantity  (cost=50271 rows=498780) (actual time=0.02..500 rows=500011 loops=1)
--                                     -> Filter: ((orders.order_date >= DATE'2024-01-01') and (orders.user_id is not null))  (cost=0.25 rows=0.333) (actual time=0.00517..0.00568 rows=0.472 loops=62961)
--                                         -> Index lookup on orders using index_orders_order_id (order_id=orders_with_large_items.order_id)  (cost=0.25 rows=1) (actual time=0.00406..0.00517 rows=1 loops=62961)
--                                 -> Index lookup on users using index_users_user_id (user_id=orders.user_id)  (cost=0.25 rows=1) (actual time=0.00424..0.00586 rows=1 loops=29706)
--                             -> Index lookup on order_totals using <auto_key0> (order_id=orders_with_large_items.order_id)  (cost=110147..110150 rows=10) (actual time=0.0796..0.0799 rows=1 loops=29735)
--                                 -> Materialize CTE order_totals  (cost=110147..110147 rows=99982) (actual time=2316..2316 rows=99329 loops=1)
--                                     -> Group aggregate: sum((order_items.quantity * order_items.price))  (cost=100149 rows=99982) (actual time=1.28..2113 rows=99329 loops=1)
--                                         -> Index scan on order_items using index_order_items_order_id  (cost=50271 rows=498780) (actual time=1.24..1866 rows=500011 loops=1)
