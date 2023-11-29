SELECT *
FROM PortfolioProject.dbo.CovidDeaths
ORDER BY 3,4;

/* SELECT *
FROM PortfolioProject.dbo.CovidVaccinations
ORDER BY 3,4; */


SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject.dbo.CovidDeaths
ORDER BY 1,2;


-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
Where location = 'Georgia'
ORDER BY 1,2;

-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid

SELECT location, date, population, total_cases, (total_cases/population)*100 AS PercentPopulationInfected
FROM PortfolioProject.dbo.CovidDeaths
-- Where location = 'Georgia'
ORDER BY 1,2;


-- Looking at countries with highers infection rate compared to population

SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM PortfolioProject.dbo.CovidDeaths
-- Where location = 'Georgia'
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC;


-- Showing the countries with the highest death count per population

SELECT location, MAX(cast(total_deaths AS int)) AS TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths
-- Where location = 'Georgia'
WHERE continent is not NULL
GROUP BY location
ORDER BY TotalDeathCount DESC;


-- Let's break things down by CONTINENT


/* SELECT location, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths
-- Where location = 'Georgia'
WHERE continent is NULL
GROUP BY location
ORDER BY TotalDeathCount DESC; */

-- Showing continents with the highest death count per population

SELECT continent, MAX(cast(total_deaths AS int)) AS TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths
-- Where location = 'Georgia'
WHERE continent is not NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC;


-- GLOBAL NUMBER

SELECT  date, SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths, 
        CAST(SUM(new_deaths) AS decimal (18, 2)) / CAST(SUM(new_cases) AS decimal (18, 2))* 100 AS DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
-- Where location = 'Georgia'
WHERE continent is not NULL
GROUP BY date
ORDER BY 1,2;

SELECT  SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths, 
        CAST(SUM(new_deaths) AS decimal (18, 2)) / CAST(SUM(new_cases) AS decimal (18, 2))* 100 AS DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
-- Where location = 'Georgia'
WHERE continent is not NULL
ORDER BY 1,2;


-- Looking at Total Population vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
        SUM(CAST(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
        -- (RollingPeopleVaccinated/population) *  100
FROM PortfolioProject.dbo.CovidDeaths dea
JOIN PortfolioProject.dbo.CovidVaccinations vac 
    ON dea.location = vac.location
    AND dea.date  = vac.date
WHERE dea.continent is not NULL
ORDER BY 2,3;


-- USE CTE

WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
        SUM(CAST(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject.dbo.CovidDeaths dea
JOIN PortfolioProject.dbo.CovidVaccinations vac 
    ON dea.location = vac.location
    AND dea.date  = vac.date
WHERE dea.continent is not NULL
)

SELECT *, (RollingPeopleVaccinated/population) * 100
FROM PopvsVac;


-- TEMP TABLE


DROP TABLE if EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
    Continent NVARCHAR(255),
    Location NVARCHAR(255),
    Date DATETIME,
    Population NUMERIC,
    New_Vaccinations NUMERIC,
    RollingPeopleVaccinated NUMERIC
)

INSERT INTO #PercentPopulationVaccinated
    SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
            SUM(CAST(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
    FROM PortfolioProject.dbo.CovidDeaths dea
    JOIN PortfolioProject.dbo.CovidVaccinations vac 
        ON dea.location = vac.location
        AND dea.date  = vac.date
    WHERE dea.continent is not NULL

SELECT *, (RollingPeopleVaccinated/population) * 100
FROM #PercentPopulationVaccinated;


-- Creating View to store data for later Visualisations

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
        SUM(CAST(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
        -- (RollingPeopleVaccinated/population) *  100
FROM PortfolioProject.dbo.CovidDeaths dea
JOIN PortfolioProject.dbo.CovidVaccinations vac 
    ON dea.location = vac.location
    AND dea.date  = vac.date
WHERE dea.continent is not NULL;

SELECT *
FROM PercentPopulationVaccinated;