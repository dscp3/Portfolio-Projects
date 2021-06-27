SELECT TOP 10
*
FROM
dbo.COVID_DEATHS
ORDER BY 3,4;


-- SELECTING OUR DATA

SELECT
location, date, total_cases, total_deaths, population
FROM
portfolioproject..COVID_DEATHS
ORDER BY 1,2;


-- GENERAL STUDIES OF CASES AND DEATHS PER COUNTRY
-- death_percent variable tells us, basically, the probability of dying from covid in each country

SELECT
location, date, total_cases, total_deaths, ROUND(total_deaths/total_cases, 3) AS death_percent
FROM
portfolioproject..COVID_DEATHS
WHERE location = 'Brazil'
ORDER BY 2 DESC;


-- (PARENTHESIS): How to alter the datatype of a column in a table

-- We can also convert a datatype using: CAST(expression AS datatype) | e.g. CAST(total_deaths AS INT)

ALTER TABLE portfolioproject..COVID_DEATHS
ALTER COLUMN new_deaths INT;


-- Total cases vs population

SELECT
location, date, total_cases, Population, ROUND((total_cases/Population), 4) as incidence
FROM
dbo.COVID_DEATHS
ORDER BY 1,2;


-- Countries with highest infection rate 
SELECT
location, Population, MAX(total_cases) as act_cases, MAX(ROUND((total_cases/Population), 4)) as incidence
FROM
dbo.COVID_DEATHS
GROUP BY location, Population
ORDER BY incidence DESC;


-- Countries with highest letality rate
SELECT
location, MAX(CAST(total_deaths AS INT)) as act_deaths, MAX(ROUND((total_deaths/Population), 5)) as letality
FROM
portfolioproject..COVID_DEATHS
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY act_deaths DESC;

-- Now, by continent
SELECT
continent, MAX(CAST(total_deaths AS INT)) as act_deaths
FROM
portfolioproject..COVID_DEATHS
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY act_deaths DESC;

SELECT
location, MAX(CAST(total_deaths AS INT)) as act_deaths
FROM
portfolioproject..COVID_DEATHS
WHERE continent IS NULL
GROUP BY location
ORDER BY act_deaths DESC;


-- Global numbers
SELECT
	date, SUM(new_cases) as cases, SUM(CAST(new_deaths AS INT)) as deaths, ROUND(SUM(CAST(new_deaths AS INT))/SUM(new_cases), 3) as death_percentage
FROM
	portfolioproject..COVID_DEATHS
WHERE
	continent IS NOT NULL
GROUP BY date
ORDER BY 1,2;

-- Consolidated
SELECT
	SUM(new_cases) as cases, SUM(CAST(new_deaths AS INT)) as deaths, ROUND(SUM(CAST(new_deaths AS INT))/SUM(new_cases), 3) as death_percentage
FROM
	portfolioproject..COVID_DEATHS
WHERE
	continent IS NOT NULL
ORDER BY 1,2;


-- JOINING TABLES

-- Population v Vaccination
SELECT
	d.continent, d.location, d.date, d.population, v.new_vaccinations, SUM(CONVERT(INT, v.new_vaccinations)) OVER (PARTITION BY d.location
	ORDER BY d.date) AS acum_vacc
FROM
	portfolioproject..COVID_DEATHS d
JOIN
	portfolioproject..COVID_VACCINATIONS v ON d.location = v.location AND d.date = v.date
WHERE d.continent IS NOT NULL
ORDER BY 2,3;

-- USE CTE (e.g. for Brazil)

WITH pop_vac (continent, location, date, population, new_vaccinations, acum_vacc)
AS
(
SELECT
	d.continent, d.location, d.date, d.population, v.new_vaccinations, SUM(CONVERT(INT, v.new_vaccinations)) OVER (PARTITION BY d.location
	ORDER BY d.date) AS acum_vacc
FROM
	portfolioproject..COVID_DEATHS d
JOIN
	portfolioproject..COVID_VACCINATIONS v ON d.location = v.location AND d.date = v.date
WHERE d.continent IS NOT NULL
)

SELECT 
	*, ROUND((acum_vacc/population) * 100, 2) as vacc_percent
FROM
	pop_vac
WHERE location = 'Brazil';


-- TABLE VARIABLE

DECLARE @percent_pop_vacc TABLE
(
	continent NVARCHAR(255),
	location NVARCHAR(255),
	date DATETIME,
	population NUMERIC,
	new_vacc NUMERIC,
	acum_vacc NUMERIC
)

INSERT INTO @percent_pop_vacc
SELECT
	d.continent, d.location, d.date, d.population, v.new_vaccinations, SUM(CONVERT(INT, v.new_vaccinations)) OVER (PARTITION BY d.location
	ORDER BY d.date) AS acum_vacc
FROM
	portfolioproject..COVID_DEATHS d
JOIN
	portfolioproject..COVID_VACCINATIONS v ON d.location = v.location AND d.date = v.date
WHERE d.continent IS NOT NULL;

SELECT
*, ROUND(acum_vacc/population * 100, 2) as vacc_percent
FROM
@percent_pop_vacc;


-- CREATE VIEW FOR LATER VIS

CREATE VIEW v_percent_pop_vacc AS
SELECT
	d.continent, d.location, d.date, d.population, v.new_vaccinations, SUM(CONVERT(INT, v.new_vaccinations)) OVER (PARTITION BY d.location
	ORDER BY d.date) AS acum_vacc
FROM
	portfolioproject..COVID_DEATHS d
JOIN
	portfolioproject..COVID_VACCINATIONS v ON d.location = v.location AND d.date = v.date
WHERE d.continent IS NOT NULL;

SELECT
*
FROM
v_percent_pop_vacc;