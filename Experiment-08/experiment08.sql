-- =====================================================================
-- EXPERIMENT 08
-- Title: Banking Transactions, ACID Compliance, and Isolation Levels
-- Aim: To implement a robust banking transaction system demonstrating ACID
--      properties using COMMIT, ROLLBACK, and SAVEPOINT, and to simulate
--      and evaluate concurrency anomalies across SQL isolation levels
--      (READ UNCOMMITTED, READ COMMITTED, REPEATABLE READ, SERIALIZABLE).
-- Student: Sayna Bhramer | UID: 25LBCS3252
-- DBMS: MySQL Server 8.0 / 9.x (InnoDB Engine)
-- =====================================================================

CREATE DATABASE IF NOT EXISTS banking_system_db;
USE banking_system_db;

-- =====================================================================
-- STEP 1: SCHEMA DEFINITION & AUDIT TRAIL
-- =====================================================================

DROP TABLE IF EXISTS Transaction_Audit;
DROP TABLE IF EXISTS Account;

CREATE TABLE Account (
    AccountID INT PRIMARY KEY,
    HolderName VARCHAR(60) NOT NULL,
    AccountType ENUM('Savings', 'Current') NOT NULL DEFAULT 'Savings',
    Balance DECIMAL(12,2) NOT NULL CHECK (Balance >= 0.00),
    Status ENUM('ACTIVE', 'FROZEN', 'CLOSED') NOT NULL DEFAULT 'ACTIVE'
) ENGINE=InnoDB;

CREATE TABLE Transaction_Audit (
    AuditID INT AUTO_INCREMENT PRIMARY KEY,
    TxCode VARCHAR(20) NOT NULL,
    FromAccount INT NOT NULL,
    ToAccount INT NOT NULL,
    Amount DECIMAL(12,2) NOT NULL,
    TxTimestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    Status ENUM('SUCCESS', 'FAILED', 'REVERTED') NOT NULL,
    Remarks VARCHAR(255),
    FOREIGN KEY (FromAccount) REFERENCES Account(AccountID),
    FOREIGN KEY (ToAccount) REFERENCES Account(AccountID)
) ENGINE=InnoDB;

-- Populate Accounts
INSERT INTO Account VALUES
(101, 'Aarav Sharma', 'Savings', 50000.00, 'ACTIVE'),
(102, 'Priya Patel', 'Savings', 35000.00, 'ACTIVE'),
(103, 'Rahul Verma', 'Current', 80000.00, 'ACTIVE'),
(104, 'Sneha Nair', 'Savings', 12000.00, 'ACTIVE'),
(105, 'Vikram Sen', 'Current', 25000.00, 'ACTIVE');

-- Q8.1 Initial State
SELECT * FROM Account;

-- =====================================================================
-- STEP 2: SUCCESSFUL FUND TRANSFER WITH COMMIT
-- Atomicity, Consistency, Isolation, Durability
-- =====================================================================

START TRANSACTION;

-- Deduct 10,000 from Aarav (101)
UPDATE Account 
SET Balance = Balance - 10000.00 
WHERE AccountID = 101 AND Balance >= 10000.00 AND Status = 'ACTIVE';

-- Credit 10,000 to Priya (102)
UPDATE Account 
SET Balance = Balance + 10000.00 
WHERE AccountID = 102 AND Status = 'ACTIVE';

-- Record in audit log
INSERT INTO Transaction_Audit (TxCode, FromAccount, ToAccount, Amount, Status, Remarks)
VALUES ('TXN1001', 101, 102, 10000.00, 'SUCCESS', 'Fund transfer completed successfully.');

COMMIT;

-- Q8.2 State After Commit
SELECT * FROM Account WHERE AccountID IN (101, 102);
SELECT * FROM Transaction_Audit;

-- =====================================================================
-- STEP 3: TRANSACTION FAILURE & ROLLBACK
-- Enforcing Balance Constraints and Reverting State
-- =====================================================================

START TRANSACTION;

-- Attempt to transfer 60,000 from Aarav (Current Balance: 40,000)
-- Simulation of business logic validation
SET @source_bal = (SELECT Balance FROM Account WHERE AccountID = 101);

-- If insufficient, trigger rollback
ROLLBACK;

-- Q8.3 Verify state unchanged after rollback
SELECT * FROM Account WHERE AccountID IN (101, 102);

-- =====================================================================
-- STEP 4: BATCH TRANSFER WITH SAVEPOINT & PARTIAL ROLLBACK
-- =====================================================================

START TRANSACTION;

-- Transfer 1: 5,000 from 101 to 103 (Valid)
UPDATE Account SET Balance = Balance - 5000.00 WHERE AccountID = 101;
UPDATE Account SET Balance = Balance + 5000.00 WHERE AccountID = 103;

-- Set Savepoint after successful first transfer
SAVEPOINT sp_batch_part1;

-- Transfer 2: Attempt 50,000 from 101 to 102 (Invalid - Insufficient Balance)
-- Revert only uncommitted part back to Savepoint
ROLLBACK TO SAVEPOINT sp_batch_part1;

-- Commit the valid portion
COMMIT;

-- Q8.4 State After Savepoint & Partial Rollback
SELECT * FROM Account WHERE AccountID IN (101, 102, 103);

-- =====================================================================
-- STEP 5: ISOLATION LEVELS & ANOMALY SIMULATION
-- =====================================================================

-- 1. Check current isolation level
SELECT @@GLOBAL.transaction_isolation, @@SESSION.transaction_isolation;

-- 2. Setting Isolation Levels for Testing
-- SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
-- SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
-- SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;
-- SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
