
/* login procedure */
CREATE PROCEDURE login (
	username varchar
	password varchar
)
LANGUAGE plpgsql    
AS $$
BEGIN
    ((SELECT student WHERE student.username = username AND student.password = password)
	UNION
	(SELECT teacher WHERE teacher.username = username AND teacher.password = password)
	UNION
	(SELECT employee WHERE employee.username = username AND employee.password = password))
	NATURAL JOIN
	public.user

END;$$



-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 

/* check unique username from each type of user
   our designed changed half way and we decided to keep
   username and password in student, teacher and empolyee instead of user
   and this part is from that time
   
   now we keep username and password in user*/
CREATE FUNCTION trigger_check_username()
RETURNS TRIGGER AS $$
BEGIN
	IF NEW.username IN (
		(SELECT username FROM student)
		UNION
		(SELECT username FROM teacher)
		UNION
		(SELECT username FROM employee)
	) THEN
        RETURN NULL;
	END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;


CREATE TRIGGER check_username BEFORE INSERT ON student
FOR EACH ROW
EXECUTE PROCEDURE trigger_check_username();

CREATE TRIGGER check_username BEFORE INSERT ON teacher
FOR EACH ROW
EXECUTE PROCEDURE trigger_check_username();

CREATE TRIGGER check_username BEFORE INSERT ON employee
FOR EACH ROW
EXECUTE PROCEDURE trigger_check_username();


-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 

/* returns the report card of a student */
CREATE OR REPLACE FUNCTION get_student_courses_report(student_id INTEGER)
RETURNS TABLE(
	term_id int, term_title varchar, course_id int, course_name varchar,
	credit smallint, avg numeric, max int, min int, mark int)
AS $$
BEGIN
RETURN QUERY 
   
   SELECT term.id AS term_id, term.title AS term_title, course.id AS course_id,
   		course.name AS course_name, course.credit, aggregate_data.avg, aggregate_data.max,
		aggregate_data.min, student__section.mark
	FROM (SELECT 
		section.term_id, section.id AS section_id, section.course_id, AVG(student__section.mark),
		MAX(student__section.mark), MIN(student__section.mark)
		FROM section JOIN student__section ON section.id=student__section.section_id
		WHERE 
		  section.term_id in (SELECT student__term.term_id FROM student__term WHERE student__term.student_id = $1) AND
		  section.id in (SELECT student__section.section_id FROM student__section WHERE student__section.student_id = $1)
		GROUP BY section.term_id, section.id, section.course_id) AS aggregate_data
	JOIN student__section ON student__section.section_id = aggregate_data.section_id
	AND student__section.student_id = $1
	JOIN course ON aggregate_data.course_id = course.id
	JOIN term ON aggregate_data.term_id = term.id
	ORDER BY term.start_date DESC, course_id;
   
END; $$ LANGUAGE plpgsql;


-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 

/* returns the report card of a student for a specific term */
CREATE OR REPLACE FUNCTION get_student_courses_report_by_term(student_id_ INTEGER, term_id_ INTEGER)
RETURNS TABLE(
	term_id int, course_id int, course_name varchar, credit smallint,
	avg numeric, max int, min int, mark int)
AS $$
BEGIN
RETURN QUERY 
   
   SELECT aggregate_data.term_id, course.id AS course_id,
   		course.name AS course_name, course.credit, aggregate_data.avg, aggregate_data.max,
		aggregate_data.min, student__section.mark
	FROM (SELECT 
		section.term_id, section.id AS section_id, section.course_id, AVG(student__section.mark),
		MAX(student__section.mark), MIN(student__section.mark)
		FROM section JOIN student__section ON section.id=student__section.section_id
		WHERE 
		  section.term_id = $2 AND
		  section.id in (SELECT student__section.section_id FROM student__section WHERE student__section.student_id = $1)
		GROUP BY section.term_id, section.id, section.course_id) AS aggregate_data
	JOIN student__section ON student__section.section_id = aggregate_data.section_id
	AND student__section.student_id = $1
	JOIN course ON aggregate_data.course_id = course.id
	ORDER BY course_id;
   
END; $$ LANGUAGE plpgsql;


-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 

/* returns the average average grade of a department in a term */
CREATE OR REPLACE FUNCTION get_department_average(department_name VARCHAR, term_id INTEGER)
RETURNS TABLE(department varchar, avg numeric)
AS $$
BEGIN
RETURN QUERY 
   
	SELECT student.department, AVG(individual_average.avg) FROM
		(
			SELECT student__section.student_id, AVG(student__section.mark) 
			FROM student__section JOIN section ON student__section.section_id=section.id
			WHERE section.term_id= $2
			GROUP BY student__section.student_id
		) as individual_average
		JOIN student ON student.sid=individual_average.student_id
		GROUP BY student.department
		HAVING student.department = $1;
  
END; $$ LANGUAGE plpgsql;


-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --


/* returns all valid sections a student can choose in course registration */
CREATE OR REPLACE FUNCTION get_student_course_registration_sections(
	studen_id INTEGER,
	term_id INTEGER,
	department VARCHAR)
