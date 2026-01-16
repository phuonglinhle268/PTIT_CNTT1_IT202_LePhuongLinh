create database session15;
use session15;

CREATE TABLE users (
    user_id INT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(50) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE posts (
    post_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT,
    content TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id)
        REFERENCES users (user_id)
        ON DELETE CASCADE
);

CREATE TABLE comments (
    comment_id INT PRIMARY KEY AUTO_INCREMENT,
    post_id INT,
    user_id INT,
    content TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (post_id)
        REFERENCES posts (post_id)
        ON DELETE CASCADE,
    FOREIGN KEY (user_id)
        REFERENCES users (user_id)
        ON DELETE CASCADE
);

CREATE TABLE likes (
    user_id INT,
    post_id INT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (user_id , post_id),
    FOREIGN KEY (user_id)
        REFERENCES users (user_id)
        ON DELETE CASCADE,
    FOREIGN KEY (post_id)
        REFERENCES posts (post_id)
        ON DELETE CASCADE
);

CREATE TABLE friends (
    user_id INT,
    friend_id INT,
    status ENUM('pending', 'accepted') DEFAULT 'pending',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (user_id , friend_id),
    FOREIGN KEY (user_id)
        REFERENCES users (user_id)
        ON DELETE CASCADE,
    FOREIGN KEY (friend_id)
        REFERENCES users (user_id)
        ON DELETE CASCADE
);

