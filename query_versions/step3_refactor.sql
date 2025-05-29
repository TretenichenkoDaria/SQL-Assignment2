use assignment2;

explain
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
straight_join order_items
group by users.user_id, users.name, users.email, low_stock_count.count
having total_spent > 500
order by total_spent desc;
