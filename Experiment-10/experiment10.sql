-- =====================================================================
-- EXPERIMENT 10
-- Title: Slow Query Analysis & Performance Optimization Using EXPLAIN,
--        Targeted Indexing, and Architectural Query Rewriting
-- Aim: To detect, profile, analyze, and optimize five distinct slow queries
--      using MySQL EXPLAIN, composite/covering/full-text indexing, and
--      query rewriting strategies.
-- Student: Sayna Bhramer | UID: 25LBCS3252
-- DBMS: MySQL Server 8.0 / 9.x (InnoDB Engine)
-- =====================================================================

CREATE DATABASE IF NOT EXISTS query_tuning_db;
USE query_tuning_db;

-- =====================================================================
-- SLOW QUERY 1: NON-SARGABLE FUNCTION IN WHERE CLAUSE
-- =====================================================================

-- Slow Query 1 (Function prevents index usage):
-- EXPLAIN SELECT * FROM railway_booking WHERE YEAR(Journey_Date) = 2024;

-- Optimization: Add index and rewrite predicate into SARGable range
CREATE INDEX idx_journey_date ON railway_booking(Journey_Date);

-- Optimized Query 1:
EXPLAIN SELECT * FROM railway_booking 
WHERE Journey_Date >= '2024-01-01' AND Journey_Date < '2025-01-01';

-- =====================================================================
-- SLOW QUERY 2: UNINDEXED LEADING WILDCARD (LIKE '%value%')
-- =====================================================================

-- Slow Query 2 (Leading wildcard forces full table scan):
-- EXPLAIN SELECT * FROM railway_booking WHERE Passenger_Name LIKE '%Sharma%';

-- Optimization: Deploy MySQL FULLTEXT index
ALTER TABLE railway_booking ADD FULLTEXT INDEX idx_ft_pname(Passenger_Name);

-- Optimized Query 2:
EXPLAIN SELECT * FROM railway_booking 
WHERE MATCH(Passenger_Name) AGAINST('Sharma' IN BOOLEAN MODE);

-- =====================================================================
-- SLOW QUERY 3: CORRELATED SUBQUERY IN PROJECTION LIST
-- =====================================================================

-- Slow Query 3 (Correlated subquery runs 100,000 times):
-- EXPLAIN SELECT r1.Booking_ID, r1.Train_Number, r1.Fare,
--        (SELECT AVG(r2.Fare) FROM railway_booking r2 WHERE r2.Train_Number = r1.Train_Number) AS AvgTrainFare
-- FROM railway_booking r1;

-- Optimization: Rewrite using pre-aggregated derived table / CTE + JOIN
EXPLAIN SELECT r1.Booking_ID, r1.Train_Number, r1.Fare, tf.AvgTrainFare
FROM railway_booking r1
JOIN (
    SELECT Train_Number, AVG(Fare) AS AvgTrainFare
    FROM railway_booking
    GROUP BY Train_Number
) tf ON r1.Train_Number = tf.Train_Number;

-- =====================================================================
-- SLOW QUERY 4: SELECT * REQUIRING CLUSTERED TABLE LOOKUPS
-- =====================================================================

-- Slow Query 4 (Secondary index lookup requires clustered page reads):
-- EXPLAIN SELECT * FROM railway_booking WHERE Train_Number = 12951;

-- Optimization: Create Covering Composite Index covering projected columns
CREATE INDEX idx_covering_train_fare ON railway_booking(Train_Number, Booking_ID, PNR_Number, Fare);

-- Optimized Query 4 (Covering Index: 'Using index' in Extra):
EXPLAIN SELECT Train_Number, Booking_ID, PNR_Number, Fare 
FROM railway_booking 
WHERE Train_Number = 12951;

-- =====================================================================
-- SLOW QUERY 5: EXPENSIVE UNION DEDUPLICATION & HIGH-OFFSET PAGINATION
-- =====================================================================

-- Slow Query 5 (Costly temp table sort & offset discard):
-- EXPLAIN SELECT Booking_ID, PNR_Number, Fare FROM railway_booking WHERE Seat_Class = '1A'
-- UNION
-- SELECT Booking_ID, PNR_Number, Fare FROM railway_booking WHERE Seat_Class = '2A'
-- LIMIT 10 OFFSET 50000;

-- Optimization: Replace UNION with UNION ALL (or IN clause) + Keyset Seek
EXPLAIN SELECT Booking_ID, PNR_Number, Fare 
FROM railway_booking 
WHERE Seat_Class IN ('1A', '2A') AND Booking_ID > 50000 
ORDER BY Booking_ID 
LIMIT 10;
