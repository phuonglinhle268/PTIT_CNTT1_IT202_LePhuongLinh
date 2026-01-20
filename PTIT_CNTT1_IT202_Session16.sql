create database quanlybanhang;
use quanlybanhang;

create table Customers(
	customer_id int auto_increment primary key,
    customer_name varchar(100) not null,
    phone varchar(20) unique not null,
    address varchar(255)
);

create table Products(
	product_id int auto_increment primary key,
    product_name varchar(100) unique not null,
    price decimal(10,2) not null,
    quantity int not null check(quantity >= 0),
    category varchar(50) not null
);

create table Employees(
	employee_id int auto_increment primary key,
    employee_name varchar(100) not null,
    birthday date,
    position varchar(50) not null,
    salary decimal(10,2) not null,
    revenue decimal(10,2) default 0  -- Tổng doanh thu do nhân viên quản lý
);

create table Orders(
	order_id int auto_increment primary key,
    customer_id int not null,
    employee_id int not null,
    order_date datetime default current_timestamp,
    total_amount decimal(10,2) default 0,    --  Tổng tiền đơn hàng
    
    foreign key(customer_id) references Customers(customer_id),
    foreign key(employee_id) references Employees(employee_id)
);

create table OrderDetails(
	order_detail_id int auto_increment primary key,
    order_id int not null,
    product_id int not null,
    quantity int not null check(quantity>0),
    unit_price decimal(10,2) not null,
    
    foreign key(order_id) references Orders(order_id),
    foreign key(product_id) references Products(product_id)
);

select * from Customers;
select * from Products;
select * from Orders;
select * from Employees;
select * from OrderDetails;

alter table Customers
add email varchar(100) not null unique;
alter table Employees drop column birthday;

-- câu 4: chèn dữ liệu
insert into Customers(customer_name, phone, address, email) values
	('nguyen van a', '0901111111', 'ha noi', 'a@gmail.com'),
	('tran thi b', '0902222222', 'hai phong', 'b@gmail.com'),
	('le van c', '0903333333', 'da nang', 'c@gmail.com'),
	('pham thi d', '0904444444', 'tp hcm', 'd@gmail.com'),
	('hoang van e', '0905555555', 'can tho', 'e@gmail.com');

insert into Products(product_name, price, quantity, category) values
	('laptop dell', 15000000, 10, 'electronics'),
	('iphone 14', 20000000, 8, 'electronics'),
	('chuot logitech', 500000, 50, 'accessories'),
	('ban phim co', 1200000, 30, 'accessories'),
	('man hinh samsung', 4000000, 15, 'electronics');

insert into Employees(employee_name, position, salary, revenue) values
	('nguyen van nam', 'sales', 8000000, 0),
	('tran thi hoa', 'sales', 8500000, 0),
	('le van long', 'manager', 15000000, 0),
	('pham thi lan', 'sales', 8200000, 0),
	('hoang van minh', 'accountant', 10000000, 0);

insert into Orders(customer_id, employee_id, total_amount) values
	(1, 1, 15500000),
	(2, 2, 20000000),
	(3, 1, 1700000),
	(4, 4, 4000000),
	(5, 3, 15000000);

insert into OrderDetails(order_id, product_id, quantity, unit_price) values
	(1, 1, 1, 15000000),
	(1, 3, 1, 500000),
	(2, 2, 1, 20000000),
	(3, 4, 1, 1200000),
	(3, 3, 1, 500000),
	(4, 5, 1, 4000000),
	(5, 1, 1, 15000000);
    
-- câu 5: truy vấn cơ bản
update Products
set product_name = 'Laptop Dell XPS', price = 99.99 where product_id = 1;

-- select o.order_id,
--        c.customer_name,
--        e.employee_name,
--        o.total_amount,
--        o.order_date
-- from Orders o
-- join Customers c on o.customer_id = c.customer_id
-- join Employees e on o.employee_id = e.employee_id;

-- câu 6
-- Đếm số lượng đơn hàng của mỗi khách hàng
select 
	c.customer_id, c.customer_name,
    count(o.order_id) as total_orders
from Customers c left join Orders o on c.customer_id = o.customer_id
group by c.customer_id, c.customer_name;

-- Thống kê tổng doanh thu của từng nhân viên trong năm hiện tại
select
	e.employee_id, e.employee_name,
    sum(o.total_amount) as total_revenue
from Employees e join Orders o on e.employee_id = o.employee_id
where year(o.order_date) = year(curdate()) group by e.employee_id, e.employee_name;

-- Thống kê những sản phẩm có số lượng đặt hàng lớn hơn 100 trong tháng hiện tại.
-- Thông tin gồm : mã sản phẩm, tên sản phẩm, số lượt đặt và sắp xếp theo số lượng giảm dần
select
	p.product_id, p.product_name,
    sum(od.quantity) as total_quantity
from Products p 
join OrderDetails od on p.product_id = od.product_id
join orders o on od.order_id = o.order_id 
where month(o.order_date) = month(curdate()) and year(o.order_date) = year(curdate())
group by p.product_id, p.product_name having total_quantity > 100 order by total_quantity desc;

