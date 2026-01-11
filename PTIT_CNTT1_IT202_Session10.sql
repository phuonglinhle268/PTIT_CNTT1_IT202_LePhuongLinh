use social_network_pro;

-- bài 1
-- 2) Tạo view hiện người dùng họ “Nguyễn”. 
-- gồm các cột: user_id, username, full_name, email, created_at
create or replace view view_users_firstname as
select user_id, username, full_name, email, created_at 
from users
where full_name like 'Nguyễn%';

-- 3) Tiến hành hiển thị lại view vừa tạo được - truy vấn kiểm tra
select * from view_users_firstname;

-- 4) Thêm một nhân viên mới vào bảng User có họ “Nguyễn”.
insert into users(username, full_name, gender, email, password, birthdate, hometown) values
	('thai', 'Nguyễn Phương Thái', 'Nữ', 'thai@gmail.com', '412', '2007-08-05', 'Hà Nội');
 
-- 5)  Thực hiện xóa nhân viên vừa thêm khỏi bảng User
delete from users where username = 'thai';


-- bài 2
-- 2) Tạo view hiện User với các cột: user_id(mã người dùng) và total_user_post
create or replace view view_user_post as
select 
	u.user_id, 
    count(p.post_id) as total_user_post
from users u join posts p on u.user_id = p.user_id
group by u.user_id;

-- 3) Tiến hành hiển thị lại view_user_post để kiểm chứng
select * from view_user_post;

-- 4) Kết hợp view view_user_post với bảng users để hiển thị các cột: full_name(họ tên), total_user_post 
select 
	u.full_name,
    v.total_user_post
from users u join view_user_post v on u.user_id = v.user_id;

-- bài 3
-- explain analyze: cho biết kế hoạch thực thi dự kiến
-- dùng để xem MySQL chạy câu SQL như thế nào, có dùng index không và tốn bao nhiêu thời gian.
-- quét theo id, thay vì toàn bảng

-- 2) Viết câu truy vấn Select tìm tất cả những User ở Hà Nội
explain analyze
select * from users where hometown = 'Hà Nội';

-- 3) Tạo một chỉ mục có tên idx_hometown cho cột hometown của bảng User. 
create index idx_hometown on users(hometown);

-- 4) So sánh kết quả trước và sau khi đánh chỉ mục.
-- Trước: table scan, quét toàn bộ bảng
--  type: all, extra: using where
-- Sau: Chỉ quét các dòng có hometown = 'Hà Nội'
-- type: ref, extra: Using index condition
-- => Index giúp tăng tốc SELECT nhưng làm chậm INSERT / UPDATE / DELETE

-- 5) Hãy xóa chỉ mục idx_hometown khỏi bảng customers.
drop index idx_hometown on users;

-- bài 4
-- 2) Tạo chỉ mục phức hợp (Composite Index)
-- Tạo một truy vấn để tìm tất cả các bài viết (posts) trong năm 2026 của người dùng có user_id là 1
explain analyze
select 
	post_id, 
    content,
    created_at
from posts where user_id = 1 and year(created_at) = 2026;
-- Tạo chỉ mục phức hợp với tên idx_created_at_user_id trên bảng posts sử dụng các cột created_at và user_id.
create index idx_created_at_user_id on posts (created_at, user_id);

-- 3) Tạo chỉ mục duy nhất (Unique Index)
-- Tạo một truy vấn để tìm tất cả các người dùng (users) có email là 'an@gmail.com'
explain analyze
select 
	user_id, 
    username, 
    email 
from users where email = 'an@gmail.com';
-- Tạo chỉ mục duy nhất với tên idx_email trên cột email trong bảng users.
create unique index idx_email on users (email);

-- 4) Xóa chỉ mục
-- Xóa chỉ mục 
drop index idx_created_at_user_id on post;
drop index idx_email on users;

-- bài 5
-- 2) Tạo chỉ mục có tên idx_hometown trên cột hometown của bảng users
create index idx_hometown on users(hometown);
-- 3) Thực hiện truy vấn với các yêu cầu sau:
-- Viết một câu truy vấn để tìm tất cả các người dùng (users) có hometown là "Hà Nội"
-- Kết hợp với bảng friends để hiển thị thêm thông tin về các người bạn của người dùng. 
-- Sắp xếp danh sách theo username giảm dần và giới hạn kết quả chỉ hiển thị 3 người dùng đầu tiên
explain analyze
select
	u.user_id,
    u.username,
    f.friend_id,
    f.status
from users u join friends f on f.user_id = u.user.id
where u.hometown='Hà Nội' order by u.username desc limit 3;

-- bài 6
-- 2) Tạo một view tên view_users_summary để thống kê số lượng bài viết của từng người dùng
create or replace view view_users_summary as
select 
	u.user_id, 
    u.username,
    count(p.post_id) as total_posts
from users u left join posts p on p.user_id = u.user_id
group by u.user_id, u.username;
select * from view_users_summary;
-- 3) Truy vấn từ view_users_summary để hiển thị các thông tin người dùng có total_posts lớn hơn 5
select user_id, username, total_posts
from view_users_summary where total_posts > 5;

-- bài 7
-- 2) Tạo một view với tên view_user_activity_status hiển thị các cột:  user_id , username, gender, created_at, status. 
-- Trong đó status được xác định như sau: 
-- "Active" nếu người dùng có ít nhất 1 bài viết hoặc 1 bình luận.
-- "Inactive" nếu người dùng không có bài viết và không có bình luận.
create or replace view view_user_activity_status as
select u.user_id, u.username, u.gender, u.created_at,
	case 
		when exists( select 1 from posts p where u.user_id = p.user_id)
        or exists( select 1 from comments c where u.user_id = c.user_id)
		then  'Active' else 'Inactive'
	end as status
