/*
 * ScienceQtech Employee Performance Mapping
 * Course-end Project 1
 * 
 * Description:
 * ScienceQtech is a startup that works in the Data Science field.
 * This project analyzes employee performance, calculates bonuses,
 * and generates reports for the HR department.
 * 
 * Database: employee_final_Project_ScienceQtech
 */

-- ============================================================================
-- 1. DATABASE CREATION
-- ============================================================================

CREATE DATABASE IF NOT EXISTS employee_final_Project_ScienceQtech;
USE employee_final_Project_ScienceQtech;

-- ============================================================================
-- 2. TABLE CREATION
-- ============================================================================

-- Projects Table
CREATE TABLE proj_table (
    PROJECT_ID VARCHAR(10) PRIMARY KEY,
    PROJ_NAME VARCHAR(100),
    DOMAIN VARCHAR(100),
    START_DATE DATE,
    CLOSURE_DATE DATE,
    DEV_QTR VARCHAR(10),
    STATUS VARCHAR(50)
);

-- Employee Records Table
CREATE TABLE emp_record_table (
    EMP_ID VARCHAR(10) PRIMARY KEY,
    FIRST_NAME VARCHAR(50),
    LAST_NAME VARCHAR(50),
    GENDER VARCHAR(10),
    ROLE VARCHAR(100),
    DEPT VARCHAR(100),
    EXP INT,
    COUNTRY VARCHAR(50),
    CONTINENT VARCHAR(50),
    SALARY DECIMAL(10,2),
    EMP_RATING INT,
    MANAGER_ID VARCHAR(10),
    PROJ_ID VARCHAR(10),
    CONSTRAINT fk_manager FOREIGN KEY (MANAGER_ID) 
        REFERENCES emp_record_table(EMP_ID) ON DELETE SET NULL,
    CONSTRAINT fk_project FOREIGN KEY (PROJ_ID) 
        REFERENCES proj_table(PROJECT_ID) ON DELETE SET NULL
);

-- Data Science Team Table
CREATE TABLE data_science_team (
    EMP_ID VARCHAR(10),
    FIRST_NAME VARCHAR(50),
    LAST_NAME VARCHAR(50),
    GENDER VARCHAR(10),
    ROLE VARCHAR(100),
    DEPT VARCHAR(100),
    EXP INT,
    COUNTRY VARCHAR(50),
    CONTINENT VARCHAR(50),
    PRIMARY KEY (EMP_ID),
    CONSTRAINT fk_ds_emp FOREIGN KEY (EMP_ID) 
        REFERENCES emp_record_table(EMP_ID) ON DELETE CASCADE
);

-- ============================================================================
-- 3. BASIC QUERIES - View all employees by department
-- ============================================================================

SELECT EMP_ID, FIRST_NAME, LAST_NAME, GENDER, DEPT 
FROM emp_record_table 
ORDER BY DEPT;

-- ============================================================================
-- 4. FILTER EMPLOYEES BY RATING
-- ============================================================================

-- Employees with rating less than 2
SELECT EMP_ID, FIRST_NAME, LAST_NAME, GENDER, DEPT, EMP_RATING 
FROM emp_record_table 
WHERE EMP_RATING < 2;

-- Employees with rating greater than 4
SELECT EMP_ID, FIRST_NAME, LAST_NAME, GENDER, DEPT, EMP_RATING 
FROM emp_record_table 
WHERE EMP_RATING > 4;

-- Employees with rating between 2 and 4
SELECT EMP_ID, FIRST_NAME, LAST_NAME, GENDER, DEPT, EMP_RATING 
FROM emp_record_table 
WHERE EMP_RATING >= 2 AND EMP_RATING <= 4;

-- ============================================================================
-- 5. CONCATENATE NAMES IN FINANCE DEPARTMENT
-- ============================================================================

SELECT *, 
       CONCAT(FIRST_NAME, ' ', LAST_NAME) AS NAME 
FROM emp_record_table 
WHERE DEPT = 'FINANCE';

-- ============================================================================
-- 6. LIST EMPLOYEES WITH REPORTERS
-- ============================================================================

SELECT MANAGER_ID, COUNT(EMP_ID) AS REPORTERS 
FROM emp_record_table 
WHERE MANAGER_ID IS NOT NULL 
GROUP BY MANAGER_ID 
ORDER BY MANAGER_ID;

-- ============================================================================
-- 7. UNION - Healthcare and Finance Departments
-- ============================================================================

SELECT * FROM emp_record_table WHERE DEPT = 'Healthcare'
UNION
SELECT * FROM emp_record_table WHERE DEPT = 'Finance'
ORDER BY DEPT, EMP_ID;

-- ============================================================================
-- 8. WINDOW FUNCTION - Max Rating per Department
-- ============================================================================

SELECT EMP_ID, 
       FIRST_NAME,
       LAST_NAME,
       ROLE,
       DEPT,
       EMP_RATING,
       MAX(EMP_RATING) OVER (PARTITION BY DEPT) AS MAX_RATING
FROM emp_record_table;

-- ============================================================================
-- 9. MIN AND MAX SALARY BY ROLE
-- ============================================================================

