use social_network_pro;

-- bài 1
-- 2) Tạo stored procedure có tham số IN nhận vào p_user_id:
delimiter //
create procedure get_posts_by_user (
    in p_user_id int
)
begin
    select 
        post_id as PostID,
        content as NoiDung,
        created_at as ThoiGianTao
    from posts
    where user_id = p_user_id order by created_at desc;
end //
delimiter ;
-- 3) Gọi lại thủ tục vừa tạo với user cụ thể mà bạn muốn
call get_posts_by_user(1);
-- 4) Xóa thủ tục vừa tạo.
drop procedure if exists get_posts_by_user;

-- bài 2
-- 2) Tính tổng like của bài viết
delimiter //
create procedure CalculatePostLikes (
    in p_post_id int,
    out total_likes int
)
begin
    select count(*) into total_likes
    from likes where post_id = p_post_id;
end //
delimiter ;
-- 3) Thực hiện gọi stored procedure CalculatePostLikes với một post cụ thể 
call CalculatePostLikes(3, @total_likes);
-- và truy vấn giá trị của tham số OUT total_likes sau khi thủ tục thực thi
select @total_likes as tong_like;

-- 4) Xóa thủ tục vừa mới tạo trên
drop procedure if exists CalculatePostLikes;

-- bài 3
-- 2) Viết stored procedure tên CalculateBonusPoints nhận hai tham số:
-- p_user_id (INT, IN) – ID của user
-- p_bonus_points (INT, INOUT) – Điểm thưởng ban đầu
-- Trong procedure:
-- Đếm số lượng bài viết (posts) của user đó.
-- Nếu số bài viết ≥ 10, cộng thêm 50 điểm vào p_bonus_points.
-- Nếu số bài viết ≥ 20, cộng thêm tổng cộng 100 điểm (thay vì chỉ 50).
-- Cuối cùng, tham số p_bonus_points sẽ được sửa đổi và trả ra giá trị mới.
delimiter //
create procedure CalculateBonusPoints (
    in p_user_id int,
    inout p_bonus_points int
)
begin
    declare total_posts int;
    -- Đếm số bài viết của user
    select count(*) into total_posts
    from posts where user_id = p_user_id;
    -- Cộng điểm 
    if total_posts >= 20 then
        set p_bonus_points = p_bonus_points + 100;
   elseif total_posts >= 10 then
        set p_bonus_points = p_bonus_points + 50;
    end if;
end //
delimiter ;
-- 3) Gọi thủ tục trên với giá trị id user và p_bonus_points bất kì mà bạn muốn cập nhật
set @bonus_points = 100;
call CalculateBonusPoints(3, @bonus_points);
-- 4) Select ra p_bonus_points 
select @bonus_points as final_bonus_point;
-- 5) Xóa thủ tục mới khởi tạo trên
drop procedure if exists CalculateBonusPoints;

-- bài 4
-- 2) Viết procedure tên CreatePostWithValidation nhận IN p_user_id (INT), IN p_content (TEXT). 
-- Nếu độ dài content < 5 ký tự thì không thêm bài viết 
-- và SET một biến thông báo lỗi để trả về thông báo “Nội dung quá ngắn” hoặc “Thêm bài viết thành công”).
delimiter //
create procedure CreatePostWithValidation (
    in p_user_id int,
    in p_content text,
    out result_message varchar(255)
)
begin
    if char_length(p_content) < 5 then
		set result_message = 'Nội dung quá ngắn';
    else
        insert into posts (user_id, content, created_at) values (p_user_id, p_content, NOW());
        set result_message = 'Thêm bài viết thành công';
    end if;
end //
delimiter ;
-- 3) Gọi thủ tục và thử insert các trường hợp 
call CreatePostWithValidation(1, 'hi', @message);  -- nội dung ngắn
call CreatePostWithValidation(1, 'Cơ sở dữ liệu', @message);  -- phù hợp
-- 4) Kiểm tra các kết quả
select @message as noti;  -- thông báo trả về
select post_id, user_id, content, created_at
from posts order by post_id desc;
-- 5) Xóa thủ tục vừa khởi tạo trên
drop procedure if exists CreatePostWithValidation;

