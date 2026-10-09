-- =====================================================================
-- EXPERIMENT 06
-- Title: Stored Procedures with Error Handling, Transactions & Triggers
-- Aim: To create a stored procedure transfer_employee(emp_id, new_dept_id)
--      with input validation and error handling, to implement triggers for
--      salary validation and audit logging, and to test normal and edge cases.
-- Student: Sayna Bhramer | UID: 25LBCS3252
-- DBMS: MySQL Server 8.0 (Community Edition)
-- =====================================================================

USE company_db;

-- =====================================================================
-- 5.1 AUDIT TABLE
-- =====================================================================

CREATE TABLE IF NOT EXISTS employee_audit ( 
    audit_id INT AUTO_INCREMENT PRIMARY KEY, 
    emp_id INT NOT NULL, 
    old_dept_id INT, 
    new_dept_id INT, 
    action_time DATETIME DEFAULT CURRENT_TIMESTAMP, 
    action VARCHAR(50) 
);

-- =====================================================================
-- 5.2 STORED PROCEDURE: transfer_employee
-- =====================================================================

DELIMITER  

CREATE PROCEDURE transfer_employee(IN p_emp_id INT, IN p_new_dept_id INT) 
BEGIN 
    DECLARE v_old_dept INT; 

    -- Any SQL error: undo the work and pass the error to the caller 
    DECLARE EXIT HANDLER FOR SQLEXCEPTION 
    BEGIN 
        ROLLBACK; 
        RESIGNAL; 
    END; 

    -- Validation 1: employee must exist 
    IF NOT EXISTS (SELECT 1 FROM employee WHERE emp_id = p_emp_id) THEN 
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Employee does not exist'; 
    END IF; 

    -- Validation 2: target department must exist 
    IF NOT EXISTS (SELECT 1 FROM department WHERE dept_id = p_new_dept_id) THEN 
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Department does not exist'; 
    END IF; 

    -- Validation 3: must be a real change 
    SELECT dept_id INTO v_old_dept FROM employee WHERE emp_id = p_emp_id; 
    IF v_old_dept = p_new_dept_id THEN 
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Employee already belongs to this department'; 
    END IF; 

    START TRANSACTION; 
    UPDATE employee SET dept_id = p_new_dept_id WHERE emp_id = p_emp_id; 
    COMMIT; 
END 

-- =====================================================================
-- 5.3 TRIGGERS
-- =====================================================================

-- Trigger 1: salary validation on INSERT
CREATE TRIGGER trg_salary_check_insert 
BEFORE INSERT ON employee 
FOR EACH ROW 
BEGIN 
    IF NEW.salary < 15000 THEN 
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Salary cannot be less than 15000'; 
    END IF; 
END 

-- Trigger 2: salary validation on UPDATE
CREATE TRIGGER trg_salary_check_update 
BEFORE UPDATE ON employee 
FOR EACH ROW 
BEGIN 
    IF NEW.salary < 15000 THEN 
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Salary cannot be less than 15000'; 
    END IF; 
END 

-- Trigger 3: audit log whenever an employee changes department 
CREATE TRIGGER trg_audit_dept_change 
AFTER UPDATE ON employee 
FOR EACH ROW 
BEGIN 
    IF NOT (OLD.dept_id <=> NEW.dept_id) THEN 
        INSERT INTO employee_audit (emp_id, old_dept_id, new_dept_id, action) 
        VALUES (OLD.emp_id, OLD.dept_id, NEW.dept_id, 'Employee Transferred'); 
    END IF; 
END 

DELIMITER ;

-- =====================================================================
-- 6. TEST CASES & EXECUTION
-- =====================================================================

-- Q6.1 Valid transfer — move Priya (102) from IT (1) to Finance (3)
CALL transfer_employee(102, 3); 
SELECT * FROM employee WHERE emp_id = 102; 

-- Q6.2 Audit trigger fired automatically 
SELECT * FROM employee_audit; 

-- Q6.3 Salary trigger — update below the minimum is blocked 
UPDATE employee SET salary = 12000 WHERE emp_id = 105; 

-- Q6.4 Edge case — employee does not exist 
-- Expected: ERROR 1644 (45000): Employee does not exist
CALL transfer_employee(999, 2); 

-- Q6.5 Edge case — department does not exist 
-- Expected: ERROR 1644 (45000): Department does not exist
CALL transfer_employee(101, 9); 

-- Q6.6 Edge case — transfer to the same department 
-- Expected: ERROR 1644 (45000): Employee already belongs to this department
CALL transfer_employee(103, 1); 

-- Q6.7 Edge case — INSERT with invalid salary 
-- Expected: ERROR 1644 (45000): Salary cannot be less than 15000
INSERT INTO employee VALUES 
(131, 'Test', 'Male', 10000.00, '2026-09-27', 1, 101);
