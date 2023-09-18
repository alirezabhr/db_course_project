CREATE DOMAIN weekday INTEGER CHECK (1 <= value and value <= 7);
CREATE TYPE exam_type AS ENUM ('final', 'midterm', 'quiz');