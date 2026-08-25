# 🗄️ SQL Server Enterprise Querying & Automation Portfolio

A comprehensive collection of 26 solved SQL tasks demonstrating core-to-advanced database operations using **Microsoft SQL Server (T-SQL)**. This repository showcases relational database design, aggregate analysis, analytical window functions, automation triggers, procedural logic (Stored Procedures/Cursors), and user-defined functions (UDFs).

---

## 📌 Table of Contents
- [Project Overview](#project-overview)
- [Database Schema & Architecture](#database-schema--architecture)
- [Key Features & Concepts Covered](#key-features--concepts-covered)
- [Tasks & Code Breakdown](#tasks--code-breakdown)
- [How to Run](#how-to-run)

---

## 🛠️ Key Features & Concepts Covered

* **Views & Aggregations:** Encapsulating multi-table joins and aggregated performance metrics (`vw_dept_salary_summary`, `vw_emp_dept`).
* **Analytical Window Functions:** Utilizing `RANK()`, `DENSE_RANK()`, `AVG() OVER()`, and `LAG()` for salary benchmarking and consecutive row analysis.
* **Complex Data Pipeline (CTEs):** Constructing single and multi-stage Common Table Expressions (`WITH` clauses) for dynamic subquery abstractions and classification.
* **Database Automation (Triggers):** 
  * `AFTER INSERT` logging to maintain history tables (`hire_log`).
  * `AFTER UPDATE` validation with data integrity enforcement (`ROLLBACK TRANSACTION` on salary cuts).
* **Stored Procedures & Procedural Logic:** 
  * Dynamic conditional parameters (`sp_give_raise`, `sp_budget_check`).
  * Explicit Cursors & Batch Processing (`sp_SalaryReview`) for custom row-by-row raise recalculations.
* **User-Defined Functions (UDFs):** Scalar functions for business logic calculations (`fn_annual_salary`, `fn_salary_grade`).
* **Performance Optimization:** Designing composite and single-column non-clustered indexes (`idx_emp_dept`, `idx_dept_salary`) for query performance tuning.

---

## 📐 Database Schema & Architecture

The tasks operate on two relational environments:
1. **Core HR Environment:** `Departments` and `Employees` tables managing staff data, managerial links, and budget limits.
2. **Project Management Extension:** Interconnected `Departments`, `Employees`, and `Projects` tables for enterprise resource planning analytics.

---

## 📝 Tasks & Code Breakdown

The notebook/script covers:
* **Tasks 1-4:** Database Views (`vw_all_employees`, `vw_dept10`, `vw_emp_dept`, salary summaries).
* **Tasks 5-7:** Stored Procedures for operational logic and budget validation checks.
* **Tasks 8-10:** Triggers for automated welcome alerts, audit logging, and integrity constraints.
* **Tasks 11 & 13:** Scalar UDFs for salary grading and annual projection.
* **Tasks 12 & 14-17:** Window functions for salary rankings and historical comparison (`LAG`).
* **Tasks 18-20:** Single and multi-CTE structures for complex metric derivation.
* **Tasks 21-22:** Index creation (`idx_emp_dept`, `idx_dept_salary`) and execution plan optimization strategies.
* **Tasks 23-26:** Comprehensive end-to-end tasks combining CTEs, CASE expressions, window partition functions, and Cursor-based stored procedures (`sp_SalaryReview`).

---

## 🚀 How to Run

1. Open **SQL Server Management Studio (SSMS)** or Azure Data Studio.
2. Connect to your local or target SQL Server instance.
3. Open the `sql_practice_tasks.sql` file.
4. Execute the script sequentially to create tables, populate sample data, and run all procedures/queries.
