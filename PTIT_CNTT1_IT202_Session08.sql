create database session08;
use session08;

create table customers(
	customer_id int auto_increment primary key,
    customer_name varchar(100) not null,
    email varchar(100) not null unique,
    phone varchar(10) not null unique
);

-- danh mục sản phẩm
create table categories(
	category_id int auto_increment primary key,
    category_name varchar(255) not null unique
);

-- sản phẩm trong danh mục
create table products(
	product_id int auto_increment primary key,
    product_name varchar(255) not null unique,
    price decimal(10,2) not null check(price > 0),
    category_id int,
    
    foreign key (category_id) references categories(category_id)
);

create table orders(
	order_id int auto_increment primary key,
    customer_id int,
    order_date datetime,
    status enum('Pending','Completed','Cancel') default 'Pending',
    
    foreign key (customer_id) references customers(customer_id)
);

create table order_items(
	order_item_id int auto_increment primary key,
    order_id int,
    product_id int,
    quantity int not null check(quantity > 0),
    
    foreign key (order_id) references orders(order_id),
    foreign key (product_id) references products(product_id)
);

insert into customers(customer_name, email, phone) values
	('Nguyen An', 'an@example.com', '0919565431'),
	('Le Binh', 'binh@example.com', '0294729571'),
	('Tran Chau', 'chau@example.com', '0927561845'),
	('Pham Duy', 'duy@example.com', '0994716582'),
	('Vo Ha', 'ha@example.com', '0918375524'),
	('Hoang Linh', 'linh@example.com', '0974904273');

insert into categories(category_name) values
	('Smartphone'),
	('Laptop'),
	('Accessories'),
	('Home Appliance');
    
insert into products(product_name, price, category_id) values
	('iPhone 15', 25000000, 1),
	('Samsung Galaxy S23', 22000000, 1),
	('MacBook Air M2', 32000000, 2),
	('Dell Inspiron 5515', 21000000, 2),
	('AirPods Pro', 6500000, 3),
	('LG Washing Machine', 8500000, 4);
    
insert into orders(customer_id, status) values
	(1, 'Completed'),
	(2, 'Pending'),
	(1, 'Completed'),
	(3, 'Cancel'),
	(4, 'Completed'),
	(5, 'Pending');
    
insert into order_items(order_id, product_id, quantity) values
	(1, 1, 1),   
	(1, 5, 2),   
	(2, 2, 1),  
	(3, 3, 1),  
	(4, 6, 1),  
	(5, 4, 1),  
	(6, 5, 1);

-- Phần A
-- Lấy danh sách tất cả danh mục sản phẩm trong hệ thống.
select * from categories;
-- Lấy danh sách đơn hàng có trạng thái là COMPLETED
select * from orders where status = 'Completed';
-- Lấy danh sách sản phẩm và sắp xếp theo giá giảm dần
select * from products order by price desc;
-- Lấy 5 sản phẩm có giá cao nhất, bỏ qua 2 sản phẩm đầu tiên
select * from products order by price desc limit 5 offset 2;

-- Phần B
-- Lấy danh sách sản phẩm kèm tên danh mục
select 
	pro.product_id, 
    pro.product_name, 
    pro.price, 
    cat.category_name
from products pro
join categories cat on cat.category__id = pro.category_id;

-- Lấy danh sách đơn hàng gồm: order_id, order_date, customer_name, status
select
	ord.order_id,
    ord.order_date,
    ord.status,
    cus.customer_name
from orders ord
join customers cus on ord.customer_id = cus.customer_id;

-- Tính tổng số lượng sản phẩm trong từng đơn hàng
select 
	order_id,
    sum(quantity) as total_item
from order_items group by order_id;

-- Thống kê số đơn hàng của mỗi khách hàng
select
	customer_id,
    count(*) as customer_total_order
from orders group by customer_id;

-- Lấy danh sách khách hàng có tổng số đơn hàng ≥ 2
select
	customer_id,
    count(*) as customer_total_order
from orders group by customer_id having customer_total_order >= 2;

-- Thống kê giá trung bình, thấp nhất và cao nhất của sản phẩm theo danh mục
select
	cat.category_name,
    avg(pro.price) as avg_price,
    max(pro.price) as max_price,
    min(pro.price) as min_price
from products pro
join categories cat on pro.category_id = cat.category_id
group by cat.category_id, cat.category_name;

-- Phần 3
-- Lấy danh sách sản phẩm có giá cao hơn giá trung bình của tất cả sản phẩm
select * from products where price > (select avg(price) from products);

-- Lấy danh sách khách hàng đã từng đặt ít nhất một đơn hàng
select * from customers where customer_id in( select distinct customer_id from orders);

-- Lấy đơn hàng có tổng số lượng sản phẩm lớn nhất
select order_id from order_items group by order_id
having sum(quantity) = (
	select max(total_quantity)
    from (select sum(quantity) as total_quantity from order_items group by order_id) order_max_quantity
    );


-- Lấy tên khách hàng đã mua sản phẩm thuộc danh mục có giá trung bình cao nhất
-- Tìm danh mục có giá trung bình cao nhất
-- Tìm sản phẩm thuộc danh mục đó
-- Tìm khách đã mua sản phẩm đó
select cus.customer_name
from customers cus
where cus.customer_id in (
    select ord.customer_id
    from orders ord
    where ord.order_id in (
        select ord_item.order_id
        from order_items ord_item
        where ord_item.product_id in (
            select pro.product_id from products pro
            where pro.category_id = (
                select category_id
                from (
                    select category_id, avg(price) as avg_price
                    from products group by category_id
                    order by avg_price desc limit 1
                ) top_category
            )
        )
    )
);

-- Từ bảng tạm (subquery), thống kê tổng số lượng sản phẩm đã mua của từng khách hàng
select
    ord.customer_id,
    sum(ord_item.quantity) as total_quantity
from orders ord
join order_items ord_item on ord.order_id = ord_item.order_id
group by ord.customer_id;

-- Viết lại truy vấn lấy sản phẩm có giá cao nhất, đảm bảo:
-- Subquery chỉ trả về một giá trị
-- Không gây lỗi “Subquery returns more than 1 row”
select * from products where price = (
    select max(price) from products
);



