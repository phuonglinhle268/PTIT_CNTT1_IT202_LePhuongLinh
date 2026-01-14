create database session13;
use session13;

-- bài 1
create table users(
	user_id int auto_increment primary key,
    username varchar(50) unique not null,
    email varchar(100) unique not null,
    created_at date,
    follower_count int default 0,
    post_count int default 0
);

create table posts(
	post_id int auto_increment primary key,
    user_id int,
    content text,
    created_at datetime,
    like_count int default 0,
    
    foreign key (user_id) references users(user_id) on delete cascade  
    -- xóa user thì xóa luôn post đó
);

INSERT INTO users (username, email, created_at) VALUES
	('alice',   'alice@example.com',   '2025-01-01'),
	('bob',     'bob@example.com',     '2025-01-02'),
	('charlie', 'charlie@example.com', '2025-01-03'),
	('david',   'david@example.com',   '2025-01-04'),
	('emma',    'emma@example.com',    '2025-01-05'),
	('frank',   'frank@example.com',   '2025-01-06'),
	('grace',   'grace@example.com',   '2025-01-07'),
	('henry',   'henry@example.com',   '2025-01-08'),
	('irene',   'irene@example.com',   '2025-01-09'),
	('jack',    'jack@example.com',    '2025-01-10');


-- Trigger AFTER INSERT trên posts: Khi thêm bài đăng mới, tăng post_count lên 1
delimiter //
create trigger after_insert_posts after insert on posts
for each row
begin
	update users
    set post_count = post_count + 1
    where user_id = new.user_id;
end //
delimiter ;

-- xóa bài, giảm post_count đi 1
delimiter //
create trigger after_delete_posts after delete on posts
for each row
begin
	update users
    set post_count = post_count - 1
    where user_id = old.user_id;
end //
delimiter ;

INSERT INTO posts (user_id, content, created_at) VALUES
	(1, 'Hello world from Alice!',            '2025-01-10 10:00:00'),
	(1, 'Second post by Alice',               '2025-01-10 12:00:00'),
	(2, 'Bob first post',                     '2025-01-11 09:00:00'),
	(3, 'Charlie sharing thoughts',           '2025-01-12 15:00:00'),
	(4, 'David joins the platform',           '2025-01-13 08:30:00'),
	(5, 'Emma says hello everyone!',          '2025-01-13 10:15:00'),
	(6, 'Frank posting his first update',     '2025-01-14 09:45:00'),
	(7, 'Grace shares a motivational quote',  '2025-01-14 11:20:00'),
	(8, 'Henry checking in for the first time','2025-01-15 14:00:00'),
	(9, 'Irene writes her first blog post',    '2025-01-16 16:40:00');

SELECT * FROM users;

-- xóa bài đăng và kiểm tra
delete from posts where post_id = 2;
select * from users;

-- bài 2
create table likes(
	like_id int auto_increment primary key,
    user_id int,
    post_id int,
    liked_at datetime default current_timestamp,
    
    foreign key (user_id) references users(user_id) on delete cascade,
    foreign key (post_id) references posts(post_id) on delete cascade
);
-- trigger cập nhập like
delimiter //
create trigger after_insert_likes
after insert on likes
for each row
begin
	update posts
    set like_count = like_count + 1
    where post_id = new.post_id;
end //
delimiter ;

delimiter //
create trigger after_delete_likes
after delete on likes
for each row
begin
	update posts
    set like_count = like_count - 1
    where post_id = old.post_id;
end //
delimiter ;

insert into likes (user_id, post_id, liked_at) values
	(2, 1, '2025-01-10 11:00:00'),
	(3, 1, '2025-01-10 13:00:00'),
	(4, 1, '2025-01-10 14:00:00'),

	(1, 3, '2025-01-11 10:00:00'),
	(5, 3, '2025-01-11 11:30:00'),

	(6, 4, '2025-01-12 16:00:00'),
	(7, 4, '2025-01-12 16:10:00'),

	(8, 5, '2025-01-13 10:20:00'),
	(9, 6, '2025-01-14 09:50:00'),
	(10,7, '2025-01-14 11:45:00');

create or replace view user_statistics as
select
	u.user_id,
    u.username,
    u.post_count,
    sum(p.like_count) as total_likes
from users u
left join posts p on u.user_id = p.user_id
group by u.user_id, u.username, u.post_count;

-- bài 3
-- BEFORE INSERT: Kiểm tra không cho phép user like bài đăng của chính mình
delimiter //
create trigger before_insert_likes before insert on likes
for each row
begin
	declare post_owner int;
    select user_id into post_owner from posts
    where post_id = new.post_id;
    
    if new.user_id = post_owner then 
		set new.post_id = null;  -- ko cho user tự like bài
	end if;
end //
delimiter ;

-- after update like
delimiter //
create trigger after_update_likes after update on likes
for each row
begin
	-- tăng like
	update posts
    set like_count = like_count + 1
    where post_id = new.post_id;
    
    -- giảm like
    update posts
    set like_count = like_count - 1
    where post_id = old.post_id;
end //
delimiter ;

-- Thử like bài của chính mình (phải báo lỗi)
insert into likes (user_id, post_id) values (3, 4);

-- Thêm like hợp lệ, kiểm tra like_count.
insert into likes (user_id, post_id) values (2, 4);
select post_id, like_count from posts where post_id = 4;

-- UPDATE một like sang post khác, kiểm tra like_count của cả hai post
-- Chuyển lượt like của user 2 từ post 4 sang post 1
update likes set post_id = 1 where user_id = 2 and post_id = 4 limit 1;
select post_id, like_count from posts where post_id in (1,4);