from users u;
-- 3) Truy vấn view view_user_activity_status và kiểm tra kết quả thu được
select * from view_user_activity_status;
-- 4)Truy vấn view view_user_activity_status để thống kê số lượng người dùng theo từng trạng thái 
select 
	status,
    count(*) as user_count
from view_user_activity_status group by status order by user_count desc;

-- bài 8
-- 2) Tạo một index idx_user_gender trên cột gender của bảng users.
create index idx_user_gender on users(gender);
-- 3) Tạo một view tên view_highly_interactive_users để hiển thị những người dùng tương tác tốt (số lượng comment lớn hơn 5) 
create or replace view view_highly_interactive_users as
select 
	u.user_id,
    u.username,
    count(c.comment_id) as comment_count
from users u join comments c on u.user_id = c.user_id
group by u.user_id, u.username having comment_count > 5;
-- 4) Truy vấn các thông tin của view view_highly_interactive_users 
select * from  view_highly_interactive_users;
-- 5) Viết truy vấn kết hợp view_highly_interactive_users với bảng posts để tính tổng số bình luận cho mỗi người dùng: 
-- Tính tổng số bình luận của mỗi người dùng (sum_comment_user). Sắp xếp kết quả theo số lượng bình luận giảm dần. 
-- Kết quả cần hiển thị các cột: username, sum_comment_user. Sử dụng GROUP BY để nhóm theo người dùng và tính tổng số bình luận.
select
	v.username,
    sum(v.comment_count) as sum_comment_user
from  view_highly_interactive_users v
join posts p on v.user_id = p.user_id
group by v.user_id, v.username order by sum_comment_user desc;

-- bài 9
-- 3) Tạo một view tên view_user_activity để hiển thị tổng số lượng bài viết và bình luận của mỗi người dùng. Các cột trong view bao gồm: user_id (Mã người dùng), total_posts (Tổng số bài viết), total_comments (Tổng số bình luận).
create or replace view view_user_activity as
select
    u.user_id,
    count(distinct p.post_id) as total_posts,
    count(distinct c.comment_id) as total_comments
from users u left join posts p on u.user_id = p.user_id
             left join comments c on u.user_id = c.user_id
group by u.user_id;
-- 4) Hiển thị lại view trên. 
select * from view_user_activity;
-- 5) Viết truy vấn kết hợp view_user_activity với bảng users để lấy thông tin người dùng:
-- - Điều kiện: total_posts > 5 và total_comments > 20.
-- - Sắp xếp theo total_comments (Tổng số bình luận) giảm dần.
-- - Giới hạn kết quả hiển thị 5 bản ghi đầu tiên.
select
    u.user_id,
    u.username,
    v.total_posts,
    v.total_comments
from users u join view_user_activity v on u.user_id = v.user_id
where v.total_posts > 5 and v.total_comments > 20
order by v.total_comments desc limit 5;

-- bài 10
-- 2)Tạo một chỉ mục (index) trên cột username của bảng users.
create index idx_username on users(username);
-- 3)Tạo một View có tên view_user_activity_2 để thống kê tổng số bài viết (total_posts) và tổng số bạn bè (total_friends) của mỗi người dùng. 
-- Cột total_posts được tính dựa trên số lượng bản ghi trong bảng posts của mỗi người dùng. 
-- Cột total_friends được tính theo trạng thái kết bạn là accepted trong bảng friends.
create or replace view view_user_activity_2 as
select
    u.user_id,
   count(distinct p.post_id) as total_posts,
    COUNT(distinct 
        case
            when f.status = 'accepted' then f.friend_id 
        end
    ) as total_friends
from users u left join posts p on u.user_id = p.user_id
             left join friends f on u.user_id = f.user_id
group by u.user_id;
-- 4) Hiển thị lại view trên. 
select * from view_user_activity_2 ;
-- 5)Viết một truy vấn kết hợp view_user_activity với bảng users để hiển thị danh sách người dùng có total_posts > 0, sắp xếp theo total_posts giảm dần
-- Thêm một cột friend_description vào kết quả. Cột này chứa mô tả rút gọn về số bạn bè, cụ thể:
--    Nếu total_friends > 5, hiển thị "Nhiều bạn bè".
--    Nếu total_friends từ 2 đến 5, hiển thị "Vừa đủ bạn bè".
--    Nếu total_friends < 2, hiển thị "Ít bạn bè".
-- Thêm một cột post_activity_score (điểm hoạt động bài viết) với công thức:
--    Nếu total_posts > 10, post_activity_score = total_posts * 1.1 (tăng 10%).
--    Nếu total_posts từ 5 đến 10, post_activity_score = total_posts.
--    Nếu total_posts < 5, post_activity_score = total_posts * 0.9 (giảm 10%).
select
    u.full_name,
    v.total_posts,
    v.total_friends,
    case
        when v.total_friends > 5 then 'Nhiều bạn bè'
        when v.total_friends between 2 and 5 then 'Vừa đủ bạn bè'
        else 'Ít bạn bè'
    end as friend_description,
    case
        when v.total_posts > 10 then v.total_posts * 1.1
        when v.total_posts between 5 and 10 then v.total_posts
        else v.total_posts * 0.9
    end as post_activity_score
from users u join view_user_activity_2 v on u.user_id = v.user_id
where v.total_posts > 0 order by v.total_posts desc;

