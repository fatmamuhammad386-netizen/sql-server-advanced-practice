CREATE TABLE Departments ( 
dept_id INT PRIMARY KEY, 
dept_name VARCHAR(50), 
budget_limit INT 
);  
CREATE TABLE Employees ( 
emp_id INT PRIMARY KEY, 
name VARCHAR(50), 
salary INT, 
dept_id INT, 
manager_id INT, 
hire_date DATE, 
job_title VARCHAR(50) 
); 
INSERT INTO Departments VALUES 
(10, 'Data Engineering', 25000), 
(20, 'Software Development', 30000), 
(30, 'Quality Assurance', 15000); 
INSERT INTO Employees VALUES 
(1, 'Yusuf', 9500, 10, NULL, '2023-01-15', 'Lead Engineer'), 
(2, 'Mennah', 8200, 10, 1, '2023-06-20', 'Data Analyst'), 
(3, 'Ahmed', 7500, 20, 1, '2024-03-10', 'Backend Developer'), 
(4, 'Sara', 13000, 20, NULL, '2022-11-05', 'Manager'), 
(5, 'Khalid', 6000, 10, 2, '2024-01-12', 'Junior Developer');  
 
--Q1. Create a VIEW named vw_all_employees that shows every employee's 
create view vw_all_employees as 
select name , salary , job_title from Employees
select * from vw_all_employees

---Q2. Create a VIEW named vw_dept10 that shows the name and salary 
create view vw_dept10 as
select name , salary from Employees
where dept_id=10
select * from vw_dept10

--Q3. Create a VIEW named vw_emp_dept that shows each employee's 
create view vw_emp_dept as
select name , job_title ,dept_name
from Employees e join Departments d
on e.dept_id=d.dept_id and dept_name='data Engineering'

--Q4. Create a VIEW named vw_dept_salary_summary that shows: 
create view vw_dept_salary_summary as
select d.dept_name , count(emp_id) as Total_Employees , sum(salary) as Total_Salary
, avg(salary) as Avg_Salary
from Departments d left join Employees e
on e.dept_id=d.dept_id
group by d.dept_name

select * from vw_dept_salary_summary
where avg_Salary > 7500;
drop view vw_dept_salary_summary
--Q5. Create a stored procedure named sp_all_employees that takes no parameters
create procedure sp_all_employees as 
begin 
select * from employees
end
exec sp_all_employees
--Q6. Create a stored procedure named sp_give_raise that accepts emp_id (INT) 
create procedure sp_give_raise
@empid int , @raise_pct int
as 
begin
update Employees set salary= salary+((@raise_pct/100.00)*salary)
where emp_id=@empid
end
exec sp_give_raise 2,50
select * from Employees
--Q7. Create a stored procedure named sp_budget_check that accepts a dept_id.
create procedure sp_budget_check 
@deptid int
as
begin 
	if (select sum(salary) from employees where dept_id=@deptid)> (select budget_limit from departments where dept_id=@deptid)
	begin
	print'over budget'
	end
	else
	begin
	print'Within Budget'
	end
end
exec sp_budget_check 3
--Q8. Create a trigger named trg_welcome that fires AFTER INSERT on the Employees table and prints the message: 'New employee added: <name>' using the NEW keyword to access the inserted name. 
create trigger trg_welcome on employees after insert as
begin 
declare @new_name varchar(20)
select @new_name=name from inserted
print 'New employee added:' + @new_name
end
INSERT INTO Employees VALUES (6, 'Yasmine', 7000, 10, 1, '2026-06-30', 'Data Engineer');
/*Q9 Create a table named hire_log with columns: 
emp_id (INT), emp_name (VARCHAR 50), logged_at (DATETIME). 
Then create a trigger named trg_log_hire that fires AFTER INSERT 
on the Employees table and inserts a record into hire_log 
capturing the new employee's id, name, and the current timestamp. */
create table hire_log (
emp_id int ,
emp_name varchar(50),
logged_at datetime
)
create trigger trg_log_hire on employees after insert as 
begin 
insert into hire_log (emp_id,emp_name,logged_at)
select emp_id , name , GETDATE() from inserted
end
INSERT INTO Employees VALUES (7, 'zeina', 7000, 20, 1, '2026-07-1', 'Backend Developer');
select * from hire_log

