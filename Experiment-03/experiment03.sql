-- =====================================================================
-- EXPERIMENT 03
-- Title: Employee-Department-Project Relational Schema
-- Aim: To design an Employee-Department-Project relational schema in MySQL,
--      populate it with 30 employees across 5 departments and 8 projects,
--      and write SQL queries demonstrating selection, projection, aggregate
--      functions, GROUP BY, HAVING, CASE expressions and ORDER BY.
-- Student: Sayna Bhramer | UID: 25LBCS3252
-- DBMS: MySQL Server 8.0 (Community Edition)
-- =====================================================================

-- Create and select the database
CREATE DATABASE IF NOT EXISTS company_db;
USE company_db;

-- =====================================================================
-- 5.1 DDL — CREATE TABLES
-- =====================================================================

-- 1. DEPARTMENT
CREATE TABLE department (
    dept_id INT PRIMARY KEY,
    dept_name VARCHAR(50) NOT NULL UNIQUE,
    location VARCHAR(50) NOT NULL
);

-- 2. EMPLOYEE (self-referencing FK for manager)
CREATE TABLE employee (
    emp_id INT PRIMARY KEY,
    emp_name VARCHAR(50) NOT NULL,
    gender ENUM('Male','Female') NOT NULL,
    salary DECIMAL(10,2) NOT NULL CHECK (salary > 0),
    hire_date DATE NOT NULL,
    dept_id INT,
    manager_id INT,
    CONSTRAINT fk_emp_dept FOREIGN KEY (dept_id)
        REFERENCES department(dept_id) ON DELETE SET NULL,
    CONSTRAINT fk_emp_mgr FOREIGN KEY (manager_id)
        REFERENCES employee(emp_id) ON DELETE SET NULL
);

-- 3. PROJECT
CREATE TABLE project (
    project_id INT PRIMARY KEY,
    project_name VARCHAR(60) NOT NULL UNIQUE,
    dept_id INT NOT NULL,
    budget DECIMAL(12,2) NOT NULL,
    start_date DATE NOT NULL,
    CONSTRAINT fk_proj_dept FOREIGN KEY (dept_id)
        REFERENCES department(dept_id)
);

-- 4. WORKS_ON (M:N bridge between EMPLOYEE and PROJECT)
CREATE TABLE works_on (
    emp_id INT,
    project_id INT,
    hours_worked INT NOT NULL DEFAULT 0,
    PRIMARY KEY (emp_id, project_id),
    CONSTRAINT fk_wo_emp FOREIGN KEY (emp_id)
        REFERENCES employee(emp_id) ON DELETE CASCADE,
    CONSTRAINT fk_wo_proj FOREIGN KEY (project_id)
        REFERENCES project(project_id) ON DELETE CASCADE
);

-- =====================================================================
-- 5.2 DML — INSERT SAMPLE DATA
-- =====================================================================

-- 5 departments
INSERT INTO department (dept_id, dept_name, location) VALUES 
(1, 'IT', 'Noida'),
(2, 'HR', 'Lucknow'),
(3, 'Finance', 'Mumbai'),
(4, 'Marketing', 'Delhi'),
(5, 'Operations', 'Bengaluru');

-- 30 employees (6 per department)
INSERT INTO employee (emp_id, emp_name, gender, salary, hire_date, dept_id, manager_id) VALUES
(101, 'Aarav', 'Male', 65000, '2021-01-15', 1, NULL),
(102, 'Priya', 'Female', 58000, '2021-03-20', 1, 101),
(103, 'Rahul', 'Male', 72000, '2020-07-10', 1, 101),
(104, 'Sneha', 'Female', 55000, '2022-02-11', 1, 103),
(105, 'Aditya', 'Male', 48000, '2023-06-05', 1, 103),
(106, 'Neha', 'Female', 62000, '2020-05-18', 1, 101),
(107, 'Rohan', 'Male', 52000, '2019-08-01', 2, NULL),
(108, 'Ananya', 'Female', 60000, '2020-09-14', 2, 107),
(109, 'Karan', 'Male', 45000, '2023-01-09', 2, 107),
(110, 'Ishita', 'Female', 57000, '2021-11-22', 2, 108),
(111, 'Vivek', 'Male', 49000, '2022-07-18', 2, 108),
(112, 'Meera', 'Female', 68000, '2019-11-25', 2, 107),
(113, 'Arjun', 'Male', 75000, '2020-02-14', 3, NULL),
(114, 'Kavya', 'Female', 65000, '2021-05-17', 3, 113),
(115, 'Manish', 'Male', 55000, '2022-03-28', 3, 113),
(116, 'Pooja', 'Female', 59000, '2021-09-06', 3, 114),
(117, 'Sahil', 'Male', 51000, '2023-04-12', 3, 114),
(118, 'Divya', 'Female', 70000, '2020-08-19', 3, 113),
(119, 'Varun', 'Male', 58000, '2019-12-02', 4, NULL),
(120, 'Riya', 'Female', 62000, '2020-06-16', 4, 119),
(121, 'Aditi', 'Female', 56000, '2022-05-23', 4, 119),
(122, 'Kunal', 'Male', 48000, '2023-02-15', 4, 120),
(123, 'Simran', 'Female', 46000, '2023-08-21', 4, 120),
(124, 'Tanya', 'Female', 66000, '2020-12-01', 4, 119),
(125, 'Mohit', 'Male', 61000, '2021-02-10', 5, NULL),
(126, 'Yash', 'Male', 54000, '2022-01-17', 5, 125),
(127, 'Naina', 'Female', 52000, '2022-10-03', 5, 125),
(128, 'Rajat', 'Male', 50000, '2023-03-14', 5, 126),
(129, 'Nikhil', 'Male', 51000, '2023-07-24', 5, 126),
(130, 'Sakshi', 'Female', 67000, '2020-10-09', 5, 125);

