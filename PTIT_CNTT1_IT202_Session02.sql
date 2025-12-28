create database session02;
use session02;

-- bài 2
create table class (
	class_id int auto_increment primary key,
	class_name varchar(100) not null,
	school_year varchar(20)
);

create table student (
	student_id int auto_increment primary key,
	fullname varchar(30) not null,
	dob date,
    class_id int not null,
	foreign key (class_id) references class(class_id)
);

-- bài 3
create table subject (
	subject_id int auto_increment primary key,
    subject_name varchar(50) not null unique,
    credit int not null,
    check(credit > 0)
);

-- bài 4
create table enrollment (
	enroll_date date not null,
	student_id int not null,
    subject_id int not null,
    primary key(student_id, subject_id),
    foreign key (student_id) references student(student_id),
    foreign key (subject_id) references subject(subject_id)
);

-- bài 5
create table teacher (
	teacher_id int auto_increment primary key,
    teacher_name varchar(20) not null,
    email varchar(30) not null unique
);

alter table subject 
add teacher_id int not null,
add constraint subject_teacher
	foreign key (teacher_id) references teacher(teacher_id);
    
-- bài 6
create table score (
	student_id int not null,
    subject_id int not null,
    process_score decimal,
    final_score decimal,
    
    primary key(student_id, subject_id),
    foreign key (student_id) references student(student_id),
    foreign key (subject_id) references subject(subject_id),
    
    check (process_score >= 0 and process_score <= 10),
    check (final_score >= 0 and final_score <= 10)
);