/*Q10 Create a trigger named trg_no_salary_cut that fires BEFORE UPDATE 
on the Employees table. 
If the new salary value is less than the old salary value, 
raise an error using:  SIGNAL SQLSTATE '45000' 
with the message 'Salary reduction is not allowed'. 
Write a test UPDATE that would trigger this error. */
create trigger trg_no_salary_cut on employees after update as 
begin 
if exists (
select 1 from inserted i
join deleted d on i.emp_id = d.emp_id
where i.salary < d.salary)
begin
raiserror('Salary reduction is not allowed',16,1);
rollback transaction
end 
end
/*Q11. Create a UDF named fn_annual_salary that takes monthly_salary 
(INT) 
and returns the annual salary (monthly × 12). 
Write a SELECT query using this function to display each employee's 
name and Annual_Salary.*/
create function fn_annual_salary (@monthly_salary int)
returns int as 
begin
return @monthly_salary * 12;
end

select name, 
       dbo.fn_annual_salary(salary) AS Annual_Salary
from employees;
--Q12. For each department, find the name and salary of the employee who has the lowest salary in that department.
select name, salary 
from Employees e
where salary in (select min(salary) 
from Employees 
where dept_id = e.dept_id)
/*Q13. Create a UDF named fn_salary_grade that accepts a salary (INT) and 
returns: 
•  salary >= 10000  →  'Grade A' 
•  salary 7000 to 9999  →  'Grade B' 
•  salary < 7000    →  'Grade C' 
Write a SELECT that displays name, salary, and Grade for all employees 
ordered by salary DESC. 
Then write a second SELECT that uses fn_salary_grade inside a WHERE 
clause 
to return only 'Grade B' employees. */
create function fn_salary_grade (@salary int )
returns varchar(20) as
begin 
if @salary >= 10000  return 'Grade A' 
else if @salary >= 7000 and @salary<=9999 return 'Grade B'
return 'Grade C'
end

select name , salary , dbo.fn_salary_grade(salary) as grade
from employees order by salary desc

select name , salary , dbo.fn_salary_grade(salary) as grade
from employees where dbo.fn_salary_grade(salary) = 'Grade B'

/*Q14. Write a query using RANK() to rank all employees by salary
from highest to lowest. 
Display: name, salary, and Salary_Rank. 
(Employees with the same salary share the same rank.) */  --dense rank
select name , salary , RANK()over(order by salary desc)as Salary_Rank
from Employees
--Q15. Department Average Salary
select name, dept_id, salary, AVG(salary) OVER(PARTITION BY dept_id) AS Dept_Avg_Salary
from Employees
/*Q16. Using the LAG() window function ordered by hire_date ASC,
write a query that shows for each employee: 
name, hire_date, salary, and the salary of the previously hired 
employee as Prev_Hire_Salary. 
Rows with no previous hire should show NULL.*/
select name , hire_date ,salary ,lag(salary) over(order by hire_date)as previously_hired 
from Employees
/*Q17. Write a query using DENSE_RANK() partitioned by dept_id 
and ordered by salary DESC. 
Show: name, dept_id, salary, and Rank_In_Dept. 
Then wrap this query inside a subquery to return ONLY 
the employee with rank = 1 in each department. */
select name , dept_id , salary , Rank_In_Dept
from (select name , dept_id , salary , DENSE_RANK()over(partition by dept_id order by salary ) as Rank_In_Dept  from Employees )as subquery 
where Rank_In_Dept =1

/*Q18. Write a query using a CTE named HighEarners that selects all 
employees 
earning above 8,000. 
Then SELECT name and salary from the CTE. */
with HighEarners as (
select name , salary from Employees where salary > 8000
)
select name , salary from HighEarners

/*Q19. Write a query using a CTE named DeptTotal that calculates 
the total salary (SUM) per dept_id. 
Then join DeptTotal with the Departments table and show 
dept_name and Total_Salaries only for departments 
where total salary exceeds the budget_limit. */
with DeptTotal as (select sum(salary) as total_salaries from Employees group by dept_id)
select d.dept_name,dt.total_salaries
from DeptTotal dt join departments d on dt.dept_id = d.dept_id
where dt.total_salaries > d.budget_limit;



