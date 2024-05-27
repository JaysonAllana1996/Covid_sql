-- Let's view the Table CovidDeaths 
Select *
From CovidDeaths



-- Let's view the table CovidVaccinations
Select *
From CovidVaccinations



--Counting total cases per country
SELECT 
    iso_code
    ,location
    ,MAX(Cast(total_cases as int)) AS total_cases
FROM 
    CovidDeaths
GROUP BY 
    iso_code
    ,location
Order BY
    iso_code 


--Counting total cases per country vs sum of new cases(Should be equal)
SELECT 
    iso_code
    ,location
    ,Sum(Cast(new_cases as int)) AS sum_new_cases
    ,MAX(Cast(total_cases as int)) AS total_cases_max
FROM 
    CovidDeaths
GROUP BY 
    iso_code
    , location
Order BY
    iso_code 



--Counting total cases by continent
SELECT 
    continent
    ,Sum(Cast(new_cases as int)) AS sum_new_cases
    ,MAX(Cast(total_cases as int)) AS total_cases_max
FROM 
    CovidDeaths
WHERE
continent IS NOT NULL
    AND TRIM(continent) != ''
-- Trim function added due to nulls still displayed when no trim is used
GROUP BY 
    continent
Order BY
    total_cases_max DESC



-- Ranking country with most deaths 
SELECT 
    continent
    ,location as country
    ,Sum(Cast(new_deaths as int)) AS sum_new_death
    ,MAX(Cast(total_deaths as int)) AS total_death_max
FROM 
    CovidDeaths
WHERE
continent IS NOT NULL
    AND TRIM(continent) != ''
GROUP BY 
    location
    ,continent
Order BY
    total_death_max DESC



-- Ranking country with total deaths per million 
SELECT 
    continent
    ,location as country
    ,MAX(Cast(new_deaths as float)) AS sum_new_death
    ,MAX(Cast(total_deaths_per_million as float)) AS total_death_per_million
FROM 
    CovidDeaths
WHERE
continent IS NOT NULL
    AND TRIM(continent) != ''
GROUP BY 
    location
    ,continent
Order BY
    total_death_per_million DESC


-- Ranking continent with most deaths 
SELECT 
    location as continent
    ,Sum(Cast(new_deaths as int)) AS sum_new_death
    ,MAX(Cast(total_deaths as int)) AS total_death_max
FROM 
    CovidDeaths
WHERE
continent =' '
GROUP BY 
	location
Order BY
    total_death_max DESC


-- Ranking deaths per cases percentage by country
SELECT 
    continent
    ,location as country
    ,MAX(Cast(total_deaths as int)) AS total_death_max
    ,MAX(Cast(total_cases as int)) AS total_cases_max
	,CAST(ROUND((MAX(CAST(total_deaths AS INT)) * 100.0) / MAX(CAST(total_cases AS INT)), 2) AS DECIMAL(10, 2)) AS death_pct
FROM 
    CovidDeaths
WHERE
continent IS NOT NULL
    AND TRIM(continent) != ''
	and total_cases != 0
GROUP BY 
    location
    ,continent
Order BY
   death_pct DESC



-- Top country with highest percentage of cases vs population
SELECT 
    location
    ,MAX(Cast(total_cases as int)) AS total_cases_max
	,Max(Cast(population as int)) AS total_population
	,CAST(ROUND((MAX(CAST(total_cases AS INT)) * 100.0) / MAX(CAST(population AS INT)), 2) AS DECIMAL(10, 2)) AS cases_pct
FROM 
    CovidDeaths
WHERE
continent IS NOT NULL
    AND TRIM(continent) != ''
	and total_cases != 0
GROUP BY 
    location
Order BY
   cases_pct DESC


-- Top Cases and deaths per million and death percentage
Select 
	location
	,continent
	-- I need to compare the max and sum of the columns to check if the data is correct
	,SUM(Cast(new_cases_per_million as float)) as case_per_mil_sum
	,Max(Cast(total_cases_per_million as float)) as case_per_mil_max
	,SUM(Cast(new_deaths_per_million as float)) as death_per_mil_sum
	,Max(Cast(total_deaths_per_million as float)) as death_per_mil_max
	,MAX(Cast(total_deaths as int)) AS total_death_max
    ,MAX(Cast(total_cases as int)) AS total_cases_max
	,CAST(ROUND((MAX(CAST(total_deaths AS INT)) * 100.0) / MAX(CAST(total_cases AS INT)), 2) AS DECIMAL(10, 2)) AS death_pct