-- Câu 7 - Truy vấn nâng cao
-- Lấy danh sách khách hàng chưa từng đặt hàng
select c.customer_id, c.customer_name from Customers c
left join Orders o on c.customer_id = o.customer_id where o.order_id is null;

-- Lấy danh sách sản phẩm có giá cao hơn giá trung bình của tất cả sản phẩm
select product_id, product_name, price from Products where price > (select avg(price) from Products);

-- Tìm những khách hàng có mức chi tiêu cao nhất
select
	c.customer_id, c.customer_name,
    sum(o.total_amount) as total_spent
from Customers c join Orders o on c.customer_id = o.customer_id 
group by c.customer_id, c.customer_name
having sum(o.total_amount) = (
	select max(total_spent) from ( 
		select sum(total_amount) as total_spent from orders group by customer_id) max_total );

-- câu 8: tạo view
-- Tạo view có tên view_order_list hiển thị thông tin đơn hàng
create or replace view view_order_list as
select
	o.order_id,
	c.customer_name,
    e.employee_name,
    o.total_amount,
    o.order_date
from Orders o
join customers c on o.customer_id = c.customer_id
join employees e on o.employee_id = e.employee_id
order by o.order_date desc;

-- Tạo view có tên view_order_detail_product hiển thị chi tiết đơn hàng 
create or replace view view_order_detail_product as
select 
	od.order_detail_id,
    p.product_name,
    od.quantity,
    od.unit_price
from OrderDetails od join Products p on p.product_id = od.product_id
order by od.quantity desc;

-- Câu 9 - Tạo thủ tục lưu trữ
-- Tạo thủ tục có tên proc_insert_employee nhận vào các thông tin cần thiết 
-- thực hiện thêm mới dữ liệu vào bảng nhân viên và trả về mã nhân viên vừa mới thêm.
delimiter //
create procedure proc_insert_employee(
	 in p_employee_name varchar(100),
     in p_position varchar(50),
     in p_salary decimal(10,2),
     out p_employee_id int
)
begin
	insert into Employees(employee_name, position, salary) values (p_employee_name, p_position, p_salary);
    set p_employee_id = last_insert_id();
end //
delimiter ;

-- Tạo thủ tục có tên proc_get_orderdetails lọc những chi tiết đơn hàng dựa theo mã đặt hàng
delimiter //
create procedure proc_get_orderdetails(
	in p_order_id int
)
begin
	select * from OrderDetails where p_order_id = order_id;
end //
delimiter ;

-- Tạo thủ tục có tên proc_cal_total_amount_by_order nhận vào tham số là mã, đơn hàng
-- trả về số lượng loại sản phẩm trong đơn hàng đó.
delimiter //
create procedure proc_cal_total_amount_by_order(
	in p_order_id int,
    out p_total_products int
)
begin
	select count(distinct product_id) into p_total_products from OrderDetails
    where p_order_id = order_id;
end //
delimiter ;
    
-- câu 10: trigger
-- Tạo trigger có tên trigger_after_insert_order_details để tự động cập nhật số lượng
-- sản phẩm trong kho mỗi khi thêm một chi tiết đơn hàng mới. Nếu số lượng trong kho
-- không đủ thì ném ra thông báo lỗi “Số lượng sản phẩm trong kho không đủ” và hủy
-- thao tác chèn.
delimiter //
create trigger trigger_after_insert_order_details before insert on OrderDetails
for each row
begin
	declare current_quantity int;
    select quantity into current_quantity from Products where product_id = new.product_id;
    if current_quantity < new.quantity then
		signal sqlstate '45000'
        set message_text = 'số lượng sản phẩm trong kho không đủ';
	else 
		update Products
        set quantity = quantity - new.quantity where product_id = new.product_id;
	end if;
end //
delimiter ;

-- Câu 11 - Quản lý transaction
-- Tạo một thủ tục có tên proc_insert_order_details nhận vào tham số là mã đơn hàng,
-- mã sản phẩm, số lượng và giá sản phẩm. Sử dụng transaction thực hiện các yêu cầu sau :
-- Kiểm tra nếu mã hóa đơn không tồn tại trong bảng order thì ném ra thông báo
-- lỗi “không tồn tại mã hóa đơn”.
-- Chèn dữ liệu vào bảng order_details
-- Cập nhật tổng tiền của đơn hàng ở bảng Orders
-- Nếu như có bất cứ lỗi nào sinh ra, rollback lại Transaction
delimiter //
create procedure proc_insert_order_details(
	in p_order_id int,
	in p_product_id int,
	in p_quantity int,
	in p_unit_price decimal(10,2)
)
begin
	declare v_count int;
    start transaction;
    select count(*) into v_count from Orders where p_order_id = order_id;
    if v_count = 0 then
		rollback;
        signal sqlstate '45000'
        set message_text = 'Mã đơn không tồn tại';
	end if;
    
    insert into OrderDetails(order_id, product_id, quantity, unit_price) 
		values (p_order_id, p_product_id, p_quantity, p_unit_price);
        
	update Orders
    set total_amount = total_amount + (p_quantity * p_unit_price) where p_order_id = order_id;
    
    commit;
end //
delimiter ;