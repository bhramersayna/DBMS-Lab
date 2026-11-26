-- =====================================================================
-- EXPERIMENT 09
-- Title: Query Performance Benchmarking & Indexing on Railway Booking System
-- Aim: To benchmark query execution performance on a large railway booking
--      dataset (100,000 records) before and after creating B-Tree secondary
--      and composite indexes, evaluating query plans and latency metrics.
-- Student: Sayna Bhramer | UID: 25LBCS3252
-- DBMS: MySQL Server 8.0 / 9.x (InnoDB Engine)
-- =====================================================================

CREATE DATABASE IF NOT EXISTS railway_booking_db;
USE railway_booking_db;

-- =====================================================================
-- STEP 1: SCHEMA CREATION (UNINDEXED BASELINE)
-- =====================================================================

DROP TABLE IF EXISTS railway_booking;

CREATE TABLE railway_booking (
    Booking_ID INT AUTO_INCREMENT PRIMARY KEY,
    PNR_Number VARCHAR(15) NOT NULL,
    Train_Number INT NOT NULL,
    Train_Name VARCHAR(100) NOT NULL,
    Passenger_Name VARCHAR(60) NOT NULL,
    Passenger_Age INT NOT NULL,
    Seat_Class VARCHAR(10) NOT NULL,
    Coach_Number VARCHAR(10) NOT NULL,
    Seat_Number INT NOT NULL,
    Journey_Date DATE NOT NULL,
    Source_Station VARCHAR(50) NOT NULL,
    Destination_Station VARCHAR(50) NOT NULL,
    Fare DECIMAL(10,2) NOT NULL,
    Booking_Status ENUM('CONFIRMED', 'WAITLIST', 'RAC', 'CANCELLED') NOT NULL,
    Booking_Timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- =====================================================================
-- STEP 2: BENCHMARK QUERIES (BEFORE INDEXING)
-- Performs full table scans (type = ALL) across 100,000 rows
-- =====================================================================

-- Query 1: Point lookup on PNR
EXPLAIN SELECT * FROM railway_booking WHERE PNR_Number = 'PNR8472910';

-- Query 2: Range search on Train and Date
EXPLAIN SELECT * FROM railway_booking 
WHERE Train_Number = 12951 
  AND Journey_Date BETWEEN '2024-04-01' AND '2024-04-30';

-- Query 3: Status and Class Filter
EXPLAIN SELECT COUNT(*) FROM railway_booking 
WHERE Booking_Status = 'CONFIRMED' AND Seat_Class = '3A';

-- Query 4: Passenger Name Lookup
EXPLAIN SELECT * FROM railway_booking WHERE Passenger_Name = 'Aarav Sharma';

-- =====================================================================
-- STEP 3: CREATING OPTIMIZED B-TREE INDEXES
-- =====================================================================

-- Index 1: Unique index for high-cardinality PNR lookups
CREATE UNIQUE INDEX idx_pnr ON railway_booking(PNR_Number);

-- Index 2: Composite index for Train schedule filtering
CREATE INDEX idx_train_date ON railway_booking(Train_Number, Journey_Date);

-- Index 3: Composite index for status counting
CREATE INDEX idx_passenger_status ON railway_booking(Booking_Status, Seat_Class);

-- Index 4: Secondary index for passenger lookup
CREATE INDEX idx_passenger_name ON railway_booking(Passenger_Name);

-- =====================================================================
-- STEP 4: BENCHMARK QUERIES (AFTER INDEXING)
-- Evaluates index access (type = const / range / ref)
-- =====================================================================

-- Query 1: Uses idx_pnr (type = const)
EXPLAIN SELECT * FROM railway_booking WHERE PNR_Number = 'PNR8472910';

-- Query 2: Uses idx_train_date (type = range)
EXPLAIN SELECT * FROM railway_booking 
WHERE Train_Number = 12951 
  AND Journey_Date BETWEEN '2024-04-01' AND '2024-04-30';

-- Query 3: Uses idx_passenger_status (type = ref)
EXPLAIN SELECT COUNT(*) FROM railway_booking 
WHERE Booking_Status = 'CONFIRMED' AND Seat_Class = '3A';

-- Query 4: Uses idx_passenger_name (type = ref)
EXPLAIN SELECT * FROM railway_booking WHERE Passenger_Name = 'Aarav Sharma';
