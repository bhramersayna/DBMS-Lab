# Database Management Systems (DBMS) Lab

Repository containing structured experiments for the **Database Management Systems Lab (MySQL 8.0 / 9.x)**, conducted by **Sayna Bhramer** (UID: 25LBCS3252), Chandigarh University.

Every experiment is organized in a self-contained directory containing its documentation, complete SQL source code, and verified execution output screenshots.

---

## 📑 List of Experiments

| Experiment No. | Title | Aim Summary | Folder Link |
| :---: | :--- | :--- | :---: |
| **03** | **Employee–Department–Project Schema** | Design schema (30 employees, 5 departments, 8 projects) and query using Selection, Projection, Aggregates, GROUP BY, HAVING, CASE, and ORDER BY. | [📂 Experiment-03](./Experiment-03/) |
| **04** | **Complex SQL Queries & Optimization** | Implement INNER JOIN, LEFT JOIN, SELF JOIN, 3-way join, correlated subqueries, EXISTS, simulated INTERSECT/EXCEPT, and analyze query execution plans with EXPLAIN. | [📂 Experiment-04](./Experiment-04/) |
| **05** | **SQL Views & Recursive CTEs** | Create summary & hierarchical views, test updatability and WITH CHECK OPTION, and build recursive Common Table Expressions (WITH RECURSIVE) for organizational hierarchies. | [📂 Experiment-05](./Experiment-05/) |
| **06** | **Stored Procedures, Error Handling & Triggers** | Implement stored procedure 	ransfer_employee with transactional error handling (SIGNAL/RESIGNAL), domain validation triggers, and automated audit logging. | [📂 Experiment-06](./Experiment-06/) |
| **07** | **Database Normalization (UNF to 3NF & BCNF)** | Normalize a denormalized Sales/Order relation through UNF, 1NF, 2NF, 3NF, and BCNF. Eliminate insertion, update, and deletion anomalies while proving lossless join and dependency preservation. | [📂 Experiment-07](./Experiment-07/) |
| **08** | **Banking Transactions & Isolation Levels** | Implement robust banking transactions demonstrating ACID properties using COMMIT, ROLLBACK, and SAVEPOINT, and evaluate concurrency anomalies across SQL isolation levels. | [📂 Experiment-08](./Experiment-08/) |
| **09** | **Railway Booking Performance & Indexing** | Benchmark SQL query execution on a 100,000-record railway reservation dataset before and after creating B-Tree secondary and composite indexes. | [📂 Experiment-09](./Experiment-09/) |
| **10** | **Slow Query Analysis & Optimization** | Profile, analyze, and optimize five distinct slow SQL queries using MySQL EXPLAIN, covering/full-text indexing, SARGable predicates, and query rewriting. | [📂 Experiment-10](./Experiment-10/) |

---

## 📂 Repository Structure

`
DBMS-Lab/
├── README.md                                # Root repository guide and experiments index
├── Sayna_Bhramer_25LBCS3252_DBMS.pdf        # Original lab manual PDF
├── Experiment-03/
│   ├── README.md                            # Experiment 03 procedure, theory, queries & results
│   ├── experiment03.sql                     # Full DDL, DML and query scripts
│   └── output/                              # 8 original execution screenshots (Q3.1 - Q3.8)
├── Experiment-04/
│   ├── README.md                            # Experiment 04 procedure, joins, subqueries & EXPLAIN
│   ├── experiment04.sql                     # SQL query scripts
│   └── output/                              # 10 original execution screenshots (Q4.1 - Q4.10)
├── Experiment-05/
│   ├── README.md                            # Experiment 05 procedure, views, CTE analysis
│   ├── experiment05.sql                     # Views & recursive CTE scripts
│   └── output/                              # 4 original execution screenshots (Q5.1 - Q5.4)
├── Experiment-06/
│   ├── README.md                            # Experiment 06 procedure, procedures, triggers
│   ├── experiment06.sql                     # Stored procedure, triggers & test harness
│   └── output/                              # 7 original execution screenshots (Q6.1 - Q6.7)
├── Experiment-07/
│   ├── README.md                            # Normalization theory, FDs, anomalies, BCNF analysis
│   ├── experiment07.sql                     # Complete DDL & DML for UNF, 1NF, 2NF, 3NF, BCNF & join
│   └── output/                              # 6 terminal execution screenshots (Q7.1 - Q7.6)
├── Experiment-08/
│   ├── README.md                            # Banking transactions, ACID, savepoints & isolation levels
│   ├── experiment08.sql                     # TCL operations, error handlers & isolation simulation
│   └── output/                              # 5 terminal execution screenshots (Q8.1 - Q8.5)
├── Experiment-09/
│   ├── README.md                            # Railway booking benchmarking, B-Tree & composite indexes
│   ├── experiment09.sql                     # 100K-row dataset schema, indexes & benchmark queries
│   └── output/                              # 5 terminal execution screenshots (Q9.1 - Q9.5)
└── Experiment-10/
    ├── README.md                            # Analysis of 5 slow queries, EXPLAIN profiling & speedups
    ├── experiment10.sql                     # SARGable queries, FULLTEXT, covering indexes & rewrites
    └── output/                              # 6 terminal execution screenshots (Q10.1 - Q10.6)
`

---

## 🛠️ Environment & Tools
- **DBMS**: MySQL Server 8.0 / 9.x (Community Edition)
- **Tooling**: MySQL Workbench 8.0 / MySQL Shell
- **OS**: Windows 11
- **Language**: SQL (DDL, DML, DQL, TCL)
