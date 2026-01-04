create database k24_cntt01_session05;

use k24_cntt01_session05;

create table classes(
	class_id char(20) not null primary key,
    class_name varchar(100) not null unique
);

create table students(
	stu_id int auto_increment primary key,
    full_name varchar(50),
    gender bit,
    birthday date,
    address varchar(200),
    class_id char(20),
    foreign key(class_id) references classes(class_id)
);

insert into classes(class_id,class_name) values
('hn-k24-cntt01','Lớp lập trình vien 01 k24 Hà Nội'),
('hn-k24-cntt02','Lớp lập trình vien 02 k24 Hà Nội'),
('hn-k24-cntt03','Lớp lập trình vien 03 k24 Hà Nội'),
('hn-k24-cntt04','Lớp lập trình vien 04 k24 Hà Nội'),
('hn-k24-cntt05','Lớp lập trình vien 05 k24 Hà Nội');

select * from classes;

select class_id as 'Mã lớp', class_name as 'Tên lớp' from classes;

insert into students(full_name,gender,birthday,address,class_id) values
('Nguyễn Văn Cường',1,'2005-12-21','Thái Bình','hn-k24-cntt01'),
('Nguyễn Lâm Anh',1,'2005-06-03','Thái Bình','hn-k24-cntt01'),
('Nguyễn Thuý Hường',0,'2005-10-11','Hà Nội','hn-k24-cntt02'),
('Nguyễn Vân Giang',0,'2005-08-17','Tuyên Quang','hn-k24-cntt02'),
('Nguyễn Tường Vy',0,'2005-05-25','Hà Nội','hn-k24-cntt03');

select s.stu_id,s.full_name,s.gender, s.birthday,s.address,c.class_name 
from students s join classes c on s.class_id = c.class_id;

select s.stu_id,s.full_name,case s.gender when 1 then 'Nam' when 0 then 'Nữ' end as 'gender', s.birthday,s.address,c.class_name 
from students s join classes c on s.class_id = c.class_id;

-- Dữ liệu bóng đá
create table doi_bong(
	ma_doi_bong char(15) not null primary key,
    ten_doi_bong varchar(100) not null unique
);

create table tt_thi_dau(
	ma_tran_dau int auto_increment primary key,
    ngay_thi_dau date,
    ma_doi_bong char(15),
    so_ban_thang int check(so_ban_thang>=0),
    so_ban_thua int check(so_ban_thua>=0),
    diem int check(diem>=0 and diem<=3)
);

insert into doi_bong(ma_doi_bong,ten_doi_bong) values
('MU','Manchester United'),
('ARS','Arsenal'),
('LIV','Liverpool');

insert into tt_thi_dau(ngay_thi_dau,ma_doi_bong,so_ban_thang,so_ban_thua) values
('2025-10-22','MU',3,1),
('2025-10-22','ARS',1,3),
('2025-10-30','MU',2,2),
('2025-10-30','LIV',2,2),
('2025-11-10','ARS',0,2),
('2025-11-10','LIV',2,0);

select * from tt_thi_dau;

-- Cập nhật cột điểm trong bảng tt_thi_dau cho các đội bong
-- Cách tính: số bàn thắng>số bàn thua: 3 điểm
-- số bàn thắng = số bàn thua: 1 điểm
-- số bàn thắng < số bàn thua: 0 điểm

update tt_thi_dau set diem =(
	case when so_ban_thang - so_ban_thua>0 then 3
    when so_ban_thang - so_ban_thua=0 then 1
    when so_ban_thang - so_ban_thua<0 then 0 end
);

-- Truy vấn để lấy thông tin 2 trận thắng trong bảng trên
-- asc: ascending -> Tăng dần;  desc: descending -> Giảm dần
select * from tt_thi_dau order by diem desc limit 2 offset 0;

-- Nhập thêm 2 đội khác nữa
insert into doi_bong(ma_doi_bong,ten_doi_bong) values
('MC','Manchester City'),
('CHE','Cheseal');

-- Hiển thị thông tin các đội bóng chưa thi đấu trận nào?
select * from doi_bong where ma_doi_bong not in (select distinct ma_doi_bong from tt_thi_dau);

-- Demo left join: 
select db.*,td.* from doi_bong db left join tt_thi_dau td
on db.ma_doi_bong = td.ma_doi_bong;

-- Lấy ra thông tin trận đấu của các đội bóng chỉ thắng hoặc hoà
select * from tt_thi_dau where diem between 1 and 3;

-- THÔNG TIN ĐIỂM THI
create table subject(
	subject_id char(15) not null primary key,
    subject_name varchar(100) not null unique
);

create table exam(	
	stu_id char(20) not null,
    subject_id char(15) not null,
    times int check(times>0),
    exam_date date,
    mark float check(mark>=0 and mark<=10)
);

insert into subject(subject_id, subject_name) values
('c','Lập trình C'),
('ja','Lập trình Java'),
('c#','Lập trình .Net');

select * from students;
insert into exam(stu_id,subject_id,times,exam_date,mark) values
(1,'c',1,'2025-05-10',3),
(1,'c',2,'2025-05-20',4),
(1,'c',3,'2025-06-08',7),
(1,'ja',1,'2025-07-11',6),
(2,'c',1,'2025-05-10',10),
(3,'c',1,'2025-05-10',2),
(3,'c',2,'2025-05-20',6),
(2,'ja',1,'2025-07-11',9),
(3,'ja',1,'2025-07-11',4),
(3,'ja',2,'2025-08-15',7);

select * from exam;

insert into exam(stu_id,subject_id,times,exam_date,mark) values
(4,'c',1,'2025-05-10',1),
(4,'c',2,'2025-05-20',2);

insert into exam(stu_id,subject_id,times,exam_date,mark) values
(3,'c',3,'2025-11-28',6);

-- Lấy thông tin điểm thi của tất cả sinh viên, lần thi là lần cuối cùng

-- Truy vấn lần 1 để loại bỏ số lần thi trùng lặp theo môn của từng sinh viên
-- -> Nhóm theo mã sinh viên và mã môn, lấy max(lần thi)
-- Chỉ lấy được các thông tin: Mã sinh viên, mã môn, lần thi
select ex.* from exam ex join(
select e1.stu_id,e1.subject_id,mark(e1.exam_date) as 'exam_date' from exam e1 join
(select e.stu_id,e.subject_id,max(e.mark) as 'mark'from exam e
group by e.stu_id,e.subject_id) e2 on
e1.stu_id = e2.stu_id and e1.subject_id=e2.subject_id and e1.mark=e2.mark
group by e1.stu_id,e1.subject_id) ex1 on ex.stu_i=ex1.stu_id and
ex.subject_id=ex1.subject_id and ex.exam_date = ex1.exam_date;

-- support by chatgpt
SELECT e1.*
FROM exam e1
JOIN (
    SELECT stu_id, subject_id, mark, MAX(exam_date) AS exam_date
    FROM exam
    WHERE (stu_id, subject_id, mark) IN (
        SELECT stu_id, subject_id, MAX(mark)
        FROM exam
        GROUP BY stu_id, subject_id
    )
    GROUP BY stu_id, subject_id, mark
) e2
ON e1.stu_id = e2.stu_id
AND e1.subject_id = e2.subject_id
AND e1.mark = e2.mark
AND e1.exam_date = e2.exam_date;