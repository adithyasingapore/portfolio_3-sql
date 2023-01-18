/*
COVID-19 Analysis with SQL

Dataset: "Coronavirus Pandemic (COVID-19)"
Licence: CC-BY-4.0
Published online at https://ourworldindata.org/covid-deaths

Citation and thanks to authors and contributors to the dataset:
Edouard Mathieu, Hannah Ritchie, Lucas Rodés-Guirao, Cameron Appel, Charlie Giattino,
Joe Hasell, Bobbie Macdonald, Saloni Dattani, Diana Beltekian, Esteban Ortiz-Ospina
and Max Roser (2020)

The dataset has been downloaded and split into two CSVs, imported as two tables:
covid_deaths and covid_vaccinations. This has been done to allow me to demonstrate JOINS.
*/



-- Initial query for the covid_deaths table
SELECT * FROM covid_deaths
	ORDER BY location, date;

-- Initial query for the covid_vaccinations table
SELECT * FROM covid_vaccinations
	ORDER BY location, date;



-- Summary data overview of the covid_deaths table
SELECT location, date, total_cases, new_cases, total_deaths, population
	FROM covid_deaths
    ORDER BY location, date;



-- Calculating death percentage from total_cases and total_deaths
-- Shows likelihood of death if a person contracts COVID-19 in each particular country.
SELECT location, date, total_cases, CAST(total_deaths as decimal) AS total_deaths, (total_deaths/total_cases)*100 AS death_percentage
	FROM covid_deaths
    ORDER BY location, date;
/* NOTE:
SQL imported the total_deaths column as "varchar" date type, which is not numeric.
This is why I have CAST the data type into a numeric data type, in order to calculate.
Also, for some reason, data types 'numeric', 'int' and 'bigint' gave errors.
So I have used 'decimal' data type instead. The results are still whole numbers. */



-- Calculating infection percentage from total_cases and population
-- Shows spread of COVID-19 (number of cases) amongst the population of India
-- Changing the WHERE clause location to a different country will give the infection percentage for that country.
SELECT location, date, population, total_cases, (total_cases/population)*100 AS infection_percentage
	FROM covid_deaths
    WHERE location = 'India'
    ORDER BY location, date;
/* NOTE:
If you run my scripts and encounter any numeric columns not calculated properly,
e.g. when ORDER BY descending, 997 appears before 8240, this is because SQL has imported
it as "varchar" and is ordering variable characters 9 before 8, instead of numeric size.
This is due to auto-assigning of column data types by SQL when importing the CSV data.
So, please use the CAST function to cast it into a numeric column wherever needed.*/



-- Listing countries by highest infection rate amongst population
SELECT location, population, MAX(total_cases) AS highest_infection_count, MAX((total_cases/population))*100 AS infection_percentage
	FROM covid_deaths
    GROUP BY location, population
    ORDER BY infection_percentage DESC;



-- Listing countries by highest number of deaths amongst population
SELECT location, continent, population, MAX(CAST(total_deaths AS decimal)) AS total_death_count
	FROM covid_deaths
    WHERE continent != ""
    GROUP BY location, population
    ORDER BY total_death_count DESC;
/* NOTE:
Aggregate figures for "World", "Europe" etc. have been included in our dataset.
So when we order by descending, these large figures appear at the top.
We only want countries' figures, so we can exclude these global/continental figures.
e.g. "North America" is listed under 'location', its 'continent' is empty but not NULL.
So we add WHERE continent != (not equal to) "" (empty) to exclude these aggregate figures.
If it was NULL instead of empty, we would use WHERE continent IS NOT NULL.
*/


-- Now, we let's analyse by continent
-- Listing the continents by highest death count
SELECT location, MAX(CAST(total_deaths AS decimal)) AS total_death_count
	FROM covid_deaths
    WHERE continent = ""
    AND location NOT IN ('World', 'European Union', 'International')
    GROUP BY location
    ORDER BY total_death_count DESC;
/* NOTE:
We are now using WHERE continent = "" (is equal to empty). The '!' before '=' is removed.
This will provide us the aggregate continental and world figures.
We exclude 'World' and 'International' as they are not continents.
We also exclude 'European Union' (EU) as the EU is a part of 'Europe'. */



-- Global new cases, new deaths and death percentage for every date worldwide
SELECT date, SUM(new_cases) AS global_cases, SUM(new_deaths) AS global_deaths, (SUM(new_deaths)/SUM(new_cases))*100 AS global_death_percentage
	FROM covid_deaths
    WHERE continent != ""
    GROUP BY date
    ORDER BY date;



-- Total cumulative cases and deaths recorded worldwide till end of dataset date
SELECT SUM(new_cases) AS global_cases, SUM(new_deaths) AS global_deaths, (SUM(new_deaths)/SUM(new_cases))*100 AS global_death_percentage
	FROM covid_deaths
    WHERE continent != "";



-- Joining the covid_deaths and covid_vaccinations tables
-- Aliases 'dea' and 'vac' for easy referencing (don't have to type full table name every time).
SELECT *
	FROM covid_deaths dea
    JOIN covid_vaccinations vac
		ON dea.location = vac.location
        AND dea.date = vac.date;



-- Listing each country's new vaccinations and rolling sum of vaccinations on each date
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
			SUM(CAST(vac.new_vaccinations AS float)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_sum_vaccinations
	FROM covid_deaths dea
    JOIN covid_vaccinations vac
		ON dea.location = vac.location
        AND dea.date = vac.date
	WHERE dea.continent != ""
    ORDER BY dea.location, dea.date;



-- Listing new vaccinations, rolling sum of vaccinations and percentage of population vaccinated on each date
WITH population_vaccinated (continent, location, date, population, new_vaccinations, rolling_sum_vaccinations)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
			SUM(CAST(vac.new_vaccinations AS float)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_sum_vaccinations
	FROM covid_deaths dea
    JOIN covid_vaccinations vac
		ON dea.location = vac.location
        AND dea.date = vac.date
	WHERE dea.continent != ""
    ORDER BY dea.location, dea.date
)
SELECT *, (rolling_sum_vaccinations/population)*100 AS percentage_vaccinated
	FROM population_vaccinated;



-- Creating a temp table for percentage of population vaccinated

DROP TABLE IF EXISTS coviddeaths.percentage_population_vaccinated;

CREATE TABLE coviddeaths.percentage_population_vaccinated (
	continent varchar(255),
	location varchar(255),
	date datetime,
	population numeric,
	new_vaccinations numeric,
	rolling_sum_vaccinations numeric
);

INSERT INTO coviddeaths.percentage_population_vaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
			SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_sum_vaccinations
	FROM covid_deaths dea
    JOIN covid_vaccinations vac
		ON dea.location = vac.location
        AND dea.date = vac.date
	WHERE dea.continent != ""
    ORDER BY dea.location, dea.date;

SELECT *, (rolling_sum_vaccinations/population)*100 AS percentage_vaccinated
	FROM coviddeaths.percentage_population_vaccinated;



-- Sample of a VIEW created to store data for later visualization using Tableau
CREATE VIEW view_population_vaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
			SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_sum_vaccinations
	FROM covid_deaths dea
    JOIN covid_vaccinations vac
		ON dea.location = vac.location
        AND dea.date = vac.date
	WHERE dea.continent != "";

SELECT * FROM view_population_vaccinated;