RETURNS TABLE(
   section_id int,
   course_id int,
   course_name varchar,
   credit smallint,
   week_day weekday,
   start_time time,
   end_time time
)
AS $$
BEGIN
RETURN QUERY 
   
	SELECT section.id as section_id, course.id as course_id, 
		course.name as course_name, course.credit,
		section_time.week_day, section_time.start_time, section_time.end_time
	FROM section 
	JOIN course ON section.course_id=course.id
	LEFT JOIN section_time ON section_time.section_id=section.id

	WHERE section.term_id = $2 AND
	section.course_id IN (

	SELECT course.id
	FROM course 
	WHERE course.department = $3 AND
	  NOT EXISTS ( 
	  SELECT course__prerequisite.before
	  FROM course__prerequisite
	  WHERE course__prerequisite.after = course.id AND course__prerequisite.is_prerequisite=true
	  AND course__prerequisite.before NOT IN 
		( SELECT course.id 
		FROM student__section JOIN section ON student__section.section_id=section.id
		JOIN course ON section.course_id=course.id
		WHERE student__section.student_id=$1 AND student__section.mark >= 10
		)  
	) AND course.id NOT IN 
	  ( SELECT course.id
	   FROM student__section JOIN section ON student__section.section_id=section.id
	   JOIN course ON section.course_id=course.id
	   WHERE student__section.student_id=$1 AND student__section.mark >= 10
	  )
	) ORDER BY section.id DESC;  

END; $$ LANGUAGE plpgsql;



-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 


/* retrieves the chart of a department */
CREATE OR REPLACE FUNCTION get_chart(department_name VARCHAR)
RETURNS TABLE(
  course_id int,
  course_name varchar,
  suggested_term smallint,
  credit smallint,
  pishniaz_course_term varchar
)
AS $$
BEGIN
RETURN QUERY 
   
	SELECT course_pishniaz.course_id, course_pishniaz.course_name, course_pishniaz.suggested_term,
		course_pishniaz.credit, course.name AS pishniaz_course_name FROM
		(
			SELECT course.id AS course_id, course.suggested_term, course.credit,
			course.name AS course_name, course__prerequisite.before,
			course__prerequisite.is_prerequisite FROM
				course LEFT JOIN course__prerequisite ON course.id=course__prerequisite.after
				WHERE course.department=$1
		) AS course_pishniaz
		LEFT JOIN course ON course.id = course_pishniaz.before
		ORDER BY suggested_term;
   
END; $$ LANGUAGE plpgsql;



-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 


/* checks intersection of a new section a student wants to choose and previous choosen
   sections in a term, used in registration course */
CREATE OR REPLACE FUNCTION check_intersection(student_id_ int, section_id_ int)
RETURNS int AS $$
BEGIN

	RETURN (
		SELECT COUNT(*) FROM (
			SELECT * FROM section JOIN section_time AS selected_time ON section.id=selected_time.section_id
			WHERE NOT EXISTS (
			  SELECT *
			  FROM section_time
			  WHERE section_time.section_id IN (
				SELECT student__section.section_id 
				FROM student__section JOIN section ON student__section.section_id=section.id
				WHERE student__section.student_id=$1 AND section.term_id = (SELECT term_id FROM section AS S2 WHERE S2.id = $2)
			  ) 
			  AND(section_time.week_day = selected_time.week_day
			  AND ((selected_time.start_time BETWEEN section_time.start_time AND section_time.end_time)
			  OR (selected_time.end_time BETWEEN section_time.start_time AND section_time.end_time )))
			) AND section.id=$2
		) AS with_out_intersection
	);

END; $$ LANGUAGE plpgsql;



-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 


/* trigger to stop two sections with time intersection from being created (selected) */
CREATE OR REPLACE FUNCTION check_value_before_insert()
	RETURNS TRIGGER AS $$
	BEGIN

		IF (select check_intersection(NEW.student_id, NEW.section_id)) != 0 THEN
			RETURN NEW;
		ELSE
			RAISE EXCEPTION 'Intersection found!';
		END IF;

	END; $$ LANGUAGE plpgsql;
	

CREATE OR REPLACE TRIGGER check_section_intersection BEFORE INSERT ON student__section
FOR EACH ROW
EXECUTE PROCEDURE check_value_before_insert();




-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 


/* checks if a exam poll option is valid and doesn't intersect with
   students' other exams */
CREATE OR REPLACE FUNCTION check_exam_intersection( 
  section_id_ int,
   date_ date,
   start_at_ time,
   end_at_ time)
RETURNS TABLE(
  exam_date date,
  start_at time,
  end_at time
)
AS $$
BEGIN
RETURN QUERY 
   

 SELECT exam.exam_date, exam.start_at, exam.end_at FROM exam
 WHERE 
 exam.section_id IN
  (SELECT student__section.section_id FROM student__section
    WHERE student__section.student_id IN 
     (SELECT student__section.student_id FROM student__section WHERE student__section.section_id=$1)
  )
 AND date != $2 OR NOT (start_at BETWEEN $3 AND $4 AND end_at BETWEEN $3 AND $4);

END; $$ LANGUAGE plpgsql;



-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 

