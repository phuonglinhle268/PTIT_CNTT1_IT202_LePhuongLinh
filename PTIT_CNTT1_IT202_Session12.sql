create database social_network;
use social_network;

create table Users(
	user_id int primary key,
    username varchar(50) unique not null,
    password varchar(255) not null,
    email varchar(100) unique not null,
	created_at datetime default(current_timestamp())
);

create table Posts(
	post_id int primary key,
    user_id int,
    content text not null,
    created_at datetime default(current_timestamp()),
    
    foreign key (user_id) references Users(user_id)
);

create table Friends (
    user_id int,
    friend_id int,
    status varchar(20),
    check (status in ('pending', 'accepted')),
    
    foreign key (user_id) references Users(user_id),
    foreign key (friend_id) references Users(user_id)
);

create table Likes (
    user_id int,
    post_id int,
    
    foreign key (user_id) references Users(user_id),
    foreign key (post_id) references Posts(post_id)
);

insert into Users (user_id, username, password, email, created_at) values
	(1, 'linh', '123456', 'linh@gmail.com', '2026-01-01 08:00:00'),
	(2, 'an',   '123456', 'an@gmail.com',   '2026-01-02 09:00:00'),
	(3, 'binh', '123456', 'binh@gmail.com', '2026-01-03 10:00:00'),
	(4, 'hoa',  '123456', 'hoa@gmail.com',  '2026-01-04 11:00:00'),
	(5, 'minh', '123456', 'minh@gmail.com', '2026-01-05 12:00:00');
    
insert into Posts (post_id, user_id, content, created_at) values
	(1, 1, 'Hello, đây là bài viết đầu tiên của Linh', '2026-01-10 08:30:00'),
	(2, 2, 'Hôm nay học SQL rất vui', '2026-01-11 09:15:00'),
	(3, 3, 'Database Systems thật sự khó nhưng hay', '2026-01-12 10:45:00'),
	(4, 1, 'Mình đang làm mini project Social Network', '2026-01-13 14:00:00'),
	(5, 4, 'Chào mọi người, mình là Hoa', '2026-01-14 16:20:00');

insert into Friends (user_id, friend_id, status) values
	(1, 2, 'accepted'),
	(2, 1, 'accepted'),
	(1, 3, 'accepted'),
	(3, 1, 'accepted'),
	(2, 4, 'pending'),
	(3, 5, 'pending'),
	(4, 5, 'accepted'),
	(5, 4, 'accepted');

insert into Likes (user_id, post_id) values
	(1, 2),
	(2, 3),
	(2, 4),
	(3, 1),
	(3, 4),
	(4, 1),
	(5, 4),
	(5, 1);

-- Bài 1. Quản lý người dùng - đăng kí
-- Thêm - hiển thị người dùng mới
insert into Users(username, password, email) values
	('lam', '678942', 'lam@gmail.com');
select * from Users;

-- Bài 2. Hiển thị thông tin công khai bằng VIEW
-- Tạo View vw_public_users chỉ hiển thị: user_id, username, created_at.
-- SELECT từ View
-- So sánh với SELECT trực tiếp từ bảng Users.
create or replace view vw_public_users as
select user_id, username, created_at from Users;
select * from vw_public_users;

-- Bài 3. Tối ưu tìm kiếm người dùng bằng INDEX - tìm bạn bè
-- Tạo Index cho: username trong bảng Users.
-- Tìm user theo username.
create index idx_users_username on Users(username);
select * from Users where username = 'an';

-- Bài 4. Quản lý bài viết bằng Stored Procedure - Đăng bài viết
-- Viết Procedure sp_create_post:
-- Tham số IN p_user_id, IN p_content.
-- Kiểm tra:
-- User tồn tại mới cho phép đăng bài.
delimiter //
create procedure sp_create_post(
	in p_user_id int,
    in p_content text
)
begin
	 if exists (select 1 from Users where user_id = p_user_id) then
		insert into Posts(user_id, content)
		values (p_user_id, p_content);
	end if;
end //
delimiter ;
call sp_create_post(2, 'Hôm nay học SQL rất vui');

-- Bài 5. Hiển thị News Feed bằng VIEW - trang chủ
-- Tạo View vw_recent_posts:
-- Lấy bài viết trong 7 ngày gần nhất.
-- Hiển thị danh sách bài viết mới nhất.
create or replace view vw_recent_posts as
	select * from Posts 
    where  datediff(now(), created_at) <= 7;

-- Bài 6. Tối ưu truy vấn bài viết- Xem bài viết của tôi
-- Tạo:
-- Index cho Posts.user_id
-- Composite Index (user_id, created_at).
-- Lấy danh sách bài viết của 1 user theo thời gian giảm dần.
create index idx_posts_user on Posts(user_id);
create index idx_posts_user_time on Posts(user_id, created_at);
select * from Posts
where user_id = 1 order by created_at desc;

