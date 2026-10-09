-- =====================================================================
-- EXPERIMENT 04
-- Title: Complex SQL Queries: Joins, Subqueries, Set Operations & Execution Plans
-- Aim: Using the Employee schema from Experiment 3, to write queries using
--      INNER JOIN, LEFT JOIN, self-join, a 3-way join, correlated subqueries,
--      EXISTS, and simulated INTERSECT and EXCEPT, and to compare query
--      execution plans using EXPLAIN.
-- Student: Sayna Bhramer | UID: 25LBCS3252
-- DBMS: MySQL Server 8.0 (Community Edition)
-- =====================================================================

USE company_db;

-- =====================================================================
-- 5. QUERIES
-- =====================================================================

-- Q4.1 INNER JOIN — employee with department name
SELECT e.emp_name, d.dept_name
FROM employee e
INNER JOIN department d
ON e.dept_id = d.dept_id;

-- Q4.2 LEFT JOIN — every department with its employees
SELECT d.dept_name, e.emp_name
FROM department d
LEFT JOIN employee e
ON d.dept_id = e.dept_id;

-- Q4.3 SELF JOIN — employee and reporting manager
SELECT e.emp_name AS Employee, 
       m.emp_name AS Manager
FROM employee e
LEFT JOIN employee m
ON e.manager_id = m.emp_id;

-- Q4.4 3-way JOIN — Employee × Department × Project
SELECT e.emp_name, d.dept_name, p.project_name
FROM works_on w
INNER JOIN employee e ON w.emp_id = e.emp_id
INNER JOIN department d ON e.dept_id = d.dept_id
INNER JOIN project p ON w.project_id = p.project_id
ORDER BY p.project_id, e.emp_id;

-- Q4.5 Correlated subquery — employees earning above their department average
SELECT e.emp_name, e.dept_id, e.salary
FROM employee e
WHERE e.salary > (
    SELECT AVG(i.salary)
    FROM employee i
    WHERE i.dept_id = e.dept_id
);

-- Q4.6 EXISTS — departments having at least one employee earning above ₹70,000
SELECT d.dept_name
FROM department d
WHERE EXISTS (
    SELECT 1
    FROM employee e
    WHERE e.dept_id = d.dept_id
      AND e.salary > 70000
);

-- Q4.7 Simulated INTERSECT — IT employees who also work on ERP Development
SELECT e.emp_id, e.emp_name
FROM employee e
WHERE e.dept_id = 1
  AND e.emp_id IN (
      SELECT w.emp_id
      FROM works_on w
      JOIN project p ON w.project_id = p.project_id
      WHERE p.project_name = 'ERP Development'
  );

-- Q4.8 Simulated EXCEPT — high earners (> ₹60,000) who are NOT in IT
SELECT emp_id, emp_name
FROM employee
WHERE salary > 60000
  AND emp_id NOT IN (
      SELECT emp_id
      FROM employee
      WHERE dept_id = 1
  );

-- Q4.9 EXPLAIN — plan of the correlated subquery (Q4.5)
EXPLAIN
SELECT e.emp_name, e.dept_id, e.salary
FROM employee e
WHERE e.salary > (
    SELECT AVG(i.salary)
    FROM employee i
    WHERE i.dept_id = e.dept_id
);

-- Q4.10 EXPLAIN — same result rewritten as a JOIN with a derived table
EXPLAIN
SELECT e.emp_name, e.dept_id, e.salary
FROM employee e
JOIN (
    SELECT dept_id, AVG(salary) AS avg_sal
    FROM employee
    GROUP BY dept_id
) a ON e.dept_id = a.dept_id
WHERE e.salary > a.avg_sal;