-- bài 5
-- 2)Viết procedure tên CalculateUserActivityScore nhận IN p_user_id (INT), 
-- trả về OUT activity_score (INT). 
-- Điểm được tính: mỗi post +10 điểm, mỗi comment +5 điểm, mỗi like nhận được +3 điểm. 
-- Sử dụng CASE hoặc IF để phân loại mức hoạt động và trả thêm OUT activity_level (VARCHAR(50)).
delimiter //
create procedure CalculateUserActivityScore (
    in p_user_id int,
    out activity_score int,
    out activity_level varchar(50)
)
begin
    declare post_count int default 0;
    declare comment_count int default 0;
    declare like_count int default 0;
    
    -- Đếm số bài viết
    select count(*) into post_count
    from posts where user_id = p_user_id;

    -- Đếm số comment
    select count(*) into comment_count
    from comments where user_id = p_user_id;

    -- Đếm số like nhận được (like trên bài viết của user)
    select count(*) into like_count
    from likes l join posts p on l.post_id = p.post_id where p.user_id = p_user_id;

    -- Tính tổng điểm
    set activity_score = post_count * 10 + comment_count * 5 + like_count * 3;

    -- Mức độ hoạt động
    case
        when activity_score > 500 then
            set activity_level = 'Rất tích cực';
        when activity_score >= 200 then
            set activity_level = 'Tích cực';
        else
            set activity_level = 'Bình thường';
    end case;
end //
delimiter ;
-- 3) Gọi thủ tục trên select ra activity_score và activity_level
call CalculateUserActivityScore(9, @score, @level);
select 
    @score as ActivityScore,
    @level as ActivityLevel;
-- 4) Xóa thủ tục vừa khởi tạo trên
drop procedure if exists CalculateUserActivityScore;

-- bài 6
-- 2)  Viết stored procedure tên NotifyFriendsOnNewPost nhận hai tham số IN:
-- p_user_id (INT) – ID của người đăng bài
-- p_content (TEXT) – Nội dung bài viết
-- Procedure sẽ thực hiện hai việc:
-- Thêm một bài viết mới vào bảng posts với user_id và content được truyền vào.
-- Tự động gửi thông báo loại 'new_post' vào bảng notifications cho tất cả bạn bè đã accepted (hai chiều).
-- Nội dung thông báo: “[full_name của người đăng] đã đăng một bài viết mới”.
-- Không gửi thông báo cho chính người đăng bài.
delimiter //
create procedure NotifyFriendsOnNewPost (
	in p_user_id int,
    in p_content text
)
begin
    declare v_full_name varchar(255);
    declare v_notification_content varchar(255);
    -- Lấy tên người đăng bài
    select full_name into v_full_name
    from users where user_id = p_user_id;

    -- Thêm bài viết mới
    insert into posts (user_id, content, created_at) values (p_user_id, p_content, NOW());

    -- Nội dung thông báo
    set v_notification_content = concat(v_full_name, ' đã đăng một bài viết mới');

    -- Gửi thông báo cho bạn bè (2 chiều, trạng thái accepted)
    insert into notifications (user_id, type, content, created_at)
    select friend_id, 'new_post', v_notification_content, now()
    from friends where user_id = p_user_id and status = 'accepted'
    union
    select user_id, 'new_post', v_notification_content, now()
    from friends where friend_id = p_user_id and status = 'accepted';
end //
delimiter ;
-- 3) Gọi procedue trên và thêm bài viết mới 
call NotifyFriendsOnNewPost(1, 'Hello');

-- 4) Select ra những thông báo của bài viết vừa đăng
select * from notifications
where type = 'new_post' order by created_at desc;

-- 5) Xóa thủ tục vừa khởi tạo trên
drop procedure if exists NotifyFriendsOnNewPost;