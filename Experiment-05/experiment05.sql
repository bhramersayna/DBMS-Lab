-- =====================================================================
-- EXPERIMENT 05
-- Title: SQL Views and Recursive Common Table Expressions (CTE)
-- Aim: To create SQL views for a department salary summary and the employee
--      hierarchy, to test the updatability of views, and to implement a recursive
--      Common Table Expression (CTE) that displays the complete reporting
--      chain of every employee.
-- Student: Sayna Bhramer | UID: 25LBCS3252
-- DBMS: MySQL Server 8.0 (Community Edition)
-- =====================================================================

USE company_db;

-- =====================================================================
-- 5. SQL COMMANDS & VIEWS
-- =====================================================================

-- Q5.1 View 1 — department salary summary
CREATE VIEW dept_salary_summary AS 
SELECT d.dept_id, 
       d.dept_name, 
       COUNT(e.emp_id) AS Employee_Count, 
       SUM(e.salary) AS Total_Salary, 
       AVG(e.salary) AS Average_Salary 
FROM department d 
LEFT JOIN employee e ON d.dept_id = e.dept_id 
GROUP BY d.dept_id, d.dept_name; 

-- Query View 1
SELECT * FROM dept_salary_summary;

-- Q5.2 View 2 — employee hierarchy (employee -> manager)
CREATE VIEW employee_hierarchy AS 
SELECT e.emp_id, 
       e.emp_name AS Employee, 
       m.emp_name AS Manager, 
       d.dept_name AS Department 
FROM employee e 
LEFT JOIN employee m ON e.manager_id = m.emp_id 
INNER JOIN department d ON e.dept_id = d.dept_id; 

-- Query View 2
SELECT * FROM employee_hierarchy;

-- Q5.3 Updatable view — simple view on one table, WITH CHECK OPTION
CREATE VIEW it_employees AS 
SELECT emp_id, emp_name, salary, dept_id 
FROM employee 
WHERE dept_id = 1 
WITH CHECK OPTION; 

-- Update through the view (reaches the base table)
UPDATE it_employees SET salary = salary + 2000 WHERE emp_id = 105; 
SELECT * FROM it_employees; 
SELECT emp_id, emp_name, salary FROM employee WHERE emp_id = 105; 

-- Restore the original value 
UPDATE it_employees SET salary = salary - 2000 WHERE emp_id = 105;

-- Q5.4 Recursive CTE — full reporting chain from each department head
WITH RECURSIVE reporting_chain AS ( 
    -- anchor: top-level managers
    SELECT emp_id, emp_name, manager_id, 
           1 AS level, 
           CAST(emp_name AS CHAR(200)) AS chain 
    FROM employee 
    WHERE manager_id IS NULL 
    
    UNION ALL 
    
    -- recursive step: direct reports of the previous level 
    SELECT e.emp_id, e.emp_name, e.manager_id, 
           rc.level + 1, 
           CONCAT(rc.chain, ' -> ', e.emp_name) 
    FROM employee e 
    INNER JOIN reporting_chain rc ON e.manager_id = rc.emp_id 
) 
SELECT emp_id, emp_name, level, chain AS Reporting_Chain 
FROM reporting_chain 
ORDER BY chain;
