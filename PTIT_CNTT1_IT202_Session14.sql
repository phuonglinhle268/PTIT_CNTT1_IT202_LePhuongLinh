create database social_network;
use social_network;

-- bài 1
create table users (
    user_id int primary key auto_increment,
    username varchar(50) not null,
    posts_count int default 0
);

create table posts (
    post_id int primary key auto_increment,
    user_id int not null,
    content text not null,
    created_at datetime default current_timestamp,
    
    foreign key (user_id) references users(user_id)
);

insert into users (username) values ('an'), ('linh');

-- insert bản ghi mới
start transaction;
insert into posts (user_id, content) values (1, 'Bài viết đầu');
update users
set posts_count = posts_count + 1 where user_id = 1;
commit;

-- trường hợp lỗi
start transaction;
insert into posts (user_id, content) values (9, 'Bài viết lỗi');
update users
set posts_count = posts_count + 1 where user_id = 9;
rollback;

select * from posts;
select * from users;

-- bài 2
create table likes (
    like_id int primary key auto_increment,
    post_id int not null,
    user_id int not null,
    foreign key (post_id) references posts(post_id),
    foreign key (user_id) references users(user_id),
    constraint unique_like unique (post_id, user_id)
);

alter table posts
add column likes_count int default 0;

-- update like cho bài viết
start transaction;
insert into likes (post_id, user_id) values (1, 2);
update posts
set likes_count = likes_count + 1 where post_id = 1;
commit;

--  vi phạm UNIQUE constraint (đã like trước đó) 
start transaction;
insert into likes (post_id, user_id) values (1, 2);
update posts
set likes_count = likes_count + 1 where post_id = 1;
rollback;

select * from likes;
select post_id, likes_count from posts;

-- bài 3
create table followers (
    follower_id int not null,
    followed_id int not null,
    primary key (follower_id, followed_id),
    foreign key (follower_id) references users(user_id),
    foreign key (followed_id) references users(user_id)
);

alter table users
add column following_count int default 0,
add column followers_count int default 0;

-- bảng log lỗi
create table follow_log (
    log_id int auto_increment primary key,
    follower_id int,
    followed_id int,
    error_message varchar(255),
    created_at datetime default current_timestamp
);

delimiter //
create procedure sp_follow_user (
    in p_follower_id int,
    in p_followed_id int
)
begin
    start transaction;
    -- select 1: cách viết để kiểm tra “có bản ghi hay không”
    -- 1. Kiểm tra user tồn tại
    if not exists (select 1 from users where user_id = p_follower_id)
       or not exists (select 1 from users where user_id = p_followed_id) then
        insert into follow_log (follower_id, followed_id, error_message) 
        values (p_follower_id, p_followed_id, 'User không tồn tại');
        rollback;
    -- 2. Không tự follow được
    elseif p_follower_id = p_followed_id then
        insert into follow_log (follower_id, followed_id, error_message)
        values (p_follower_id, p_followed_id, 'Không thể tự follow');
        rollback;
    -- 3. Kiểm tra chưa follow trước đó
    elseif exists (
        select 1 from followers 
        where follower_id = p_follower_id and followed_id = p_followed_id
    ) then
        insert into follow_log (follower_id, followed_id, error_message)
        values (p_follower_id, p_followed_id, 'Đã follow trước đó');
        rollback;
    else
        -- 4. Thực hiện follow
        insert into followers (follower_id, followed_id) values (p_follower_id, p_followed_id);
        update users
        set following_count = following_count + 1 where user_id = p_follower_id;
        update users
        set followers_count = followers_count + 1 where user_id = p_followed_id;
        commit;
    end if;
end //
delimiter ;

call sp_follow_user(1, 2); -- trường hợp thành công
call sp_follow_user(1, 2); -- follow lần 2 -> thất bại
call sp_follow_user(1, 1); -- tự follow -> lỗi
call sp_follow_user(1, 9); -- user không tồn tại

select * from followers;
select user_id, following_count, followers_count from users;
select * from follow_log;

-- bài 4
create table comments (
    comment_id int auto_increment primary key,
    post_id int not null,
    user_id int not null,
    content text not null,
    created_at datetime default current_timestamp,
    
    foreign key (post_id) references posts(post_id),
    foreign key (user_id) references users(user_id)
);

