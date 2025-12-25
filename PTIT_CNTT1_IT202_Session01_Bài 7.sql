create database session01_bai6;
use session01_bai6;

create table student (
    student_id int auto_increment primary key unique,
    student_name varchar(50) not null,
    email varchar(50)
);

create table subject (
    subject_id int auto_increment primary key,
    subject_code varchar(20) not null,
    subject_name varchar(50) not null,
    credit int not null,
    student_id int,
    foreign key (student_id) references student(student_id)
);

create table learning_goal (
    goal_id int auto_increment primary key,
    goal_content text not null,
    created_at datetime not null,
    subject_id int,
	foreign key (subject_id) references subject(subject_id)
);

create table class_schedule (
    class_schedule_id int auto_increment primary key,
    study_date date not null,
    start_time time not null,
    end_time time not null,
    note varchar(100),
    subject_id int,
    foreign key (subject_id) references subject(subject_id)
);

create table study_schedule (
    study_schedule_id int auto_increment primary key,
    study_date date not null,
    start_time time not null,
    end_time time not null,
    content text not null,
    subject_id int,
    foreign key (subject_id) references subject(subject_id)
);

create table material (
    material_id int auto_increment primary key,
    material_name varchar(100) not null,
    material_type varchar(30),
    storage_path varchar(100),
    subject_id int,
    foreign key (subject_id) references subject(subject_id)
);

create table schedule_material (
    study_schedule_id int,
    material_id int,
    primary key (study_schedule_id, material_id),
    foreign key (study_schedule_id) references study_schedule(study_schedule_id),
    foreign key (material_id) references material(material_id)
);
