/* Simple selections */
-- select * from student_membership_type;
-- select * from degree;
-- select * from teacher_position;
-- select * from employee_position;
-- select * from student_term_status;
-- select * from practice_class_request_status;

-- SELECT * FROM department;
-- SELECT * FROM public.user;
-- SELECT * FROM teacher;
-- SELECT * FROM student join public.user on student.user_id = public.user.id;
-- SELECT * FROM term;



/* BACKEND QUERIES */


/* get all departments */
SELECT * FROM department;

/* select all sections in a term and a specific department */
SELECT * 
FROM section JOIN course ON section.course_id=course.id
WHERE section.term_id=1 AND course.department='Computer Science';

/* get all sections that a student can register 
   in a department based on the courses they have passed and the prerequisites */
SELECT * FROM get_student_course_registration_sections(4000000, 1, 'Computer Science');

/* create a new student section */
INSERT INTO 
student__section (student_id, section_id)
VALUES (4000000, 1);

/* delete a student section */
DELETE
FROM student__section 
WHERE id=1;

/* computes the average grade average in a depatment in a specific term */
SELECT * FROM get_department_average(1, 'Computer Science');

/* retreives the chart for a specific department */
SELECT * FROM get_chart('Computer Science');

/* retrieves a user based on username and password */
SELECT *
FROM public.user
WHERE username='username' AND password='password';

/* updates user token */
UPDATE public.user
SET token='';

/* getting section detail in multipule queries */
SELECT *
FROM section
WHERE id=1;

SELECT *
FROM course
WHERE id=1;

SELECT teacher.id AS id, public.user.first_name, public.user.last_name
FROM teacher__section JOIN teacher ON teacher__section.teacher_id=teacher.id
JOIN public.user ON public.user.id=teacher.user_id
WHERE section_id=1;

SELECT *
FROM section_time
WHERE section_id=1;

/* geting all students enrolled in a section */
SELECT * 
FROM student__section JOIN student ON student__section.student_id=student.sid
JOIN public.user ON student.user_id = public.user.id
WHERE section_id=1;

/* gets all practice_class_requests in a section */
SELECT * 
FROM practice_class_request JOIN student ON practice_class_request.student_id=student.sid
WHERE practice_class_request.section_id=1
ORDER BY practice_class_request.id DESC;

/* updates the status of a practice_class_request */
UPDATE practice_class_request 
SET status='Approved' WHERE id=1;

/* create a new exam_poll */
INSERT INTO exam_poll 
(start_at, end_at, section_id, type, title) 
VALUES ('2022-10-10 12:00', '2022-10-12 12:00', 1, 'final', 'title');

/* gets detail info of a student */
SELECT *
FROM student JOIN public.user ON student.user_id=public.user.id
WHERE student.sid=4000000;

/* gets all terms of a student */
SELECT *
FROM student__term JOIN term ON student__term.term_id=term.id
WHERE student__term.student_id=4000000
ORDER BY term.start_date DESC;

/* gets all sections a student is enrolled in, in a specific term */
SELECT section.*, course.name as course_name, course.department, course.credit, student__section.is_approved
FROM student__section JOIN section ON student__section.section_id=section.id
JOIN course ON course.id=section.course_id
WHERE student_id=4000000 AND section.term_id=1;

/* create a practice_class_request */
INSERT INTO practice_class_request (student_id, section_id)
VALUES (4000000, 1);

/* gets all practice_class_requests in a section that was created by a specific student */
SELECT * 
FROM practice_class_request
WHERE student_id=4000000 AND section_id=1
ORDER BY id DESC;

/* gets all of a students deadlines in a term */
SELECT course.id as course_id, course.name as course_name, exam.*  
FROM exam JOIN section ON exam.section_id=section.id JOIN course ON section.course_id=course.id
WHERE exam.section_id IN     
(SELECT section_id
FROM student__section JOIN section ON student__section.section_id=section.id
WHERE student_id=4000000 AND term_id =1);

/* gets student terms */
SELECT *
FROM student__term JOIN term ON student__term.term_id=term.id
WHERE student__term.student_id=4000000
ORDER BY term.start_date DESC;


/* gets student report card of a term */
SELECT * FROM get_student_courses_report_by_term(4000000, 1);

/* gets average of a department average grade in a term */
SELECT * FROM get_department_average('Computer Science', 1);

/* get all teacher terms */
SELECT * FROM term WHERE id IN
(SELECT section.term_id FROM teacher__section JOIN section ON teacher__section.section_id=section.id
WHERE teacher_id=3)
ORDER BY term.start_date DESC;

/* gets all sections of a teacher in a specific term */
SELECT section.*, course.name as course_name, course.department, course.credit
FROM teacher__section JOIN section ON teacher__section.section_id=section.id
JOIN course ON course.id=section.course_id
WHERE teacher_id=3 AND section.term_id=1;

/* get all advised students of a specific advisor(teacher) */
SELECT * FROM student 
JOIN public.user ON public.user.id = student.user_id
WHERE advisor_id=3
ORDER BY sid DESC;

/* update status of course registration */
UPDATE student__section 
SET is_approved=true 
WHERE id=1;

/* gets all deadlines of a teacher in a term */
SELECT course.id as course_id, course.name as course_name, exam.*  
FROM exam JOIN section ON exam.section_id=section.id JOIN course ON section.course_id=course.id
WHERE exam.section_id IN     
(SELECT section_id
FROM teacher__section JOIN section ON teacher__section.section_id=section.id
WHERE teacher_id=%d AND term_id =%d);
