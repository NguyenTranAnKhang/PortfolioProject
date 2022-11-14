-- Select Data that we are going to be using
SELECT * 
FROM CovidDeaths
ORDER BY 3,4

SELECT * 
FROM CovidVaccinations
ORDER BY 3,4

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in Vietnam
SELECT Location, Date, Total_cases, Total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
WHERE Location = 'Vietnam'
ORDER BY 1,2

-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid
SELECT Location, Date, Total_cases, Population, (total_cases/population)*100 as InfectedPercentageP
FROM PortfolioProject.dbo.CovidDeaths
WHERE Location = 'Vietnam'
ORDER BY 1,2

-- Looking at Countries with Highest Infection Rate compared to Population
SELECT Location, Population, MAX(total_cases) as HighestICount,  MAX((total_cases/population))*100 as InfectedPercentageP
FROM PortfolioProject.dbo.CovidDeaths
GROUP BY Location, Population 
ORDER BY InfectedPercentageP DESC
-- *Population has not changed during this time

-- Showing Countries with Highest Death Count per Population
SELECT Location, MAX(CAST(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent is not NULL
GROUP BY Location
ORDER BY TotalDeathCount DESC
-- *Total_death is nvarchar
-- *Having aggregated data by Continent, Income,...

-- Showing Aggregated Data with Highest Death Count per Population
SELECT location, MAX(CAST(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent is NULL
GROUP BY location
ORDER BY TotalDeathCount DESC


-- GLOBAL NUMBERS


-- Total number of new cases, new deaths in each day 
SELECT Date, SUM(new_cases) as NewCases, SUM(CAST(new_deaths as int)) as NewDeaths, SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent is not NULL
GROUP BY date
ORDER BY 1

-- Total number of cases and deaths recorded
SELECT  SUM(new_cases) as TotalCases, SUM(CAST(new_deaths as int)) as TotalDeaths
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent is not NULL
ORDER BY 1


------------------------------------------------------


-- Looking at Total Population vs Vaccinations in each country
SELECT dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.Date)
		AS RoolingPeopleVaccinated
FROM PortfolioProject.dbo.CovidDeaths dea
JOIN PortfolioProject.dbo.CovidVaccinations vac
	ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent is not NULL 
ORDER BY 1,2,4

-- Showing Total number of people Vaccinated

-- * Using CTE 
WITH PopvsVac ( Location, Date, Population, NewVaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.Date)
		AS RoolingPeopleVaccinated
FROM PortfolioProject.dbo.CovidDeaths dea
JOIN PortfolioProject.dbo.CovidVaccinations vac
	ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent is not NULL
)
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac

-- * Using TEMP TABLE
DROP TABLE if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
INSERT INTO #PercentPopulationVaccinated
SELECT dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.Date)
		AS RoolingPeopleVaccinated
FROM PortfolioProject.dbo.CovidDeaths dea
JOIN PortfolioProject.dbo.CovidVaccinations vac
	ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent is not NULL

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated


--------------------------------

 
 -- Creating View to store data for later visualizations
CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.Date)
		AS RoolingPeopleVaccinated
FROM PortfolioProject.dbo.CovidDeaths dea
JOIN PortfolioProject.dbo.CovidVaccinations vac
	ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent is not NULL 

CREATE VIEW News AS
SELECT SUM(new_cases) as TotalCases, SUM(CAST(new_deaths as int)) as TotalDeaths, SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent is not NULL
--GROUP BY date
ORDER BY 1,2

CREATE VIEW TotalDeath AS
SELECT Location, SUM(CAST(new_deaths as int)) as TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent is NULL and location not in ('World', 'European Union', 'International','Low income', 'Lower middle income', 'High income', 'Upper middle income')
GROUP BY Location
ORDER BY TotalDeathCount DESC

CREATE VIEW HICvsIPP  AS
SELECT Location, Population, MAX(total_cases) as HighestICount,  MAX((total_cases/population))*100 as InfectedPercentageP
FROM PortfolioProject.dbo.CovidDeaths
GROUP BY Location, Population
ORDER BY 4 DESC

CREATE VIEW HICvsIPPperday AS
SELECT Location, Population, Date, MAX(total_cases) as HighestICount, MAX((total_cases/population))*100 as InfectedPercentageP
FROM PortfolioProject.dbo.CovidDeaths
GROUP BY Location, Population, Date