/*Q20. Write a query using TWO CTEs: 
  •  AvgPerDept  — calculates AVG salary per dept_id 
  •  AboveAvg    — joins AvgPerDept with Employees and keeps only 
                   employees who earn above their own department average 
Final SELECT should show name, dept_id, salary, and Dept_Avg. 
Explain in one SQL comment (--) why two CTEs improve readability 
over a nested subquery. */
with AvgPerDept as (select dept_id, avg(salary) AS Dept_Avg from Employees group by dept_id ),
AboveAvg as (select e.name, e.dept_id, e.salary, a.Dept_Avg from Employees e
join AvgPerDept a ON e.dept_id = a.dept_id where e.salary > a.Dept_Avg)
select name, dept_id, salary, Dept_Avg 
from AboveAvg
/*Q21. Write the SQL statement to create an index named idx_emp_dept 
on the dept_id column of the Employees table. 
Then write the DROP INDEX statement to remove it. 
Add a SQL comment (--) explaining which query in this task 
benefits most from this index. */
create index idx_emp_dept 
on employees (dept_id)
drop index idx_emp_dept on employees
--q15, q17, q19, and q20 benefit most from this index because they use 'dept_id' for group by , partition by 






/*Q22. Write the SQL statement to create a composite index named 
idx_dept_salary 
on the columns (dept_id, salary) of the Employees table. 
Then write the DROP statement to remove it. 
Add a comment explaining when a composite index is more eAicient 
than creating two separate single-column indexes. */
create index idx_dept_salary 
on employees (dept_id, salary)
drop index idx_dept_salary on employees
--composite index is faster because it saves the data already sorted by both columns
--it helps the database find and order the rows in one step, without combining two separate indexes








/*Q23. Write a single SELECT query (no CTEs, no subqueries in FROM) that 
shows 
ALL of the following for each employee in one result set: 
   • name   • dept_id   • salary 
   • Salary_Rank        — rank across ALL employees, highest salary = 1   
   • Rank_In_Dept       — rank within the employee's own department        
   • Dept_Avg_Salary    — average salary in the employee's department      
   • Prev_Hire_Salary   — salary of the previously hired employee globally  
All four window calculations must appear in the same query. 
Order the final result by dept_id ASC, then salary DESC. */
select name , salary , dept_id , rank() over(order by salary desc) as Salary_Rank
, dense_rank() over(partition by dept_id order by salary desc) as Rank_In_Dept
, avg(salary) over (partition by dept_id) as Dept_Avg_Salary
, lag(salary) over(order by hire_date) as Prev_Hire_Salary
from Employees 
order by dept_id asc , salary desc



--q24
create table departments (
    dept_id int primary key,
    dept_name varchar(50),
    location varchar(50),
    manager_id int
);
create table employees (
    emp_id int primary key,
    first_name varchar(50),
    last_name varchar(50),
    dept_id int,
    salary decimal(10,2),
    hire_date date,
    constraint fk_employees_departments foreign key (dept_id) references departments(dept_id)
);

create table projects (
    proj_id int primary key,
    proj_name varchar(50),
    dept_id int,
    start_date date,
    end_date date,
    status varchar(20),
    constraint fk_projects_departments foreign key (dept_id) references departments(dept_id)
);

insert into departments (dept_id, dept_name, location, manager_id) values
(10, 'Engineering', 'Cairo', 203),
(20, 'Marketing', 'Alexandria', 205),
(30, 'Operations', 'Giza', 204);

insert into employees (emp_id, first_name, last_name, dept_id, salary, hire_date) values
(201, 'Alice', 'Morgan', 10, 72000, '2021-01-01'),
(202, 'Brian', 'Carter', 20, 58000, '2021-03-15'),
(203, 'Clara', 'Nguyen', 10, 91000, '2020-06-01'),
(204, 'David', 'Smith', 30, 45000, '2022-09-01'),
(205, 'Emily', 'Hassan', 20, 67000, '2021-11-10'),
(206, 'Frank', 'Lopez', 30, 52000, '2023-02-01'),
(207, 'Grace', 'Kim', 10, 83000, '2020-05-20');

