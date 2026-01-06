create database session07;
use session07;

create table customers (
	id int auto_increment primary key,
	name varchar(50) not null,
    email varchar(50)
);

create table orders(
	order_id int auto_increment primary key,
    customer_id int,
    order_date date default(current_date()),
    total_amount decimal(10,2),
    
    foreign key (customer_id) references customers(id)
);

create table products(
	product_id int auto_increment primary key,
    product_name varchar(100),
    price decimal(10,2)
);

create table order_items(
	order_id int,
    product_id int,
    quantity int,
    
	primary key(order_id, product_id),
	foreign key(order_id) references orders(order_id),
	foreign key(product_id) references products(product_id)
);

insert into customers (name, email) values
	('An', 'an@example.com'),
	('Bình', 'binh@example.com'),
	('Châu', 'chau@example.com'),
	('Duy', 'duy@example.com'),
	('Hà', 'ha@example.com'),
	('Linh', 'linh@example.com'),
	('Minh', 'minh@example.com');
select * from customers;

insert into orders (customer_id, total_amount) values
	(1, 1500000),
	(2, 2000000),
	(1, 500000),
	(3, 3200000),
	(5, 900000),
	(3, 1200000),
	(6, 750000);
select * from orders;

insert into products (product_name, price) values
	('Điện thoại', 25000000),
	('Máy tính', 4500000),
	('Tủ lạnh', 9000000),
	('Sách', 28000000),
	('Đồng hồ', 8000000);
select * from products;

insert into order_items (order_id, product_id, quantity) values
	(1, 1, 1),
	(1, 2, 2),
	(2, 3, 1),
	(3, 1, 1),
	(4, 5, 2),
	(5, 2, 1);
select * from order_items;

-- bài 1
-- Lấy danh sách khách hàng đã từng đặt đơn hàng
select id, name, email from customers where id in (select distinct customer_id from orders);

-- bài 2
-- Lấy danh sách sản phẩm đã từng được bán
select * from products where product_id in (select product_id from order_items);

-- bài 3
-- danh sách đơn hàng có giá trị lớn hơn giá trị trung bình của tất cả đơn hàng
select order_id, customer_id, total_amount from orders 
where total_amount > (select avg(total_amount) from orders);

-- bài 4
-- tên khách hàng, số lượng đơn hàng của từng khách
select 
	cus.name, 
    (select count(*) from orders ord where ord.customer_id = cus.id ) as total_order -- đếm số đơn trong orders
from customers cus;

-- bài 5
-- Tìm khách hàng có tổng số tiền mua hàng lớn nhất
select name from customers
where id in (
    select customer_id from orders
    group by customer_id
    having sum(total_amount) = (
        select max(total_sum) 
        from (
            select sum(total_amount) as total_sum 
            from orders 
            group by customer_id
        ) customer_total
    )
);

-- bài 6
-- Lấy danh sách khách hàng có tổng tiền mua hàng lớn hơn tổng tiền trung bình của tất cả khách hàng
select 
    (select name from customers where customers.id = ord.customer_id) as customer_name,
    sum(ord.total_amount) as total_spent
from orders ord
group by ord.customer_id
having sum(ord.total_amount) >
(
    select avg(customer_total)
    from (
        select sum(total_amount) as customer_total
        from orders
        group by customer_id
    ) customer_total_spent
);
-- cách thầy
select id,name,email, (select sum(total_amount) from orders
where customer_id = customers.id) as 'Total_Spent'
from customers
where id in (
	select customer_id from orders
    group by customer_id
    having sum(total_amount) = (
		select max(total_spent) from (select sum(total_amount) as total_spent
        from orders group by customer_id) t
    )
);

-- cách thầy
select id,name,email,(select sum(total_amount) from orders 
where customer_id = id) as 'Total money' from customers
group by customer_id
having sum(total_amount)>=(
	select avg(total_amount) from orders
);

