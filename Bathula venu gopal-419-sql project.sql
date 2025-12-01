create database emp_management;

use emp_management;
-- Table 1: Job Department
CREATE TABLE JobDepartment (
    Job_ID INT PRIMARY KEY,
    jobdept VARCHAR(50),
    name VARCHAR(100),
    description TEXT,
    salaryrange VARCHAR(50)
);

-- Table 2: Salary/Bonus
CREATE TABLE SalaryBonus (
    salary_ID INT PRIMARY KEY,
    Job_ID INT,
    amount DECIMAL(10,2),
    annual DECIMAL(10,2),
    bonus DECIMAL(10,2),
    CONSTRAINT fk_salary_job FOREIGN KEY (job_ID) REFERENCES JobDepartment(Job_ID)
        ON DELETE CASCADE ON UPDATE CASCADE
);


-- Table 3: Employee
CREATE TABLE Employee (
    emp_ID INT PRIMARY KEY,
    firstname VARCHAR(50),
    lastname VARCHAR(50),
    gender VARCHAR(10),
    age INT,
    contact_add VARCHAR(100),
    emp_email VARCHAR(100) UNIQUE,
    emp_pass VARCHAR(50),
    Job_ID INT,
    CONSTRAINT fk_employee_job FOREIGN KEY (Job_ID)
        REFERENCES JobDepartment(Job_ID)
        ON DELETE SET NULL
        ON UPDATE CASCADE
);

-- Table 4: Qualification
CREATE TABLE Qualification (
    QualID INT PRIMARY KEY,
    Emp_ID INT,
    Position VARCHAR(50),
    Requirements VARCHAR(255),
    Date_In DATE,
    CONSTRAINT fk_qualification_emp FOREIGN KEY (Emp_ID)
        REFERENCES Employee(emp_ID)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);
-- Table 5: Leaves
CREATE TABLE Leaves (
    leave_ID INT PRIMARY KEY,
    emp_ID INT,
    date DATE,
    reason TEXT,
    CONSTRAINT fk_leave_emp FOREIGN KEY (emp_ID) REFERENCES Employee(emp_ID)
        ON DELETE CASCADE ON UPDATE CASCADE
);
-- Table 6: Payroll
CREATE TABLE Payroll (
    payroll_ID INT PRIMARY KEY,
    emp_ID INT,
    job_ID INT,
    salary_ID INT,
    leave_ID INT,
    date DATE,
    report TEXT,
    total_amount DECIMAL(10,2),
    CONSTRAINT fk_payroll_emp FOREIGN KEY (emp_ID) REFERENCES Employee(emp_ID)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_payroll_job FOREIGN KEY (job_ID) REFERENCES JobDepartment(job_ID)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_payroll_salary FOREIGN KEY (salary_ID) REFERENCES SalaryBonus(salary_ID)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_payroll_leave FOREIGN KEY (leave_ID) REFERENCES Leaves(leave_ID)
        ON DELETE SET NULL ON UPDATE CASCADE
);
show tables;

select * from jobdepartment;
select * from salarybonus;
select * from employee;
select * from leaves;
select * from qualification;
select * from payroll;

select count(*)from employee;
select count(*)from jobdepartment;
select count(*)from leaves;
select count(*)from qualification;
select count(*)from payroll;
select count(*)from salarybonus;

-- 1.Analysis Questions
-- 1. EMPLOYEE INSIGHTS
-- How many unique employees are currently in the system?

SELECT COUNT(DISTINCT Emp_ID) AS unique_employees
FROM Employee;

-- q2)Which departments have the highest number of employees?

SELECT 
    jd.jobdept AS department,
    COUNT(e.Emp_ID) AS employee_count
FROM 
    Employee e
JOIN 
    JobDepartment jd ON e.Job_ID = jd.Job_ID
GROUP BY 
    jd.jobdept
ORDER BY 
    employee_count DESC;
    
    -- q3) What is the average salary per department?   

SELECT jd.jobdept AS department,
       ROUND(AVG(sb.amount), 2) AS avg_salary
FROM SalaryBonus sb
JOIN JobDepartment jd ON sb.Job_ID = jd.Job_ID
GROUP BY jd.jobdept
ORDER BY avg_salary DESC;

-- q4) Who are the top 5 highest-paid employees?

SELECT e.emp_ID, CONCAT(e.firstname, ' ', e.lastname) AS employee_name,
       sb.amount AS salary, sb.bonus
FROM Employee e
JOIN SalaryBonus sb ON e.Job_ID = sb.Job_ID
ORDER BY sb.amount DESC
LIMIT 5;

SELECT e.emp_ID, 
       CONCAT(e.firstname, ' ', e.lastname) AS employee_name,
       sb.amount AS salary
FROM Employee e
JOIN SalaryBonus sb ON e.Job_ID = sb.Job_ID
ORDER BY sb.amount DESC
LIMIT 5;


-- q5)What is the total salary expenditure across the company?

SELECT ROUND(SUM(sb.amount), 2) AS total_salary_expenditure
FROM SalaryBonus sb;

-- 2. JOB ROLE AND DEPARTMENT ANALYSIS

-- q1)How many different job roles exist in each department? 

SELECT jobdept, COUNT(Job_ID) AS total_job_roles
FROM JobDepartment
GROUP BY jobdept
ORDER BY total_job_roles DESC;

-- q2)What is the average salary range per department?
SELECT salaryrange FROM JobDepartment;