CREATE TABLE user_logs (
    log_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT,
    action TEXT,
    log_time DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE post_logs (
    log_id INT PRIMARY KEY AUTO_INCREMENT,
    post_id INT,
    user_id INT,
    action VARCHAR(100),
    log_time DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE friend_logs (
    log_id INT PRIMARY KEY AUTO_INCREMENT,
    sender_id INT,
    receiver_id INT,
    action VARCHAR(50),
    log_time DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Bài 1: Đăng Ký Thành Viên
delimiter $$
 create procedure sp_register_user(
	p_username varchar(50),
    p_password varchar(255),
    p_email varchar(100)
)
begin
	declare count_check int;
	-- Kiểm tra trùng username
    select count(*) into count_check from users
    where username = p_username;
    if count_check > 0 then
		signal sqlstate '45000'
        set message_text = "Username đã tồn tại";
	end if;
    -- Kiểm tra trùng email
    select count(*) into count_check from users
    where email = p_email;
    if count_check > 0 then
		signal sqlstate '45000'
        set message_text = "Username đã tồn tại";
    end if;
    -- Thêm người dùng 
	insert into users(username, password, email) 
    values(p_username, p_password, p_email);
end $$
delimiter ;

-- Trigger tự động ghi log user
delimiter $$
create trigger triggerAfterInserUser
after insert on users
for each row
begin
	insert into user_logs(user_id, action) 
    values(new.user_id, "Đăng ký tài khoản");
end $$
delimiter ; 


-- Kiểm thử
call sp_register_user('son01', '123456', 'son01@gmail.com');
call sp_register_user('son02', '123456', 'son02@gmail.com');
call sp_register_user('son03', '123456', 'son03@gmail.com');


-- Bài 2: Đăng Bài Viết
delimiter $$
create procedure sp_create_post(
	p_user_id int,
    p_content text
)
begin
	-- Kiểm tra content rỗng
    if p_content is null or trim(p_content) = "" then
		signal sqlstate '45000'
        set message_text = "Nội dung bài viết không được rỗng";
	end if;
    -- Thêm bài viết
    insert into posts(user_id, content)
    values(p_user_id, p_content);
end $$
delimiter ;
 
delimiter $$
create trigger triggerAfterInsertPost
after insert on posts
for each row
begin
	insert into post_logs(post_id, user_id, action)
    values (new.post_id, new.user_id, "Đăng bài viết");
end $$
delimiter ;  


-- Thêm dữ liệu 
call sp_create_post(1, 'Bài viết số 1');
call sp_create_post(1, 'Bài viết số 2');
call sp_create_post(2, 'Hello mọi người');
call sp_create_post(2, 'Hôm nay học MySQL');
call sp_create_post(3, 'Trigger hoạt động tốt');
call sp_create_post(3, 'Stored Procedure khá hay');

-- Bài 3: Thích Bài Viết
-- Thêm cột like_count cho post
alter table posts
add column like_count int default 0;

-- Trigger tăng like count của bài viết sau khi like
delimiter $$
create trigger triggerAfterInsertLike
after insert on likes
for each row
begin
	update posts
    set like_count = like_count + 1
    where post_id = new.post_id;
end $$
delimiter ;

-- Trigger giảm like của bài viết sau khi unlike
delimiter $$
create trigger triggerAfterDeleteLike
after delete on likes
for each row
begin
	update posts
    set like_count = like_count - 1
    where post_id = old.post_id;
end $$
delimiter ;

-- Thêm dữ liệu
insert into likes(user_id, post_id) values (2, 1);
insert into likes(user_id, post_id) values (3, 1);
insert into likes(user_id, post_id) values (1, 2);

-- Xóa dữ liệu 
delete from likes
where user_id = 2
  and post_id = 1;

select * from posts;
select * from likes; 

-- Bài 4: Gửi Lời Mời Kết Bạn
delimiter $$
create procedure sp_send_friend_request(
	p_sender_id int,
    p_receiver_id int
)
begin
	declare count_check int;
    -- Kiểm tra tự gửi
    if p_sender_id = p_receiver_id then
		signal sqlstate '45000'
        set message_text = 'Không thể gửi lời mời cho chính mình';
    end if;
    -- Kiểm tra trùng
    select count(*) into count_check from friends
    where user_id = p_sender_id and friend_id = p_receiver_id;
    if count_check > 0 then
		signal sqlstate '45000'
        set message_text = 'Đã gửi lời mới trước đó';
	end if;
    -- Gửi lời mời
    insert into friends(user_id, friend_id)
	values (p_sender_id, p_receiver_id);
end $$
delimiter ;

delimiter $$
create trigger triggerAfterInsertFriend
after insert on friends
for each row
begin
	insert into friend_logs(sender_id, receiver_id, action)
    values (new.user_id, new.friend_id, 'Gửi lời mời kết bạn');
end $$
delimiter ;

call sp_send_friend_request(1, 2);
call sp_send_friend_request(1, 3);
call sp_send_friend_request(2, 3);

select * from friends;
select * from friend_logs;

-- Bài 5: Chấp Nhận Lời Mời Kết Bạn
delimiter $$

create procedure sp_accept_friend_request(
	p_sender_id int,
    p_receiver_id int
)
begin
	declare count_check int;
	-- Kiểm tra pending
	select count(*) into count_check
	from friends
	where user_id = p_sender_id
	  and friend_id = p_receiver_id
	  and status = 'pending';

	if count_check = 0 then
		signal sqlstate '45000'
        set message_text = 'Không tồn tại lời mời hợp lệ';
	end if;

	-- Update chiều gửi
	update friends
	set status = 'accepted'
	where user_id = p_sender_id
	  and friend_id = p_receiver_id;

	-- Insert chiều ngược
	insert into friends(user_id, friend_id, status)
	values (p_receiver_id, p_sender_id, 'accepted');
end $$
delimiter ;

-- Thêm dữ liệu
call sp_accept_friend_request(1, 2);

select * from friends;

-- Bài 6: Quản Lý Mối Quan Hệ Bạn Bè
delimiter $$
create procedure sp_unfriend(
	p_user_id int,
    p_friend_id int
)
begin
	declare count_check int;
    
	start transaction;
	-- Kiểm tra quan hệ tồn tại
	select count(*) into count_check
	from friends
	where user_id = p_user_id
	  and friend_id = p_friend_id
	  and status = 'accepted';

	if count_check = 0 then
		rollback;
		signal sqlstate '45000'
        set message_text = 'Không tồn tại quan hệ bạn bè';
	end if;

	-- Xóa 2 chiều
	delete from friends
	where (user_id = p_user_id and friend_id = p_friend_id)
	   or (user_id = p_friend_id and friend_id = p_user_id);
       
	commit;
end $$
delimiter ;

call sp_unfriend(1, 2);

select * from friends;

-- Bài 7: Quản Lý Xóa Bài Viết
delimiter $$

create procedure sp_delete_post(
	p_post_id int,
    p_user_id int
)
begin
	declare count_check int;

	start transaction;
	-- Kiểm tra bài viết tồn tại và đúng chủ
	select count(*) into count_check
	from posts
	where post_id = p_post_id
	  and user_id = p_user_id;

	if count_check = 0 then
		rollback;
		signal sqlstate '45000'
        set message_text = 'Đã xảy lỗi vui lòng thử lại!';
	end if;

	-- Xóa bài viết
	delete from posts
	where post_id = p_post_id;
	commit;
end $$
delimiter ;


call sp_delete_post(1, 1);

select * from posts;
select * from likes;
select * from comments;

-- Bài 8:
delimiter $$

create procedure sp_delete_user(
	p_user_id int
)
begin
	declare count_check int;

	start transaction;
	-- Kiểm tra user tồn tại
	select count(*) into count_check
	from users
	where user_id = p_user_id;

	if count_check = 0 then
		rollback;
		signal sqlstate '45000'
        set message_text = 'User không tồn tại';
	end if;

	-- Xóa users
	delete from users
	where user_id = p_user_id;
	commit;
end $$
delimiter ;

call sp_delete_user(1);

select * from users;
select * from posts;
select * from comments;
select * from likes;
select * from friends;

    