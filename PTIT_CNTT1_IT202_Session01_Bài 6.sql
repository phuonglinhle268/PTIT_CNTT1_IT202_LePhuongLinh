create database session01_bai5;
use session01_bai5;

create table subject (
    subject_id int auto_increment primary key,
    subject_name varchar(100) not null unique,
    credit_hours int not null
);

create table learning_goal (
    goal_id int auto_increment primary key,
    goal_content varchar(200) not null,
    created_at datetime not null,
    subject_id int not null,
    foreign key (subject_id) references subject(subject_id)
);

create table study_class (
    class_id int auto_increment primary key,
    study_date date not null,
    start_time time not null,
    end_time time not null,
    note varchar(100),
    subject_id int not null,
    foreign key (subject_id) references subject(subject_id)
);

create table study_schedule (
    schedule_id int auto_increment primary key,
    study_date date not null,
    start_time time not null,
    end_time time not null,
    content varchar(200),
    subject_id int not null,
    foreign key (subject_id) references subject(subject_id)
);

create table study_material (
    material_id int auto_increment primary key,
    material_name varchar(100) not null,
    material_type varchar(50),
    file_path varchar(150),
    subject_id int not null,
    foreign key (subject_id) references subject(subject_id)
);

create table schedule_material (
    schedule_id int not null,
    material_id int not null,
    primary key (schedule_id, material_id),
    foreign key (schedule_id) references study_schedule(schedule_id),
    foreign key (material_id) references study_material(material_id)
);
