create database session06;
use session06;

create table customers (
	customer_id int auto_increment primary key,
    full_name varchar(255) not null,
    city varchar(255) not null
);

create table orders (
	order_id int auto_increment primary key,
    customer_id int,
    order_date date,
    status enum('pending', 'completed', 'cancelled'),
    
    foreign key (customer_id) references customers(customer_id)
);

create table products (
	product_id int auto_increment primary key,
    product_name varchar(255) not null,
    price decimal(10,2)
);

create table order_items (
	order_id int,
    product_id int,
    quantity int,
    
    primary key(order_id, product_id),
    foreign key (product_id) references products(product_id),
    foreign key (order_id) references orders(order_id)
);

insert into customers(full_name, city) values
	('Nguyễn Văn A', 'Hà Nội'),
    ('Nguyễn Lâm Anh', 'TP Hồ Chí Minh'),
    ('Nguyễn Vân Giang', 'Hà Nội'),
    ('Trần Thị B', 'Đà Nẵng'),
    ('Lê Văn C', 'Huế');
select * from customers;
    
insert into orders (customer_id, order_date, status) values
	(1, '2025-01-01', 'completed'),
	(2, '2025-01-03', 'completed'),
	(1, '2025-01-04', 'completed'),
	(3, '2025-01-05', 'completed'),
	(4, '2025-01-06', 'completed');
select * from orders;

insert into products (product_name, price) values
	('Điện thoại', 25000000),
	('Máy tính', 4500000),
	('Tủ lạnh', 9000000),
	('Sách', 28000000),
	('Đồng hồ', 8000000);
    
insert into order_items (order_id, product_id, quantity) values
	(1, 1, 1),
	(1, 2, 2),
	(2, 3, 1),
	(3, 1, 1),
	(4, 5, 2),
	(5, 2, 1);

-- bài 1
-- hiện danh sách đơn kèm tên khách
select 
	ord.order_id,
    ord.order_date,
    ord.status,
    cus.full_name
from orders ord
join customers cus on ord.customer_id = cus.customer_id;

-- hiển thị mỗi khách hàng đặt bao đơn hàng
select 
	cus.customer_id,
    cus.full_name,
    count(ord.order_id) as 'total_order' 
from customers cus
left join orders ord on ord.customer_id = cus.customer_id
group by cus.full_name, cus.customer_id;

-- chỉ hiện khách hàng có ít nhất 1 đơn
select
	cus.customer_id,
    cus.full_name,
    count(ord.order_id) as 'total_order'
from customers cus
join orders ord on cus.customer_id = ord.customer_id
group by cus.customer_id, cus.full_name
having count(ord.order_id) >= 1;

-- bài 2 
alter table orders
add total_amount decimal(10,2) default 0;

-- thêm thông tin vào bảng
update orders set total_amount = 500000 where order_id = 1;
update orders set total_amount = 120000 where order_id = 2;
update orders set total_amount = 1000000 where order_id = 3;
update orders set total_amount = 3000000 where order_id = 4;
update orders set total_amount = 0 where order_id = 5;

-- Hiển thị tổng tiền mà mỗi khách hàng đã chi tiêu
select
	cus.customer_id,
    cus.full_name,
    sum(ord.total_amount) as tong_tien
from customers cus
join orders ord on ord.customer_id = cus.customer_id
group by cus.customer_id, cus.full_name;

-- Hiển thị giá trị đơn hàng cao nhất của từng khách
select
	cus.customer_id,
    cus.full_name,
    max(ord.total_amount) as 'Đơn cao nhất'
from customers cus
join orders ord on ord.customer_id = cus.customer_id
group by cus.customer_id, cus.full_name;

-- Sắp xếp danh sách khách hàng theo tổng tiền giảm dần
select
	cus.customer_id,
    cus.full_name,
    sum(ord.total_amount) as tong_tien
from customers cus
join orders ord on ord.customer_id = cus.customer_id
group by cus.customer_id, cus.full_name
order by tong_tien desc;

-- bài 3
-- tổng doanh thu theo từng ngày
select 
	order_date, 
    sum(total_amount) as daily_amount
from orders
group by order_date;

-- số lượng đơn hàng theo từng ngày
select 
	order_date, 
    count(order_id) as total_orders
from orders
group by order_date;

-- Chỉ hiển thị các ngày có doanh thu > 10.000.000
select 
	order_date, 
    sum(total_amount) as daily_amount
from orders
group by order_date
having daily_amount > 10000000;

-- bài 4
-- Hiển thị mỗi sản phẩm đã bán được bao nhiêu sản phẩm
select
	pro.product_id,
    pro.product_name,
    sum(ord_item.quantity) as total_product
from products pro
join order_items ord_item on pro.product_id = ord_item.product_id
group by pro.product_id, pro.product_name;

-- Tính doanh thu của từng sản phẩm
select 
	pro.product_id,
    pro.product_name,
    sum(ord_item.quantity) as total_sold,
    sum((ord_item.quantity) * pro.price) as doanh_thu
from products pro
join order_items ord_item on pro.product_id = ord_item.product_id
group by pro.product_id, pro.product_name;

-- Chỉ hiển thị các sản phẩm có doanh thu > 5.000.000
select 
	pro.product_id,
    pro.product_name,
    sum(ord_item.quantity) as total_sold,
    sum((ord_item.quantity) * pro.price) as doanh_thu
from products pro
join order_items ord_item on pro.product_id = ord_item.product_id
group by pro.product_id, pro.product_name
having doanh_thu > 5000000;

-- bài 5
select 
    cus.customer_id,
    cus.full_name,
    count(ord.order_id) as total_orders,  -- tổng số đơn mỗi khách
    sum(ord.total_amount) as total_spent, -- tổng số tiền đã chi
    avg(ord.total_amount) as avg_order_value  -- giá trị đơn hàng trung bình
from customers cus
join orders ord on cus.customer_id = ord.customer_id
group by cus.customer_id, cus.full_name
having count(ord.order_id) >= 3 and sum(ord.total_amount) > 10000000
order by total_spent desc;

-- bài 6
select
    pro.product_name,
    sum(ord_item.quantity) as total_sold,  -- tổng số lượng bán
    sum(ord_item.quantity * pro.price) as doanh_thu,  -- tổng doanh thu
    sum(ord_item.quantity * pro.price) / sum(ord_item.quantity) as avg_price -- Giá bán trung bình
from products pro
join order_items ord_item  on pro.product_id = ord_item.product_id
group by pro.product_id, pro.product_name
having sum(ord_item.quantity) >= 10
order by doanh_thu desc limit 5 offset 0;