SELECT jobdept AS department,
       ROUND(AVG(
           (
               CAST(
                   REPLACE(
                       REPLACE(
                           REPLACE(
                               TRIM(SUBSTRING_INDEX(salaryrange, '-', 1)),
                           '₹', ''), '$', ''), ',', ''
                       )
                   AS UNSIGNED
               ) +
               CAST(
                   REPLACE(
                       REPLACE(
                           REPLACE(
                               TRIM(SUBSTRING_INDEX(salaryrange, '-', -1)),
                           '₹', ''), '$', ''), ',', ''
                       )
                   AS UNSIGNED
               )
           ) / 2
       ), 2) AS avg_salary_range
FROM JobDepartment
GROUP BY jobdept;

-- q3)Which job roles offer the highest salary?

SELECT jd.name AS job_role, jd.jobdept,
       sb.amount AS salary
FROM JobDepartment jd
JOIN SalaryBonus sb ON jd.Job_ID = sb.Job_ID
ORDER BY sb.amount DESC
LIMIT 5;

-- q4) Which departments have the highest total salary allocation?

SELECT jd.jobdept AS department,
       ROUND(SUM(sb.amount), 2) AS total_salary
FROM SalaryBonus sb
JOIN JobDepartment jd ON sb.Job_ID = jd.Job_ID
GROUP BY jd.jobdept
ORDER BY total_salary DESC;

-- 3. QUALIFICATION AND SKILLS ANALYSIS

-- q1)How many employees have at least one qualification listed?

SELECT COUNT(DISTINCT Emp_ID) AS Employees_With_Qualification
FROM Qualification;

-- q2)Which positions require the most qualifications?

SELECT q.Position,
       COUNT(q.QualID) AS total_qualifications
FROM Qualification q
GROUP BY q.Position
ORDER BY total_qualifications DESC;

-- q3)Which employees have the highest number of qualifications?

SELECT e.emp_ID, CONCAT(e.firstname, ' ', e.lastname) AS employee_name,
       COUNT(q.QualID) AS total_qualifications
FROM Employee e
JOIN Qualification q ON e.emp_ID = q.Emp_ID
GROUP BY e.emp_ID
ORDER BY total_qualifications DESC
LIMIT 5;

-- 4. LEAVE AND ABSENCE PATTERNS

-- q1)Which year had the most employees taking leaves?

SELECT YEAR(date) AS year,
       COUNT(DISTINCT emp_ID) AS employees_took_leaves
FROM Leaves
GROUP BY YEAR(date)
ORDER BY employees_took_leaves DESC;

-- q2)What is the average number of leave days taken by its employees per department?

SELECT jd.jobdept AS department,
       ROUND(AVG(leave_count), 2) AS avg_leave_days
FROM (
    SELECT e.emp_ID, e.Job_ID, COUNT(l.leave_ID) AS leave_count
    FROM Leaves l
    JOIN Employee e ON l.emp_ID = e.emp_ID
    GROUP BY e.emp_ID, e.Job_ID
) AS emp_leaves
JOIN JobDepartment jd ON emp_leaves.Job_ID = jd.Job_ID
GROUP BY jd.jobdept;


-- q3)Which employees have taken the most leaves?

SELECT e.emp_ID, CONCAT(e.firstname, ' ', e.lastname) AS employee_name,
       COUNT(l.leave_ID) AS total_leaves
FROM Leaves l
JOIN Employee e ON l.emp_ID = e.emp_ID
GROUP BY e.emp_ID
ORDER BY total_leaves DESC
LIMIT 5;

-- q4)What is the total number of leave days taken company-wide?

SELECT COUNT(leave_ID) AS total_leave_days
FROM Leaves;

-- q5)How do leave days correlate with payroll amounts?

SELECT e.emp_ID, CONCAT(e.firstname, ' ', e.lastname) AS employee_name,
       COUNT(l.leave_ID) AS total_leaves,
       ROUND(AVG(p.total_amount), 2) AS avg_payroll
FROM Employee e
LEFT JOIN Leaves l ON e.emp_ID = l.emp_ID
LEFT JOIN Payroll p ON e.emp_ID = p.emp_ID
GROUP BY e.emp_ID
ORDER BY total_leaves DESC;

-- 5. PAYROLL AND COMPENSATION ANALYSIS

-- q1)What is the total monthly payroll processed?

SELECT DATE_FORMAT(date, '%Y-%m') AS month,
       ROUND(SUM(total_amount), 2) AS total_monthly_payroll
FROM Payroll
GROUP BY DATE_FORMAT(date, '%Y-%m')
ORDER BY month DESC;

-- q2)What is the average bonus given per department?

SELECT jd.jobdept AS department,
       ROUND(AVG(sb.bonus), 2) AS avg_bonus
FROM SalaryBonus sb
JOIN JobDepartment jd ON sb.Job_ID = jd.Job_ID
GROUP BY jd.jobdept
ORDER BY avg_bonus DESC;

-- q3)Which department receives the highest total bonuses?

SELECT jd.jobdept AS department,
       ROUND(SUM(sb.bonus), 2) AS total_bonus
FROM SalaryBonus sb
JOIN JobDepartment jd ON sb.Job_ID = jd.Job_ID
GROUP BY jd.jobdept
ORDER BY total_bonus DESC;

-- q4)What is the average value of total_amount after considering leave deductions?

SELECT ROUND(AVG(total_amount), 2) AS avg_total_after_leaves
FROM Payroll;