From
	CovidDeaths
WHERE
continent IS NOT NULL
    AND TRIM(continent) != ''
	and total_cases != 0
GROUP BY 
    location
	,continent
Order BY
   death_pct desc



--First case dates of each country
Select
	location
	,Cast(date as date) as first_date 
	,Cast(new_cases as int) as first_case
From
	CovidDeaths
Where
	new_cases = 1
Order by 
	first_case ASC
	




-- First case dates of each country with new cases on that date
SELECT
    cd.location,
    cd.date AS first_case_date,
    cd.new_cases
FROM
    CovidDeaths cd
INNER JOIN (
    SELECT
        location
        ,MIN(CAST(date AS DATE)) AS first_case_date
    FROM
        CovidDeaths
    WHERE
	continent IS NOT NULL
    AND TRIM(continent) != ''
    And new_cases > 0
    GROUP BY 
        location
) first_dates ON cd.location = first_dates.location 
	AND cd.date = first_dates.first_case_date
ORDER BY
    first_case_date ASC;






-- Countries with most total tests conducted
SELECT 
    location
    ,Sum(Cast(new_tests as int)) AS sum_new_tests
    ,MAX(Cast(total_tests as int)) AS total_tests_max
FROM 
    CovidVaccinations
WHERE
continent IS NOT NULL
    AND TRIM(continent) != ''
	and total_tests != 0
GROUP BY 
	location
Order BY
    total_tests_max DESC



-- Total Vaccinated per country
SELECT 
    location
    ,MAX(Cast(people_fully_vaccinated as int)) AS people_fully_vaccinated
FROM 
    CovidVaccinations
WHERE
continent IS NOT NULL
    AND TRIM(continent) != ''
GROUP BY 
	location
Order BY
    people_fully_vaccinated DESC



-- Total Percentage of vaccinated people and the countries' population
SELECT 
    cd.location
    ,MAX(CAST(cv_subquery.people_fully_vaccinated AS bigint)) AS people_fully_vaccinated
    ,MAX(CAST(cd.population AS bigint)) AS total_population
    ,CAST(
        ROUND(
            (MAX(CAST(cv_subquery.people_fully_vaccinated AS bigint)) * 100.0) / MAX(CAST(cd.population AS bigint)),
            2 -- Number of decimal places
        ) 
        AS FLOAT
    ) AS vaccinated_pct
FROM
    CovidDeaths cd
INNER JOIN (
    SELECT 
        location,
        MAX(CAST(people_fully_vaccinated AS bigint)) AS people_fully_vaccinated
    FROM 
        CovidVaccinations
    WHERE
        continent IS NOT NULL
        AND TRIM(continent) != ''
    GROUP BY 
        location
) cv_subquery ON cd.location = cv_subquery.location
WHERE
    CAST(cd.population AS bigint) > 0
GROUP BY
    cd.location
ORDER BY
    vaccinated_pct DESC;





-- Total Percentage of vaccinated people and the continents' population
SELECT 
    cd.location
    ,MAX(CAST(cv_subquery.people_fully_vaccinated AS bigint)) AS people_fully_vaccinated
    ,MAX(CAST(cd.population AS bigint)) AS total_population
    ,CAST(
        ROUND(
            (MAX(CAST(cv_subquery.people_fully_vaccinated AS bigint)) * 100.0) / MAX(CAST(cd.population AS bigint)),
            2
        ) 
        AS FLOAT
    ) AS vaccinated_pct
FROM
    CovidDeaths cd
INNER JOIN (
    SELECT 
        location,
        MAX(CAST(people_fully_vaccinated AS bigint)) AS people_fully_vaccinated
    FROM 
        CovidVaccinations
    WHERE
        continent= ' '
    GROUP BY 
        location
) cv_subquery ON cd.location = cv_subquery.location
WHERE
    CAST(cd.population AS bigint) > 0
GROUP BY
    cd.location
ORDER BY
    vaccinated_pct DESC;