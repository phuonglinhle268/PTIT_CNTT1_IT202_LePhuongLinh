create database session04;
use session04;

create table student (
	student_id varchar(20) primary key,
    student_name varchar(30) not null,
    date_of_birth date,
    email varchar(50) not null unique
);

create table teacher (
	teacher_id varchar(20) primary key,
    teacher_name varchar(50) not null,
    email varchar(50) not null unique
);

create table course (
	course_id varchar(20) primary key,
    course_name varchar(100) not null,
    detail text,
    total_session int not null check(total_session > 0),
    teacher_id varchar(20) not null,
    foreign key (teacher_id) references teacher(teacher_id)
);

create table enrollment (
	enroll_date date not null,
    student_id varchar(20) not null,
    course_id varchar(20) not null,
    
    primary key(student_id, course_id),
    foreign key (student_id) references student(student_id),
    foreign key (course_id) references course(course_id)
);

create table score (
	student_id varchar(20) not null,
    course_id varchar(20) not null,
    mid_score decimal(4,2) check(mid_score between 0 and 10),
    final_score decimal(4,2) check(final_score between 0 and 10),
    
    primary key (student_id, course_id),
    foreign key (student_id) references student(student_id),
    foreign key (course_id) references course(course_id)
);

-- Phần II: nhập dữ liệu
insert into student(student_id, student_name, date_of_birth, email) values
	('SV01', 'Nguyễn Văn A', '2003-05-10', 'a@gmail.com'),
    ('SV02', 'Trần Thị B', '2003-08-15', 'b@gmail.com'),
    ('SV03', 'Lê Văn C', '2002-11-20', 'c@gmail.com'),
    ('SV04', 'Phạm Thị D', '2003-02-12', 'd@gmail.com'),
    ('SV05', 'Hoàng Văn E', '2002-09-30', 'e@gmail.com');

insert into teacher(teacher_id, teacher_name, email) values
	('GV01', 'Nguyễn Minh H', 'h@gmail.com'),
    ('GV02', 'Trần Văn K', 'k@gmail.com'),
    ('GV03', 'Lê Thị M', 'm@gmail.com'),
    ('GV04', 'Phạm Văn N', 'n@gmail.com'),
    ('GV05', 'Hoàng Thị P', 'p@gmail.com');

insert into course(course_id, course_name, detail, total_session, teacher_id) values
	('C01', 'Cơ sở dữ liệu', 'Học về SQL và thiết kế CSDL', 30, 'GV01'),
    ('C02', 'Lập trình Java', 'Java cơ bản đến nâng cao', 40, 'GV02'),
    ('C03', 'Cấu trúc dữ liệu', 'Danh sách, Stack, Queue', 35, 'GV03'),
    ('C04', 'Web cơ bản', 'HTML, CSS, JavaScript', 25, 'GV04'),
    ('C05', 'Python cơ bản', 'Python cho người mới', 20, 'GV05');
    
insert into enrollment(student_id, course_id, enroll_date) values
	('SV01', 'C01', '2025-01-05'),
    ('SV01', 'C02', '2025-01-06'),
    ('SV02', 'C01', '2025-01-07'),
    ('SV03', 'C03', '2025-01-08'),
    ('SV04', 'C04', '2025-01-09');
    
insert into score(student_id, course_id, mid_score, final_score) values
	('SV01', 'C01', 7.5, 8.0),
    ('SV01', 'C02', 6.5, 7.0),
    ('SV02', 'C01', 8.0, 8.5),
    ('SV03', 'C03', 7.0, 7.5),
    ('SV04', 'C04', 6.0, 6.5);

-- Phần III - Cập nhật dữ liệu
-- cập nhật email 1 sinh viên
update student
set email = 'newstudent3@gmail.com' where student_id = 'SV03';

-- cập nhật mô tả 1 khóa học
update course
set detail = 'Làm việc với MySQL Workbench' where course_id = 'C01';

-- cập nhật điểm cuối kì cho 1 sinh viên
update score
set final_score = 10 
where student_id = 'SV04' and course_id = 'C04';

-- Phần IV - Xóa dữ liệu
-- Xóa một lượt đăng ký học không hợp lệ
delete from enrollment
where student_id = 'SV04' and course_id = 'C04';

-- Xóa kết quả học tập tương ứng (nếu cần)
delete from score
where student_id = 'SV04' and course_id = 'C04';

-- Phần V - Truy vấn dữ liệu
select * from student;
select * from teacher;
select * from course;
select * from enrollment;
select * from score;