-- xóa like
delete from likes
where user_id = 2 and post_id = 1 limit 1;
select post_id, like_count from posts where post_id = 1;

-- Truy vấn SELECT từ posts và user_statistics (từ bài 2) để kiểm chứng
select * from posts;
select * from user_statistics;

-- bài 4
create table post_history (
	history_id int auto_increment primary key,
    post_id int,
    old_content text,
    new_content text,
    changed_at datetime,
    changed_by_user_id int,
    
    foreign key (post_id) references posts(post_id) on delete cascade  -- Xóa post → lịch sử tự xóa
);

-- BEFORE UPDATE trên posts: Nếu content thay đổi, INSERT bản ghi vào post_history với old_content, new_content, changed_at NOW(), 
-- và giả sử changed_by_user_id là user_id của post.
delimiter //
create trigger before_update_posts before update on posts
for each row
begin
	if old.content <> new.content then
		insert into post_history (
			post_id,
			old_content,
			new_content,
			changed_at,
			changed_by_user_id
		)
		values (
			old.post_id,
			old.content,
			new.content,
			now(),
			old.user_id
);

	end if;
end //
delimiter ;

-- Thực hiện UPDATE nội dung một số bài đăng, sau đó SELECT từ post_history để xem lịch sử
update posts
set content = 'New post update' where post_id = 1;

update posts
set content = 'Wait for new status!!!' where post_id = 3;

-- Kiểm tra kết hợp với trigger like_count từ bài trước vẫn hoạt động khi UPDATE post
select post_id, like_count from posts;
insert into likes (user_id, post_id) values (2, 1);
select post_id, like_count from posts where post_id = 1;
select * from post_history;

-- bài 5
-- Tạo Stored Procedure add_user(username, email, created_at) thực hiện INSERT vào users.
delimiter //
create procedure add_user(
	in p_username varchar(50),
	in p_email varchar(100),
	in p_created_at date
)
begin
	insert into users (username, email, created_at) values (p_username, p_email, p_created_at);
end //
delimiter ;

-- Tạo trigger BEFORE INSERT trên users:
delimiter //

create trigger before_insert_users before insert on users
for each row
begin
	-- kiểm tra email
	IF new.email not like '%@%.%' then
		set new.email = null;
	end if;

	-- kiểm tra username
	if new.username not regexp '^[A-Za-z0-9_]+$' then
		set new.username = null;
	end if;
end //
delimiter ;

-- Gọi procedure với dữ liệu hợp lệ và không hợp lệ để kiểm thử
call add_user('testuser', 'test@gmail.com', '2025-02-01');  -- email hợp lệ
call add_user('user2', 'user2', '2025-02-02'); -- email không hợp lệ
call add_user('user@123', 'user123@gmail.com', '2025-02-03');  -- username ko hợp lệ
select * from users;

-- bài 6
create table friendships (
	follower_id int,
    followee_id int,
    status enum('pending', 'accepted') default 'accepted',
    
    primary key (follower_id, followee_id),
    foreign key (follower_id) references users(user_id) on delete cascade,
    foreign key (followee_id) references users(user_id) on delete cascade
);

-- Tạo trigger AFTER INSERT/DELETE trên friendships để cập nhật follower_count của followee.
delimiter //
create trigger after_insert_friendships
after insert on friendships
for each row
begin
	if new.status = 'accepted' then
		update users
        set follower_count = follower_count + 1
        where user_id = new.followee_id;
	end if;
end //
delimiter ;

-- after delete
delimiter //
create trigger after_delete_friendships
after delete on friendships
for each row
begin
	if old.status = 'accepted' then
		update users
        set follower_count = follower_count - 1
        where user_id = old.followee_id;
	end if;
end //
delimiter ;

-- Tạo Procedure follow_user(follower_id, followee_id, status) xử lý logic (tránh tự follow, tránh trùng)
delimiter //
create procedure follow_user(
	in p_follower_id int,
    in p_followee_id int,
    in p_status enum('pending', 'accepted')
)
begin
	-- không cho tự follow
	if p_follower_id = p_followee_id then
		leave proc_end;  -- dùng để thoát khỏi một khối lệnh (block) được đặt tên,giống như return 
	end if;

	-- tránh follow trùng
	if exists (
		select 1 from friendships
        where follower_id = p_follower_id
          and followee_id = p_followee_id
	) then
		leave proc_end;
	end if;

	-- insert hợp lệ
	insert into friendships (follower_id, followee_id, status) values (p_follower_id, p_followee_id, p_status);
	proc_end: begin end;
    -- là một block rỗng có nhãn, thường dùng làm điểm thoát cho câu lệnh LEAVE trong stored procedure hoặc trigger
end //
delimiter ;

-- Tạo View user_profile chi tiết
create or replace view user_profile as
select
	u.user_id,
    u.username,
    u.follower_count,
    u.post_count,
    ifnull(sum(p.like_count), 0) as total_likes,
    group_concat(  -- liệt kê bài gần nhất
		p.content
        order by p.created_at desc
	) as recent_posts
from users u
left join posts p on u.user_id = p.user_id
group by u.user_id, u.username, u.follower_count, u.post_count;

-- Thực hiện một số follow/unfollow và kiểm chứng follower_count, View.
call follow_user(3, 1, 'accepted'); 
call follow_user(4, 2, 'accepted'); 
delete from friendships where follower_id = 3 and followee_id = 1;
call follow_user(2, 1, 'accepted');  -- follow trùng

select user_id, username, follower_count from users;
select * from friendships;
select * from user_profile;





