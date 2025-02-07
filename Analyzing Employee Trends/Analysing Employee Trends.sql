# Analysing Employee Trends

create database HR; 
use HR;
--- To read Data ---

CREATE TABLE employee_records (
    emp_no INT PRIMARY KEY,
    gender VARCHAR(20),
    marital_status VARCHAR(20),
    age_band VARCHAR(20),
    age INT,
    department VARCHAR(50),
    education VARCHAR(50),
    education_field VARCHAR(50),
    job_role VARCHAR(50),
    business_travel VARCHAR(50),
    employee_count INT,
    attrition VARCHAR(10),
    attrition_label VARCHAR(50),
    job_satisfaction INT,
    active_employee INT
);

select * from employee_records; 

-- 1. Count the number of employees in each department---

select department, count(department) as number_of_employees from employee_records group by department; 

-- 2.Calculate the average age for each department ---

select department, avg(age) as department_wise_avg_age from employee_records group by department; 

-- 3. Identify the most common job roles in each department ---

select department, job_role, count(*) as role_count
from employee_records
group by department, job_role
order by department, role_count desc;

-- 4. Calculate the average job satisfaction for each education level ---

select education_field, avg(job_satisfaction) as avg_job_satisfaction from employee_records group by education_field; 


-- 5.Determine the average age for employees with different levels of job satisfaction ---

select job_satisfaction, avg(age) as avg_age from employee_records group by job_satisfaction; 

-- 6. Calculate the attrition rate for each age band -- 
-- >Attrition Rate= 
-- >(Number of Employees Who Left/Total Number of Employees in the Age Band)*100

SELECT age_band,COUNT(*) AS total_employees,
    SUM(CASE WHEN attrition = 'Yes' THEN 1 ELSE 0 END) AS attrition_count,
    (SUM(CASE WHEN attrition = 'Yes' THEN 1 ELSE 0 END) * 1.0 / COUNT(*)) * 100 AS attrition_rate
FROM employee_records GROUP BY age_band ORDER BY age_band; 

-- 7. Identify the departments with the highest and lowest average job satisfaction ---

WITH DepartmentSatisfaction AS (
    SELECT 
        department, 
        AVG(job_satisfaction) AS avg_satisfaction
    FROM employee_records
    GROUP BY department
)
SELECT department, avg_satisfaction
FROM DepartmentSatisfaction
WHERE avg_satisfaction = (SELECT MAX(avg_satisfaction) FROM DepartmentSatisfaction)
   OR avg_satisfaction = (SELECT MIN(avg_satisfaction) FROM DepartmentSatisfaction); 
   

-- 8. Find the age band with the highest attrition rate among employees with a specific education level---

WITH AgeBandAttrition AS (
    SELECT 
        age_band, 
        COUNT(CASE WHEN attrition = 'Yes' THEN 1 END) * 100.0 / COUNT(*) AS attrition_rate
    FROM employee_records
    WHERE education = 'Master\'s Degree'  -- Filtering for Master's Degree holders/ we can add other education level instead of master's degree
    GROUP BY age_band
)
SELECT age_band, attrition_rate
FROM AgeBandAttrition
ORDER BY attrition_rate DESC
LIMIT 1; 


-- 9.Find the education level with the highest average job satisfaction among employees who travel frequently ---

WITH EducationSatisfaction AS (
    SELECT 
        education, 
        AVG(job_satisfaction) AS avg_satisfaction
    FROM employee_records
    WHERE business_travel = 'Travel_Frequently'  -- Filtering employees who travel frequently
    GROUP BY education
)
SELECT education, avg_satisfaction
FROM EducationSatisfaction
ORDER BY avg_satisfaction DESC
LIMIT 1;


-- 10. Identify the age band with the highest average job satisfaction among married employees ----

WITH AgeBandSatisfaction AS (
    SELECT 
        age_band, 
        AVG(job_satisfaction) AS avg_satisfaction
    FROM employee_records
    WHERE marital_status = 'Married'  -- Filtering for married employees
    GROUP BY age_band
)
SELECT age_band, avg_satisfaction
FROM AgeBandSatisfaction
ORDER BY avg_satisfaction DESC
LIMIT 1;
