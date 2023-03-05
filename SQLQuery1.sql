-- The WHERE is there so we won't get continents as location, we want only countries
SELECT *
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent is not null
ORDER BY 3,4

SELECT *
FROM PortfolioProject.dbo.CovidVaccinations
WHERE continent is not null
ORDER BY 3,4

-- Select the data that we are going to use

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent is not null
ORDER BY 1,2

-- Total Cases vs Total Deaths
-- Can give an estimation of dying in case you got COVID19 in Israel
SELECT location, date, total_cases, new_cases, total_deaths, population, (total_deaths/total_cases)*100 as 'DeathPercentage'
FROM PortfolioProject.dbo.CovidDeaths
WHERE location = 'Israel'
ORDER BY 1,2

-- Total Cases vs Population
-- Getting the Percentage of population who had COVID19
SELECT location, date, new_cases, total_deaths, total_cases, population, (total_cases/population)*100 as 'CasesPercentage'
FROM PortfolioProject.dbo.CovidDeaths
WHERE location = 'Israel'
ORDER BY 1,2

-- Looking at Countries with Highest Infection Rate compared to population
SELECT location, MAX(total_cases) as 'HighestInfectionRate', population, MAX((total_cases/population)*100) as 'CasesPercentage'
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent is not null
GROUP BY location, population
ORDER BY 4 DESC

-- Showing countries with Highest Death Count per Population
SELECT location, MAX(CAST(total_deaths as int)) as 'TotalDeaths', population, (MAX(total_deaths)/population)*100 as 'DeathPercentage'
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent is not null
GROUP BY location, population
ORDER BY 2 DESC

-- CONTINENT instead of countries
-- Showing the continents with the highest DeathCount
SELECT continent, SUM(TotalDeaths) as 'TotalDeaths'
FROM (SELECT location, MAX(CAST(total_deaths as int)) as 'TotalDeaths', continent
		FROM PortfolioProject.dbo.CovidDeaths
		WHERE continent is not null
		GROUP BY location, population, continent) as D
GROUP BY continent
ORDER BY 2 DESC

-- The same as previous query, just using the Data's aggregation that was already made
SELECT location, MAX(CAST(total_deaths as int)) as 'TotalDeaths'
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent is null
GROUP BY location
ORDER BY 2 DESC

-- Global Numbers ??????????
SELECT date, SUM(new_cases) as TotalCases, SUM(CAST(new_deaths as int)) as TotalDeaths,
	(SUM(CAST(new_deaths as int))/SUM(new_cases))*100 as DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent is not null
GROUP BY date
ORDER BY 1 ASC

-- total population vs vaccinations
WITH PvsV (continent, location, date, population, new_vaccinations, TotalVaccinations)
as
(
SELECT d.continent, d.location, d.date, population, new_vaccinations,
	SUM(CAST(v.new_vaccinations as bigint)) OVER (PARTITION BY d.location ORDER BY d.location, d.date) as TotalVaccinations
FROM PortfolioProject.dbo.CovidDeaths D
JOIN PortfolioProject.dbo.CovidVaccinations V
	ON d.location = v.location AND d.date = v.date
WHERE d.continent is not null
)
SELECT *, (TotalVaccinations/population)*100 as VaccinationsPercentage
FROM PvsV
ORDER BY 2, 3

-- Creating view to store data later for tableau
CREATE VIEW PercentagePopulationVaccinated as
SELECT d.continent, d.location, d.date, population, new_vaccinations,
	SUM(CAST(v.new_vaccinations as bigint)) OVER (PARTITION BY d.location ORDER BY d.location, d.date) as TotalVaccinations
FROM PortfolioProject.dbo.CovidDeaths D
JOIN PortfolioProject.dbo.CovidVaccinations V
	ON d.location = v.location AND d.date = v.date
WHERE d.continent is not null
