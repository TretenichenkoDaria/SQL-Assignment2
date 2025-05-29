use assignment2;

create index idx_orders_user_id_order_date on orders(user_id, order_date);
create index idx_order_items_order_id_quantity on order_items(order_id, quantity);
create index idx_products_stock on products(stock);
create index idx_users_user_id on users(user_id);
create index idx_orders_order_id on orders(order_id);
create index idx_order_items_order_id on order_items(order_id);
create index idx_products_product_id on products(product_id);

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