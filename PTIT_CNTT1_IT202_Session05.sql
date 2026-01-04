create database session05;
use session05;

-- bài 1
create table products (
	product_id int auto_increment primary key,
    product_name varchar(255),
    price decimal(10,2),
    stock int,
    status enum('active', 'inactive')
);

insert into products(product_name, price, stock, status) values
	('Máy lạnh', 20000000, 6, 'active'),
    ('Điện thoại', 30000000, 1, 'active'),
    ('Laptop', 15000000, 10, 'inactive'),
    ('Bút chì', 10000, 2, 'active'),
    ('Tai nghe', 600000, 13, 'inactive');
    

select * from products;
select * from products where status = 'active';
select * from products where price > 1000000;
select * from products where status = 'active' order by price asc;  

-- bài 2
create table customers (
	customer_id int auto_increment primary key,
    full_name varchar(255),
	email varchar(255),
    city varchar(255),
    status enum ('active', 'inactive')
);

insert into customers(full_name, email, city, status) values
	( 'Nguyễn Văn A', 'a@gmail.com', 'Hà Nội', 'active'),
    ('Trần Thị B', 'b@gmail.com', 'Đà Nẵng', 'active'),
    ('Lê Văn C','c@gmail.com', 'Hà Nội', 'active'),
    ('Phạm Thị D','d@gmail.com', 'TP.HCM', 'active'),
    ( 'Hoàng Văn E', 'e@gmail.com', 'TP.HCM', 'inactive');
    
select * from customers;
select * from customers where city = 'TP.HCM';
select * from customers where status = 'active' and city = 'Hà Nội';
select * from customers order by full_name asc;

-- bài 3
create table orders (
	order_id int auto_increment primary key,
    customer_id int,
    total_amount decimal(10,2),
    order_date date,
    status enum('pending', 'completed', 'cancelled'),
    
    foreign key (customer_id) references customers(customer_id)
);

insert into orders(customer_id, total_amount, order_date, status) values
	(1, 2000000, '2023-11-19', 'completed'),
    (1, 30000000, '2025-12-05', 'pending'),
    (3, 100000, '2025-08-01', 'cancelled'),
    (2, 1300000, '2025-12-29', 'completed');

select * from orders where status = 'completed';
select * from orders where total_amount > 5000000;
select * from orders order by order_date desc limit 5 offset 0;   -- 5 đơn hàng mới nhất
select * from orders where status = 'completed' order by total_amount desc;

-- bài 4
alter table products
add sold_quantity int default 0;

-- 10 sp bán chạy nhất
select * from products order by sold_quantity desc limit 10 offset 0;
-- 5 sp bán chạy tiếp theo
select * from products order by sold_quantity desc limit 5 offset 10;
select * from products where price < 2000000 order by sold_quantity desc;

-- bài 5
select * from orders where status <> 'cancelled'
order by order_date desc limit 5 offset 0;
select * from orders where status <> 'cancelled'
order by order_date desc limit 5 offset 5;
select * from orders where status <> 'cancelled'
order by order_date desc limit 5 offset 10;

-- bài 6
-- trang 1
select * from products where status = 'active' and price BETWEEN 1000000 and 3000000
order by price asc limit 10 offset 0;

-- trang 2
select * from products where status = 'active' and price BETWEEN 1000000 and 3000000
order by price asc limit 10 offset 10;

