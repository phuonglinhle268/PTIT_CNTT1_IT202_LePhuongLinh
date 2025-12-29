create database session03;
use session03;

create table student (
	student_id int auto_increment primary key,
	full_name varchar(30) not null,
	date_of_birth date,
    email varchar(20)
);

create table subjects (
	subject_id int auto_increment primary key,
    subject_name varchar(50) not null unique,
    credit int not null,
    check(credit > 0)
);

create table enrollment (
	enroll_date date not null,
	student_id int not null,
    subject_id int not null,
    primary key(student_id, subject_id),
    foreign key (student_id) references student(student_id),
    foreign key (subject_id) references subjects(subject_id)
);

create table score (
	student_id int not null,
    subject_id int not null,
    mid_score decimal(4,2),
    final_score decimal(4,2),
    
    primary key(student_id, subject_id),
    foreign key (student_id) references student(student_id),
    foreign key (subject_id) references subjects(subject_id),
    
    check (mid_score >= 0 and mid_score <= 10),
    check (final_score >= 0 and final_score <= 10)
);

-- thêm sinh viên
insert into student(full_name, date_of_birth, email) values 
	('Nguyễn Văn A', '2006-12-12', 'nva@gmail.com'),
    ('Nguyễn Văn B', '2006-10-12', 'nvb@gmail.com'),
	('Nguyễn Văn C', '2006-09-11', 'nvc@gmail.com');

-- bài 2
select * from student;  -- lấy toàn bộ
select student_id, full_name from student;  --  lấy id và tên

-- bài 3
update student
set email = 'student3@mail.com' where student_id = 3;
update student
set date_of_birth = '2005-08-05' where student_id = 2;
delete from student where student_id = 5;

-- bài 4
insert into subjects(subject_name, credit) values 
	('Cơ sở dữ liệu', 3),
    ('Tiếng Anh', 4),
    ('Mạng máy tính', 1),
    ('ReactJS', 2);
    
update subjects
set credit = 5 where subject_id = 3;
update subjects
set subject_name = 'Học IT' where subject_name = 'Tiếng Anh';
select * from subjects;


-- bài 5
insert into enrollment(student_id, subject_id, enroll_date) values
	(1, 1, '2025-10-10'),
	(1, 2, '2025-10-10'),
	(3, 3, '2025-09-03');
select * from enrollment;
select * from enrollment where student_id = 1;  -- lấy lượt đăng kí của sinh viên

-- bài 6
-- thêm điểm cho 2 sinh viên
insert into score(student_id, subject_id, mid_score, final_score) values
	(1, 1, 8, 10),
	(1, 2, 9, 9),
	(2, 1, 7.5, 7.3),
	(2, 3, 10, 10);
-- cập nhập điểm cuối kì cho 1 sinh viên
update score
set final_score = 9.2 where student_id = 2 and subject_id = 1;
-- sinh viên điểm cuối kì từ 8
select * from score where final_score >= 8;

select * from score;

-- bài 7
-- xóa 1 lượt
delete from enrollment where student_id = 1 and subject_id = 1;

-- lấy danh sách sinh viên và điểm tương ứng
select 
    student.student_id,
    student.full_name,
    subjects.subject_name,
    score.mid_score,
    score.final_score
from student, subjects, score
where student.student_id = score.student_id
  and subjects.subject_id = score.subject_id;



