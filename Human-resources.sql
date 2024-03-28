UPDATE "HumanResources"
SET termdate = COALESCE(termdate, '0001-01-01'::date);

ALTER TABLE "HumanResources"
	ADD COLUMN age INT;

UPDATE "HumanResources"
	SET age = EXTRACT(YEAR FROM AGE(CURRENT_DATE, birthdate));

SELECT *
FROM public."HumanResources";

SELECT MIN(age) AS youngest,
	MAX(age) AS oldest
FROM "HumanResources";

SELECT COUNT(*)
FROM "HumanResources"
WHERE age < 18;

-- 1. What is the gender breakdown of employees in the company?
SELECT gender, COUNT(*) AS count
FROM "HumanResources"
WHERE age >= 18 AND termdate = '0001-01-01'
GROUP BY gender;


-- 2. What is the race/ethnicity breakdown of employees in the company?
SELECT race, COUNT(*) AS count
FROM "HumanResources"
WHERE age >= 18 AND termdate = '0001-01-01'
GROUP BY race
ORDER BY count(*) DESC;


-- 3. What is the age distribution of employees in the company?
SELECT age, 
	COUNT(*) AS count
FROM "HumanResources"
WHERE age >= 18 AND termdate = '0001-01-01'
GROUP BY age
ORDER BY age ASC;

----
SELECT MIN(age) AS Youngest,
	MAX(age) AS Oldest
FROM "HumanResources"
WHERE age >= 18 AND termdate = '0001-01-01'

SELECT 
	CASE
		WHEN age >= 20 AND age <= 29 THEN '20-29'
		WHEN age >= 30 AND age <= 39 THEN '30-39'
		WHEN age >= 40 AND age <= 49 THEN '40-49'
		WHEN age >= 50 AND age <= 59 THEN '50-59'
		ELSE '60+'
END AS age_group, COUNT(*) AS count
FROM "HumanResources"
WHERE age >= 18 AND termdate = '0001-01-01'
GROUP BY age_group
ORDER BY age_group;

-- 4. How many employees work at headquarters versus remote locations?
SELECT location, COUNT(*) AS count
FROM "HumanResources"
WHERE age >= 18 AND termdate = '0001-01-01'
GROUP BY location;

-- 5. What is the average length of employment for employees who have been terminated?
SELECT ROUND(AVG((termdate - hire_date)/365),0) AS avg_length_employment
FROM "HumanResources"
WHERE age >= 18 AND termdate <= CURRENT_DATE AND termdate <> '0001-01-01';

-- 6. How does the gender distribution vary across departments and job titles?
SELECT gender
	, department
	, COUNT(*) AS count
FROM "HumanResources"
WHERE termdate = '0001-01-01'
GROUP BY department, gender
ORDER BY department;

-- 7. What is the distribution of job titles across the company?
SELECT jobtitle
	, COUNT(*) AS count
FROM "HumanResources"
WHERE termdate = '0001-01-01'
GROUP BY jobtitle
ORDER BY count DESC;



-- 8. Which department has the highest turnover rate?
SELECT total_count
		, terminated_count
		, CASE WHEN total_count > 0 THEN terminated_count::numeric/total_count ELSE 0 END AS termination_rate
FROM (
	SELECT department
		, COUNT(*) AS total_count
		, SUM(CASE WHEN termdate <> '0001-01-01'
				AND termdate < CURRENT_DATE
				THEN 1
				ELSE 0
			END)
		AS terminated_count
	FROM "HumanResources"
	GROUP BY department
	)
AS subquery
ORDER BY termination_rate DESC;


-- 9. What is the distribution of employees across locations by city and state?
SELECT location_city, location_state, COUNT(*) AS count
FROM "HumanResources"
GROUP BY location_city, location_state
ORDER BY location_state, location_city DESC;

-- 10. How has the company's employee count changed over time based on hire and term dates?
SELECT year, hires, terminations, hires - terminations AS net_change, ROUND((hires - terminations)/hires::numeric * 100, 2) AS net_change_percent
FROM (
	SELECT EXTRACT (YEAR FROM hire_date) AS year
		, COUNT(*) AS hires
		, SUM(CASE WHEN termdate <> '0001-01-01' AND termdate < CURRENT_DATE THEN 1 ELSE 0 END) AS terminations
		FROM "HumanResources"
		GROUP BY year
) 
AS subquery
ORDER BY year ASC;


-- 11. What is the tenure distribution for each department?
SELECT department, AVG((termdate - hire_date)::numeric / 365) AS avg_tenure
FROM "HumanResources"
WHERE termdate < CURRENT_DATE AND termdate <> '0001-01-01'
GROUP BY department;