insert into projects (proj_id, proj_name, dept_id, start_date, end_date, status) values
(301, 'Core API', 10, '2023-01-01', '2023-06-30', 'Completed'),
(302, 'Brand Campaign', 20, '2023-03-01', null, 'Active'),
(303, 'Supply Chain', 30, '2023-04-01', null, 'Active'),
(304, 'Mobile App', 10, '2023-06-15', null, 'Active'),
(305, 'Recruitment Drive', 20, '2023-09-01', '2023-12-31', 'Completed');
/*Q24.Using the EMPLOYEES, DEPARTMENTS, and PROJECTS tables, write a 
complete SQL solution that performs the following four tasks: 
1. Use a CTE named DeptSalaryStats to calculate, for each department: 
the MIN salary, MAX salary, and AVG salary. 
2. Join the CTE with the EMPLOYEES table and classify each employee as 
'High' (above AVG), 'Average' (equal to AVG), or 'Below' (under AVG) 
using a CASE expression. 
3. Add a window function that assigns a dense rank to each employee 
within their department based on salary (highest salary = rank 1). 
4. Include the DEPT_NAME (from DEPARTMENTS) and filter the final result 
to show only employees who are ranked #1 in their department. */
with DeptSalaryStats as (select dept_id, min(salary) as MIN_salary  , max(salary) as MAX_salary , avg(salary) as AVG_salary from employees group by dept_id ),
ClassifiedEmp AS(select e.first_name,e.dept_id,d.dept_name,e.salary ,
case when e.salary>s.AVG_salary then 'high'
when e.salary=s.AVG_salary then 'Average'
else 'Below'
end as Salary_Class
,dense_rank() over(partition by e.dept_id order by e.salary desc) as rank_in_dept
from employees e join DeptSalaryStats s on e.dept_id=s.dept_id join departments d on e.dept_id=d.dept_id)
select first_name,dept_id,dept_name,salary,Salary_Class,Rank_In_Dept
FROM ClassifiedEmp
WHERE Rank_In_Dept = 1;
/*Q25.Using the EMPLOYEES and PROJECTS tables, write a complete SQL 
solution that produces a department performance summary report:
1. Use a CTE named ActiveProjectCount to count the number of Active 
projects per department from the PROJECTS table. 
2. Use a second CTE named DeptHeadcount to count the number of 
employees and calculate the total payroll per department. 
3. Join both CTEs with DEPARTMENTS and produce a final result showing: 
DEPT_NAME, HEADCOUNT, TOTAL_PAYROLL, ACTIVE_PROJECTS, and a 
computed column AVG_COST_PER_EMP (TOTAL_PAYROLL / 
HEADCOUNT). 
4. Order the result by TOTAL_PAYROLL descending, and use a window 
function to add a PAYROLL_RANK column that ranks departments by 
their total payroll.*/
with ActiveProjectCount as (select dept_id , count(proj_id)as active_projects from projects where status = 'Active' group by dept_id)
,
DeptHeadcount as (select count(emp_id) as headcount , sum(salary) as total_payroll , dept_id from Employees group by dept_id)
select dept_name , h.headcount , h.total_payroll , p.active_projects,
case when h.headcount> 0 then (h.total_payroll / h.headcount)
else 0 
end as avg_cost_per_emp,rank() over(order by h.total_payroll desc) as payroll_rank
from Departments d left join DeptHeadcount h on d.dept_id = h.dept_id 
left join ActiveProjectCount p on d.dept_id= p.dept_id
order by total_payroll desc

/*Q26.Write a complete PL/SQL solution that combines stored procedures, 
cursors, and exception handling to automate a department salary review: 
1. Create a stored procedure named sp_SalaryReview that accepts a 
DEPT_ID as input. 
2. Inside the procedure, use an explicit cursor to loop through all 
employees in the given department. 
3. For each employee: if their SALARY is below 60,000 → apply a 15% raise; 
if between 60,000 and 80,000 → apply a 10% raise; if above 80,000 → 
apply a 5% raise. Update the EMPLOYEES table accordingly. 
4. Add exception handling using WHEN OTHERS to print an error message 
if any update fails, and print a completion message with the total 
number of employees processed. 
5. Finally, write the EXEC/CALL statement to run sp_SalaryReview for 
department 10, then write a SELECT to verify the updated salaries.*/
CREATE PROCEDURE sp_SalaryReview @DeptID INT
AS
begin
declare @id INT;
declare @salary DECIMAL(10,2);
declare @count INT = 0;
declare c1 CURSOR for
select emp_id, salary from employees where dept_id = @DeptID;
open c1
fetch c1 into @id,@salary
while @@FETCH_STATUS=0
begin 
if @salary <60000  
update employees set salary = salary* 1.15 
else if @salary >= 60000 and @salary <=80000  
update employees set salary = salary* 1.10 
else update employees set salary = salary* 1.05
set @count=@count+1
fetch c1 into @id,@salary
end 
close c1 
deallocate c1
end
sp_SalaryReview 10
select * from employees where dept_id=10