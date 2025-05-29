create database assignment2;
use assignment2;

create table users (
    user_id int,
    name varchar(100),
    email varchar(100),
    created_at date
);

create table categories (
    category_id int,
    name varchar(100)
);

create table products (
    product_id int,
    category_id int,
    name varchar(100),
    stock int
);

create table orders (
    order_id int,
    user_id int,
    order_date date,
    total_amount decimal(10, 2)
);

create table order_items (
    order_item_id int,
    order_id int,
    product_id int,
    quantity int,
    price decimal(10, 2)
);

insert into users values
(1, 'alice', 'alice@example.com', '2023-05-10'),
(2, 'bob', 'bob@example.com', '2023-06-15'),
(3, 'charlie', 'charlie@example.com', '2023-07-20'),
(4, 'diana', 'diana@example.com', '2023-08-05'),
(5, 'eve', 'eve@example.com', '2023-09-10'),
(6, 'frank', 'frank@example.com', '2023-10-22'),
(7, 'grace', 'grace@example.com', '2023-11-01'),
(8, 'henry', 'henry@example.com', '2023-12-12');

insert into categories values
(1, 'electronics'),
(2, 'books'),
(3, 'home appliances'),
(4, 'clothing');

insert into products values
(1, 1, 'smartphone', 5),
(2, 1, 'laptop', 20),
(3, 2, 'novel', 8),
(4, 2, 'comics', 3),
(5, 3, 'microwave', 15),
(6, 3, 'toaster', 2),
(7, 4, 't-shirt', 30),
(8, 4, 'jeans', 12),
(9, 1, 'tablet', 0),
(10, 3, 'vacuum cleaner', 9);

insert into orders values
(101, 1, '2024-01-05', 1200.00),
(102, 1, '2024-03-12', 300.00),
(103, 2, '2024-04-01', 450.00),
(104, 3, '2024-02-15', 600.00),
(105, 4, '2024-04-10', 100.00),
(106, 5, '2024-05-05', 950.00),
(107, 6, '2024-01-20', 200.00),
(108, 7, '2024-03-05', 1100.00),
(109, 8, '2024-03-25', 250.00);

insert into order_items values
(1001, 101, 1, 2, 500.00),
(1002, 101, 3, 5, 40.00),
(1003, 102, 2, 1, 300.00),
(1004, 103, 1, 1, 500.00),
(1005, 104, 4, 6, 50.00),
(1006, 105, 7, 2, 30.00),
(1007, 106, 2, 3, 300.00),
(1008, 107, 5, 1, 200.00),
(1009, 108, 1, 1, 500.00),
(1010, 108, 9, 2, 300.00),
(1011, 109, 6, 5, 50.00);