alter table posts
add column comments_count int default 0;

delimiter //
create procedure sp_post_comment (
    in p_post_id int,
    in p_user_id int,
    in p_content text
)
begin
    start transaction;
    -- Thêm bình luận
    insert into comments (post_id, user_id, content) values (p_post_id, p_user_id, p_content);
    
    -- Tạo savepoint sau khi insert comment
    -- đánh dấu mốc an toàn
    savepoint after_insert;
    
    -- Cập nhật số lượng comment
    update posts
    set comments_count = comments_count + 1 where post_id = p_post_id;
    
    -- Nếu UPDATE không ảnh hưởng dòng nào → coi như lỗi
    if row_count() = 0 then
        rollback to after_insert;
    else
        commit;
    end if;
end //
delimiter ;

call sp_post_comment(1, 2, 'Xin chào');  -- post 1 user 2
call sp_post_comment(9, 2, 'Test lỗi');

select * from comments;
select post_id, comments_count from posts;

-- bài 5
create table delete_log (
    log_id int auto_increment primary key,
    post_id int,
    deleted_by int,
    deleted_at datetime default current_timestamp
);

delimiter //
create procedure sp_delete_post (
    in p_post_id int,
    in p_user_id int
)
begin
    declare v_owner_id int;
    start transaction;
    -- Kiểm tra bài viết tồn tại và đúng chủ sở hữu
    select user_id into v_owner_id
    from posts where post_id = p_post_id;
    if v_owner_id is null or v_owner_id <> p_user_id then
        rollback;
    else
        -- Xóa likes của bài viết
        delete from likes where post_id = p_post_id;
        
        -- Xóa comments của bài viết
        delete from comments where post_id = p_post_id;
        
        -- Xóa bài viết
        delete from posts where post_id = p_post_id;
        
        -- Giảm posts_count của chủ bài viết
        update users
        set posts_count = posts_count - 1 where user_id = p_user_id;
        
        -- Ghi log xóa thành công
        insert into delete_log (post_id, deleted_by) values (p_post_id, p_user_id);
        commit;
    end if;
end //
delimiter ;

call sp_delete_post(1, 1); -- hợp lệ, post 1 của user 1
call sp_delete_post(1, 2); -- ko phải chủ bài viết
call sp_delete_post(9, 1); -- bài viết không tồn tại

select * from posts;
select * from likes;
select * from comments;
select * from delete_log;    

-- bài 6
create table friend_requests (
    request_id int auto_increment primary key,
    from_user_id int,
    to_user_id int,
    status enum('pending','accepted','rejected') default 'pending',

    foreign key (from_user_id) references users(user_id),
    foreign key (to_user_id) references users(user_id)
);

create table friends (
    user_id int,
    friend_id int,
    
    primary key (user_id, friend_id),
    foreign key (user_id) references users(user_id),
    foreign key (friend_id) references users(user_id)
);
alter table users
add friends_count int default 0;

delimiter //

create procedure sp_accept_friend_request (
    in p_request_id int,
    in p_to_user_id int
)
begin
    declare v_from_user_id int;
	declare dev_status varchar(20);

    start transaction;
    -- 1. Lấy thông tin request (lock dòng)
    select from_user_id, status into v_from_user_id, v_status
    from friend_requests
	where request_id = p_request_id and to_user_id = p_to_user_id;

    -- 2. Kiểm tra request hợp lệ
    if v_from_user_id is null or v_status <> 'pending' then
        rollback;

    -- 3. Kiểm tra chưa là bạn trước đó
    elseif exists (
        select 1 from friends
        where user_id = v_from_user_id and friend_id = p_to_user_id
    ) then
        rollback;
    else
        -- 4. Thêm quan hệ bạn bè 2 chiều
        insert into friends (user_id, friend_id) values (v_from_user_id, p_to_user_id);
        insert into friends (user_id, friend_id) values (p_to_user_id, v_from_user_id);

        -- 5. Tăng friends_count cho cả hai user
        update users
        set friends_count = friends_count + 1 where user_id IN (v_from_user_id, p_to_user_id);

        -- 6. Cập nhật trạng thái request
        update friend_requests
        set status = 'accepted' where request_id = p_request_id;

        commit;
    end if;
end //
delimiter ;