-- Bài 7. Thống kê hoạt động bằng Stored Procedure
-- Viết Procedure sp_count_posts: IN p_user_id, OUT p_total.
delimiter //
create procedure sp_count_posts (
    in p_user_id int,
    out p_total int
)
begin
    select count(*) into p_total
    from Posts where user_id = p_user_id;
end //
delimiter ;
call sp_count_posts(1, @total);
select @total as total_posts;

-- Bài 8. Kiểm soát dữ liệu bằng View WITH CHECK OPTION - Quản trị người dùng
-- Tạo View vw_active_users có:
-- Điều kiện lọc user đang hoạt động
create or replace view vw_active_users as
select * from Users
where datediff(now(), created_at) <= 30 with check option;

-- Bài 9. Quản lý kết bạn bằng Stored Procedure - Gửi lời mời kết bạn
-- Viết Procedure sp_add_friend: IN p_user_id, IN p_friend_id.
-- Không cho kết bạn với chính mình.
delimiter //
create procedure sp_add_friend (
    in p_user_id int,
    in p_friend_id int
)
begin
    if p_user_id = p_friend_id then
        select 'Không thể kết bạn với chính mình' as message;
    else
        insert into Friends (user_id, friend_id, status) 
        values (p_user_id, p_friend_id, 'pending');
    end if;
end //
delimiter ;

-- Bài 10. Gợi ý bạn bè bằng Procedure nâng cao
-- Viết Procedure sp_suggest_friends: IN p_user_id, INOUT p_limit.
-- Trả: Danh sách gợi ý bạn bè
delimiter //

create procedure sp_suggest_friends (
    in p_user_id int,
    inout p_limit int
)
begin
    declare counter int default 0;
    while counter < p_limit do
        select user_id, username from Users
        where user_id != p_user_id limit p_limit;
        set counter = counter + 1;
    end while;
end //
delimiter ;


-- Bài 11. Thống kê tương tác nâng cao- Bảng xếp hạng
-- Top 5 bài viết nhiều lượt thích nhất.
-- Tạo View: vw_top_posts.
-- Tạo Index: Cho Likes.post_id.
create index idx_likes_post on Likes(post_id);
create or replace view vw_top_posts as
select p.post_id, p.content, COUNT(l.user_id) as total_likes
from Posts p join Likes l on p.post_id = l.post_id
group by p.post_id order by total_likes desc limit 5;

-- BÀI 12: Người dùng bình luận vào bài viết.
-- Viết Procedure sp_add_comment:
-- Kiểm tra: User, post tồn tại
-- Hiển thị:
-- Nội dung bình luận
-- Tên người bình luận
-- Thời gian
delimiter //

create procedure sp_add_comment (
    in p_user_id int,
    in p_post_id int,
    in p_content text
)
begin
    if not exists (select 1 from Users where user_id = p_user_id) then
        select 'User không tồn tại' as message;
    elseif not exists (select 1 from Posts where post_id = p_post_id) then
        select 'Post không tồn tại' as message;
    else
        insert into Comments (user_id, post_id, content) values (p_user_id, p_post_id, p_content);
    end if;
end //
delimiter ;
create or replace view vw_post_comments as
select c.content, u.username, c.created_at
from Comments c join Users u on c.user_id = u.user_id;

-- BÀI 13. QUẢN LÝ LƯỢT THÍCH
-- Viết Procedure sp_like_post:
-- Kiểm tra: User đã thích post chưa.
-- View thống kê lượt thích
delimiter //
create procedure sp_like_post (
    in p_user_id int,
    in p_post_id int
)
begin
    if exists(
        select 1 from Likes
        where user_id = p_user_id and post_id = p_post_id
    ) then
        select 'Đã thích bài viết này' as message;
    else
        insert into Likes (user_id, post_id) values (p_user_id, p_post_id);
    end if;
end //
delimiter ;
create or replace view vw_post_likes as
select post_id, count(*) as total_likes
from Likes group by post_id;

-- Bài 14. TÌM KIẾM NGƯỜI DÙNG & BÀI VIẾT
-- viết Stored Procedure có tên sp_search_social 
-- Trong đó:
-- Nếu p_option = 1 → tìm người dùng theo username.
-- Nếu p_option = 2 → tìm bài viết theo content.
-- Nếu giá trị khác → trả về thông báo lỗi.
delimiter //
create procedure sp_search_social (
    in p_option int,
    in p_keyword varchar(100)
)
begin
    if p_option = 1 then
        select * from Users
        where username like concat('%', p_keyword, '%');
    elseif p_option = 2 then
        select * from Posts
        where content like concat('%', p_keyword, '%');
    else
        select 'Tùy chọn không hợp lệ' as message;
    end if;
end //
delimiter ;
call sp_search_social(1, 'an');
call sp_search_social(2, 'database');