-- 8 projects
INSERT INTO project (project_id, project_name, dept_id, budget, start_date) VALUES 
(1, 'ERP Development', 1, 1500000, '2024-01-10'),
(2, 'Website Redesign', 1, 600000, '2024-02-01'),
(3, 'Mobile Application', 1, 900000, '2024-03-15'),
(4, 'Data Migration', 3, 750000, '2024-04-01'),
(5, 'Marketing Campaign', 4, 500000, '2024-05-20'),
(6, 'Payroll System', 2, 650000, '2024-06-10'),
(7, 'Customer Analytics', 4, 800000, '2024-07-05'),
(8, 'Cloud Infrastructure', 5, 1200000, '2024-08-12');

-- Employee-project assignments (30 assignments)
INSERT INTO works_on (emp_id, project_id, hours_worked) VALUES
(101, 1, 120),
(102, 1, 95),
(103, 1, 110),
(126, 1, 80),
(104, 2, 60),
(105, 2, 140),
(127, 2, 75),
(106, 3, 90),
(117, 3, 100),
(128, 3, 85),
(107, 4, 120),
(108, 4, 95),
(118, 4, 110),
(130, 4, 80),
(109, 5, 60),
(110, 5, 140),
(119, 5, 75),
(120, 5, 90),
(122, 5, 100),
(111, 6, 85),
(112, 6, 120),
(113, 6, 95),
(115, 6, 110),
(114, 7, 80),
(116, 7, 60),
(121, 7, 140),
(123, 7, 75),
(129, 7, 90),
(124, 8, 100),
(125, 8, 85);

-- =====================================================================
-- 5.3 QUERIES
-- =====================================================================

-- Q3.1 Selection (σ) — employees earning more than ₹60,000
SELECT *
FROM employee
WHERE salary > 60000;

-- Q3.2 Projection (π) — only name and salary columns
SELECT emp_name, salary
FROM employee;

-- Q3.3 Aggregate functions — company-wide salary statistics
SELECT SUM(salary) AS Total_Salary, 
       AVG(salary) AS Average_Salary, 
       MAX(salary) AS Maximum_Salary, 
       MIN(salary) AS Minimum_Salary
FROM employee;

-- Q3.4 GROUP BY — head-count per department
SELECT dept_id, COUNT(*) AS Employee_Count
FROM employee
GROUP BY dept_id;

-- Q3.5 GROUP BY with department names
SELECT d.dept_name, COUNT(e.emp_id) AS Employee_Count
FROM department d
JOIN employee e ON d.dept_id = e.dept_id 
GROUP BY d.dept_id, d.dept_name;

-- Q3.6 HAVING — departments with at least 5 employees
SELECT dept_id, COUNT(*) AS Employee_Count
FROM employee
GROUP BY dept_id 
HAVING COUNT(*) >= 5;

-- Q3.7 CASE expression — salary banding
SELECT emp_name, salary,
    CASE 
        WHEN salary >= 70000 THEN 'High Salary' 
        WHEN salary >= 55000 THEN 'Medium Salary' 
        ELSE 'Low Salary' 
    END AS Salary_Category
FROM employee;

-- Q3.8 ORDER BY — employees ranked by salary (highest first)
SELECT emp_name, salary
FROM employee
ORDER BY salary DESC;
