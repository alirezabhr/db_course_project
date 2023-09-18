CREATE TABLE user (
	id serial primary key,
	username varchar(40) not null,
	password varchar(128) not null,
	first_name varchar(50) not null,
--	last_name varchar(50) not null,
	phone varchar(11) not null,
	address text not null,
--	wallet int not null SET DEFAULT 0,
 token uuid
);

CREATE TABLE student_membership_type (
	type varchar(30) primary key
);

CREATE TABLE degree (
	name varchar(30) primary key
);

CREATE TABLE department (
	name varchar(50) primary key
);

CREATE TABLE teacher_position (
	type varchar(30) primary key
);

CREATE TABLE employee_position (
	type varchar(30) primary key
);


/* 
user is a keyword. postgres can not recognize user table in foreign key constraint.
we can type "user" or explicitly name the table like: public.user to specify the table.
*/
CREATE TABLE teacher (
	id serial primary key,
	user_id int references "user"(id) not null,
	start_date date not null,
	position varchar(30) references teacher_position(type) not null,
	is_heyatelmi bool not null,
	department varchar(50) references department(name) not null
);


CREATE TABLE employee (
	id serial primary key,
	user_id int references public.user(id) not null,
	start_date date not null,
	position varchar(30) references employee_position(type) not null,
	department varchar(50) references department(name) not null
);


CREATE TABLE student (
	sid int primary key,
	user_id int references "user"(id) not null,
	degree varchar(30) references degree(name) not null,
	start_date date not null,
	membership_type varchar(30) references student_membership_type(type) not null,
	advisor_id int references teacher(id) not null,
	department varchar(50) references department(name) not null
);


CREATE TABLE term (
	id serial primary key,
	title varchar(50) not null,
	start_date date not null,
	finish_date date not null
);


CREATE TABLE student_term_status (
	status varchar(30) primary key
);


CREATE TABLE student__term (
	id serial primary key,
	student_id int references student(sid) not null,
	term_id int references term(id) not null,
	status varchar(30) references student_term_status(status) not null
);


CREATE TABLE course (
	id serial primary key,
	name varchar(40) not null,
	suggested_term smallint not null,
--	credit smallint not null SET DEFAULT 3,
	department varchar(50) references department(name) not null
);


CREATE TABLE course__prerequisite (
	id serial primary key,
	before int references course(id) not null,
	after int references course(id) not null,
	is_prerequisite bool not null DEFAULT false
);


CREATE TABLE class_room (
	name varchar(50) primary key
);


CREATE TABLE section (
	id serial primary key,
	class_room varchar(50) references class_room(name) not null,
	course_id int references course(id) not null,
	term_id int references term(id) not null
);


CREATE TABLE exam (
	id serial primary key,
	section_id int references section(id) not null,
	exam_date date not null,
	start_at time not null,
	end_at time not null,
	type exam_type not null
);

/*
weekday is domain which is an integer between 1 to 7.
*/
CREATE TABLE section_time (
	id serial primary key,
	section_id int references section(id) not null,
	week_day weekday not null,
	start_time time not null,
	end_time time not null
);


CREATE TABLE teacher__section (
	id serial primary key,
	teacher_id int references teacher(id) not null,
	section_id int references section(id) not null
);


CREATE TABLE student__section (
	id serial primary key,
	student_id int references student(sid) not null,
	section_id int references section(id) not null,
 mark real not null DEFAULT 0,
 is_approved bool not null DEFAULT false
);


CREATE TABLE dorm_class (
	id serial primary key,
	name varchar(2) not null,
	price smallint not null
);


CREATE TABLE dorm (
	id serial primary key,
	name varchar(40) not null,
	dorm_class_id int references dorm_class(id) not null
);


CREATE TABLE dorm_room (
	id serial primary key,
	dorm_id int references dorm(id) not null,
	number smallint not null,
	capacity smallint
);


CREATE TABLE student__dorm_room (
	id serial primary key,
	student_id int references student(sid) not null,
	dorm_room_id int references dorm_room(id) not null,
	UNIQUE(student_id, dorm_room_id)
);

CREATE TABLE exam_poll (
	id serial primary key,
	start_at timestamp not null,
	end_at timestamp not null,
	section_id int references section(id) not null,
	is_final_exam bool not null
);


CREATE TABLE exam_poll_option (
	id serial primary key,
	exam_poll_id int references exam_poll(id) not null,
	exam_date date not null,
	start_at time not null,
	end_at time not null
);


CREATE TABLE exam_poll_answer (
	id serial primary key,
	student_id int references student(sid) not null,
	exam_poll_option_id int references exam_poll_option(id) not null,
	UNIQUE(student_id, exam_poll_option_id)
);


CREATE TABLE practice_class_request_status(
	status varchar(20) primary key
);


CREATE TABLE practice_class_request (
	id serial primary key,
	student_id int references student(sid) not null,
	section_id int references section(id) not null,
	status varchar(20) references practice_class_request_status(status) not null
);


CREATE TABLE teacher_assistant_request (
	id serial primary key,
	user_id int references public.user(id) not null,
	resume BYTEA not null,
	show_courses_result bool not null DEFAULT false 
)


CREATE TABLE food (
  id serial primary key,
  name varchar(40) not null,
  base_price real not null,
  original_price real not null
);

CREATE TABLE self_restaurant (
  id serial primary key,
  title varchar(50) not null
);


CREATE TABLE meal_choice(
  name varchar(30) primary key
);


CREATE TABLE self_item (
  id serial primary key,
  self_id int references self_restaurant(id) not null,
  food_id int references food(id) not null,
  date date not null,
  meal_choice varchar(30) references meal_choice(name) not null
);


CREATE TABLE self_item_reserve (
  id serial primary key,
  self_item_id int references self_item(id) not null,
  user_id int references "user"(id) not null,
  final_price real not null
);


CREATE TABLE cafe (
  id serial primary key,
  name varchar(50) not null
);


CREATE TABLE cafe_menue_item (
  id serial primary key,
  cafe_id int references cafe(id) not null,
  name varchar(50) not null,
  ingredients varchar(200) not null,
  price real not null
);


CREATE TABLE cafe_order (
  id serial primary key,
  cafe_id int references cafe(id) not null,
  user_id int references "user"(id) not null,
  date_time timestamp not null,
  final_price real not null
);