-- Using Window Functions
SELECT *, 
       MAX(SALARY) OVER (PARTITION BY DEPT) AS MAX_SALARY_ON_THIS_DEPT,
       MIN(SALARY) OVER (PARTITION BY DEPT) AS MIN_SALARY_ON_THIS_DEPT
FROM emp_record_table;

-- Using GROUP BY
SELECT ROLE,
       MIN(SALARY) AS MIN_SAL_OF_ROLE,
       MAX(SALARY) AS MAX_SAL_OF_ROLE
FROM emp_record_table 
GROUP BY ROLE;

-- ============================================================================
-- 10. RANK EMPLOYEES BY EXPERIENCE
-- ============================================================================

SELECT EMP_ID,
       CONCAT(FIRST_NAME, ' ', LAST_NAME) AS FULL_NAME,
       ROLE,
       DEPT,
       EXP,
       RANK() OVER (ORDER BY EXP) AS EMP_EXP_RANK
FROM emp_record_table;

-- ============================================================================
-- 11. CREATE VIEW - Employees with Salary > 6000
-- ============================================================================

CREATE OR REPLACE VIEW Salary AS
SELECT EMP_ID, FIRST_NAME, LAST_NAME, COUNTRY, SALARY
FROM emp_record_table
WHERE SALARY >= 6000
ORDER BY COUNTRY, EMP_ID;

-- View the created view
SELECT * FROM Salary;

-- ============================================================================
-- 12. NESTED QUERY - Employees with Experience > 10 Years
-- ============================================================================

SELECT EMP_ID, FIRST_NAME, LAST_NAME, EXP
FROM (
    SELECT * 
    FROM emp_record_table 
    WHERE EXP > 10 
    ORDER BY EXP
) AS EXP_GREATER_THAN_10;

-- ============================================================================
-- 13. STORED PROCEDURE - Employees with Experience > 3 Years
-- ============================================================================

DELIMITER $$

CREATE PROCEDURE getEMP_DETAILS()
BEGIN
    SELECT * 
    FROM emp_record_table 
    WHERE EXP > 3 
    ORDER BY EXP;
END$$

DELIMITER ;

-- Call the procedure
CALL getEMP_DETAILS();

-- ============================================================================
-- 14. STORED PROCEDURE - Check Job Standards by Experience
-- ============================================================================

DELIMITER $$

CREATE PROCEDURE CHECK_STANDARDS(
    IN p_exp INT,
    OUT p_position VARCHAR(50)
)
BEGIN
    DECLARE v_position VARCHAR(50);
    
    IF p_exp <= 2 THEN
        SET v_position = 'JUNIOR DATA SCIENTIST';
    ELSEIF p_exp > 2 AND p_exp <= 5 THEN
        SET v_position = 'ASSOCIATE DATA SCIENTIST';
    ELSEIF p_exp > 5 AND p_exp <= 10 THEN
        SET v_position = 'SENIOR DATA SCIENTIST';
    ELSEIF p_exp > 10 AND p_exp <= 12 THEN
        SET v_position = 'LEAD DATA SCIENTIST';
    ELSEIF p_exp > 12 AND p_exp <= 16 THEN
        SET v_position = 'MANAGER';
    ELSE
        SET v_position = 'DIRECTOR OR HIGHER';
    END IF;
    
    SET p_position = v_position;
END$$

DELIMITER ;

-- Test the procedure
CALL CHECK_STANDARDS(12, @POSITION);
SELECT @POSITION;

-- ============================================================================
-- 15. CREATE INDEX - Improve Performance for FIRST_NAME Search
-- ============================================================================

-- Check execution plan before index
EXPLAIN SELECT * FROM emp_record_table WHERE FIRST_NAME = 'Eric';

-- Create index
CREATE INDEX idx_first_name ON emp_record_table(FIRST_NAME(10));

-- Show all indexes
SHOW INDEXES FROM emp_record_table;

-- Check execution plan after index
EXPLAIN SELECT * FROM emp_record_table WHERE FIRST_NAME = 'Eric';

-- ============================================================================
-- 16. CALCULATE BONUS (5% of Salary × Employee Rating)
-- ============================================================================

SELECT EMP_ID,
       CONCAT(FIRST_NAME, ' ', LAST_NAME) AS NAME,
       EMP_RATING,
       SALARY,
       (SALARY * 0.05) * EMP_RATING AS BONUS
FROM emp_record_table;

-- ============================================================================
-- 17. AVERAGE SALARY BY CONTINENT AND COUNTRY
-- ============================================================================

-- By Continent
SELECT CONTINENT,
       AVG(SALARY) AS AVG_SALARY
FROM emp_record_table
GROUP BY CONTINENT
ORDER BY CONTINENT DESC;

-- By Country
SELECT COUNTRY,
       AVG(SALARY) AS AVG_SALARY
FROM emp_record_table
GROUP BY COUNTRY
ORDER BY AVG_SALARY DESC;

-- By Continent and Country
SELECT CONTINENT,
       COUNTRY,
       AVG(SALARY) AS AVG_SALARY
FROM emp_record_table
GROUP BY CONTINENT, COUNTRY
ORDER BY CONTINENT, COUNTRY;

-- ============================================================================
-- END OF SCRIPT
-- ============================================================================
