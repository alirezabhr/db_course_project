-- /* Table: user */
INSERT INTO public.user (username, password, first_name, last_name, phone, address) VALUES 
	('bahrol_username', 'bahrol_password', 'Alireza', 'Bahrol', '0917434', 'maliabad'),
	('arefeh_username', 'arefehe_password',  'Arefeh', 'Ahmadi', '0922164', 'motahari'),
	('ali_username', 'ali_password',  'Ali', 'Mahdiyar', '0917321', 'somewhere'),
	('sina_username', 'sina_password', 'Sina', 'Parvizi', '0917712', 'berlin'),
	('kesht_username', 'kesht_password', 'Morteza', 'Keshtkaran', '0917283', 'dont know'),
	('taheri_username', 'taheri_password', 'Mohammad', 'Taheri', '0917284', 'dont know'),
	('farshad_username', 'farshad_password', 'Farshad', 'Khoonjoosh', '0917294', 'dont know');


-- /* Table: department */ 
INSERT INTO department VALUES
	('Computer Science'),
	('Chemical Engineering'),
	('Mathematics'),
	('Economy'),
	('Physics');


-- /* Table: teacher */
INSERT INTO teacher (user_id, start_date, position, is_heyatelmi, department) VALUES
	(7, DATE '2015-12-17', 'Associate Professor', TRUE, 'Computer Science'),
	(8, DATE '2015-12-17', 'Full Professor', TRUE, 'Computer Science');

 
INSERT INTO student (sid, user_id, degree, start_date, membership_type, advisor_id, department) VALUES
	(9832089, 2, 'Bachelor', DATE '2019-6-10', 'Public', 2, 'Computer Science'),
	(9931172, 3, 'Bachelor', DATE '2020-6-10', 'Public', 2, 'Computer Science'),
	(9412314, 5, 'Master', DATE '2022-6-10', 'Private', 3, 'Computer Science'),
	(893214, 4, 'Doctoral', DATE '2018-6-10', 'Guest', 3, 'Computer Science');

-- /* test to show student won't be created with same username */
INSERT INTO student (user_id, degree, start_date, membership_type, advisor_id, department) VALUES
	(2, 'Bachelor', DATE '2019-6-10', 'Public', 2, 'Computer Science');


INSERT INTO term (title, start_date, finish_date) VALUES 
	('fall 1400', DATE '2021-9-1', DATE '2022-2-10'),
	('spring 1400', DATE '2022-3-1', DATE '2022-7-10');


INSERT INTO student__term (student_id, term, status) VALUES
	(9832089, 2, 'Course Registration'),
	(9832089, 3, 'Course Registration'),
	(9931172, 2, 'Course Registration'),
	(9931172, 3, 'Course Registration'),
	(9412314, 2, 'Leave of Absence'),
	(9412314, 3, 'Course Registration'),
	(893214, 2, 'Leave of Absence'),
	(893214, 3, 'Course Registration');


INSERT INTO course (name, suggested_term, department) VALUES
	('Discreate Math', 1, 'Computer Science'),
	('Computer Architecture', 2, 'Computer Science'),
	('Logic Circuits Design', 1, 'Computer Science'),
	('Numerical Analysis Method', 2, 'Computer Science');


INSERT INTO course__prerequisite (before, after, is_prerequisite) VALUES
	(1, 3, FALSE),
	(3, 2, TRUE);

