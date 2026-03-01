-- ================================
-- Gradebook System Database Script
-- ================================

-- 1. Create and use database (safe to re-run)
CREATE DATABASE IF NOT EXISTS GradebookSystem;
USE GradebookSystem;

-- 2. Drop tables if they already exist (order matters)
DROP TABLE IF EXISTS Submissions;
DROP TABLE IF EXISTS Grades;
DROP TABLE IF EXISTS Assignments;
DROP TABLE IF EXISTS Students;
DROP TABLE IF EXISTS Classes;

-- 3. Create Students table
CREATE TABLE Students (
    student_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL
);

-- 4. Create Classes table
CREATE TABLE Classes (
    class_id INT AUTO_INCREMENT PRIMARY KEY,
    class_name VARCHAR(100) NOT NULL
);

-- 5. Create Assignments table
CREATE TABLE Assignments (
    assignment_id INT AUTO_INCREMENT PRIMARY KEY,
    class_id INT NOT NULL,
    title VARCHAR(100) NOT NULL,
    due_date DATE NOT NULL,
    points INT NOT NULL,
    FOREIGN KEY (class_id) REFERENCES Classes(class_id)
        ON DELETE CASCADE
);

-- 6. Create Grades table
CREATE TABLE Grades (
    grade_id INT AUTO_INCREMENT PRIMARY KEY,
    student_id INT NOT NULL,
    assignment_id INT NOT NULL,
    score INT,
    FOREIGN KEY (student_id) REFERENCES Students(student_id)
        ON DELETE CASCADE,
    FOREIGN KEY (assignment_id) REFERENCES Assignments(assignment_id)
        ON DELETE CASCADE,
    UNIQUE (student_id, assignment_id)
);

-- 7. Create Submissions table
CREATE TABLE Submissions (
    student_id INT NOT NULL,
    assignment_id INT NOT NULL,
    submitted BOOLEAN DEFAULT FALSE,
    PRIMARY KEY (student_id, assignment_id),
    FOREIGN KEY (student_id) REFERENCES Students(student_id)
        ON DELETE CASCADE,
    FOREIGN KEY (assignment_id) REFERENCES Assignments(assignment_id)
        ON DELETE CASCADE
);

-- ================================
-- SAMPLE DATA (10 students)
-- ================================

-- 8. Insert Students
INSERT INTO Students (name, email) VALUES
('Alice Johnson', 'alice@example.com'),
('Bob Smith', 'bob@example.com'),
('Charlie Brown', 'charlie@example.com'),
('David Lee', 'david@example.com'),
('Eva Green', 'eva@example.com'),
('Frank White', 'frank@example.com'),
('Grace Kim', 'grace@example.com'),
('Hannah Scott', 'hannah@example.com'),
('Ian Miller', 'ian@example.com'),
('Julia Adams', 'julia@example.com');

-- 9. Insert Classes
INSERT INTO Classes (class_name) VALUES
('Math 101'),
('Computer Science 101');

-- 10. Insert Assignments
INSERT INTO Assignments (class_id, title, due_date, points) VALUES
(1, 'Homework 1', '2026-02-01', 100),
(1, 'Homework 2', '2026-02-15', 100),
(2, 'Project 1', '2026-03-01', 200);

-- 11. Insert Grades
INSERT INTO Grades (student_id, assignment_id, score) VALUES
(1, 1, 95),
(1, 2, 88),
(2, 1, 70),
(3, 1, 60),
(4, 1, 85),
(5, 1, 92),
(6, 2, 78),
(7, 2, 80),
(8, 1, 55),
(9, 2, 100),
(10, 1, 90);

-- 12. Insert Submissions
INSERT INTO Submissions (student_id, assignment_id, submitted) VALUES
(1, 1, TRUE),
(1, 2, TRUE),
(2, 1, TRUE),
(2, 2, FALSE),
(3, 1, TRUE),
(3, 2, FALSE),
(4, 1, TRUE),
(4, 2, FALSE),
(5, 1, TRUE),
(5, 2, FALSE),
(6, 1, FALSE),
(6, 2, TRUE),
(7, 1, FALSE),
(7, 2, TRUE),
(8, 1, TRUE),
(8, 2, FALSE),
(9, 1, FALSE),
(9, 2, TRUE),
(10, 1, TRUE),
(10, 2, FALSE);

-- ================================
-- TEST QUERIES
-- ================================

-- View all grades
SELECT s.name, a.title, g.score
FROM Grades g
JOIN Students s ON g.student_id = s.student_id
JOIN Assignments a ON g.assignment_id = a.assignment_id;

-- Find missing assignments
SELECT s.name, a.title
FROM Submissions sub
JOIN Students s ON sub.student_id = s.student_id
JOIN Assignments a ON sub.assignment_id = a.assignment_id
WHERE sub.submitted = FALSE;

-- Calculate student averages
SELECT s.name, AVG(g.score) AS average_score
FROM Grades g
JOIN Students s ON g.student_id = s.student_id
GROUP BY s.student_id;

-- ================================
-- TASK 2: Grade Calculator Queries
-- ================================

-- 1. Calculate a student’s average (percentage based on points) for all students
SELECT s.name,
       SUM(g.score) AS total_score,
       SUM(a.points) AS total_points,
       (SUM(g.score)/SUM(a.points))*100 AS average_percentage
FROM Grades g
JOIN Assignments a ON g.assignment_id = a.assignment_id
JOIN Students s ON g.student_id = s.student_id
GROUP BY s.name;

-- 2. Find missing assignments for all students
SELECT s.name, a.title AS missing_assignment
FROM Students s
JOIN Assignments a
LEFT JOIN Grades g ON s.student_id = g.student_id AND a.assignment_id = g.assignment_id
WHERE g.score IS NULL
ORDER BY s.name;

-- 3. Detect failing students (average < 60%)
SELECT s.name,
       (SUM(g.score)/SUM(a.points))*100 AS average_percentage
FROM Grades g
JOIN Assignments a ON g.assignment_id = a.assignment_id
JOIN Students s ON g.student_id = s.student_id
GROUP BY s.student_id, s.name
HAVING average_percentage < 60;

-- 4. Update a student’s grade
-- Example: Update Alice’s Homework 2 score to 92
UPDATE Grades
SET score = 92
WHERE student_id = 1 AND assignment_id = 2;

-- 5. Optional: View updated averages after updating a grade
SELECT s.name,
       SUM(g.score) AS total_score,
       SUM(a.points) AS total_points,
       (SUM(g.score)/SUM(a.points))*100 AS average_percentage
FROM Grades g
JOIN Assignments a ON g.assignment_id = a.assignment_id
JOIN Students s ON g.student_id = s.student_id
GROUP BY s.name;