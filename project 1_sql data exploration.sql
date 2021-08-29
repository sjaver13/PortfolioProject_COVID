-- following AlexTheAnalyst https://www.youtube.com/watch?v=qfyynHBFOsM
-- this is done on MySQL vs AlexTheAnalyst uses MS SQL Server so there are some variations in the syntax

-- ensure that you start your database
USE portfolio_project_covid;

-- check to make sure the data imported correctly
SELECT * FROM coronavirus_deaths WHERE continent = '' order by 3,4;
SELECT * FROM coronavirus_vacinations order by 3,4;

-- select the data that you are going to use
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM coronavirus_deaths
order by 1, 2;

-- total cases vs total deaths
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM coronavirus_deaths
order by 1, 2;

-- total cases vs total deaths in a specific country, in this case United States
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM coronavirus_deaths
WHERE location like '%states%'
order by 1, 2;

-- total cases vs total deaths in a specific country, in this case Canada
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM coronavirus_deaths
WHERE location like '%canada%'
order by 1, 2;

-- total cases vs total deaths in a specific country, in this case China
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM coronavirus_deaths
WHERE location like '%china%'
order by 1, 2;

-- Total Cases vs Population (Canada)
SELECT location, date, total_cases, population, (total_cases/population)*100 as PercentagePopulationInfected
FROM coronavirus_deaths
WHERE location like '%canada%'
order by 1, 2;

-- countries with highest infection rate compared to population
SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentagePopulationInfected
FROM coronavirus_deaths
GROUP BY location, population
order by PercentagePopulationInfected desc;

-- Countries with Highest Death Count per Population
SELECT location, MAX(CAST(total_deaths as UNSIGNED)) as TotalDeathCount
FROM coronavirus_deaths
WHERE continent is not null or ' '
GROUP BY location
order by TotalDeathCount desc;

-- Highest Death Count per Population by continent
SELECT continent, MAX(CAST(total_deaths as UNSIGNED)) as TotalDeathCount
FROM coronavirus_deaths
WHERE continent is not null or continent = ''
GROUP BY continent
order by TotalDeathCount desc;

SELECT location, MAX(CAST(total_deaths as UNSIGNED)) as TotalDeathCount
FROM coronavirus_deaths
WHERE continent is null OR continent = ''
GROUP BY location
order by TotalDeathCount desc;


-- GLOBAL NUMBERS
SELECT date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM coronavirus_deaths
WHERE continent is null OR continent = ''
order by 1, 2;

SELECT date, SUM(new_cases)
FROM coronavirus_deaths
WHERE continent is null OR continent = ''
GROUP BY date
order by 1, 2;

SELECT date, SUM(new_cases), SUM(CAST(new_deaths as UNSIGNED))
FROM coronavirus_deaths
WHERE continent is null OR continent = ''
GROUP BY date
order by 1, 2;

SELECT date, SUM(new_cases) as total_cases, SUM(CAST(new_deaths as UNSIGNED)) as total_deaths, SUM(CAST(new_deaths as UNSIGNED))/SUM(new_cases)*100
FROM coronavirus_deaths
WHERE continent is null OR continent = ''
GROUP BY date
order by 1, 2;

SELECT SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths)/SUM(new_cases)*100
FROM coronavirus_deaths
WHERE continent is null OR continent = ''
order by 1, 2;

-- vacinations table
SELECT * FROM coronavirus_vacinations order by 1.2;

-- join tables
SELECT *
FROM coronavirus_deaths dea
JOIN coronavirus_vacinations vac
ON dea.location = vac.location and dea.date = vac.date;

-- total population vs vacination
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM coronavirus_deaths dea
JOIN coronavirus_vacinations vac
ON dea.location = vac.location and dea.date = vac.date
WHERE dea.continent is not null OR dea.continent = ''
ORDER BY 2,3;

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVacinated
FROM coronavirus_deaths dea
JOIN coronavirus_vacinations vac
ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3;

-- USE CTE Percent Population Vaccinated

WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVacinated
FROM coronavirus_deaths dea
JOIN coronavirus_vacinations vac
ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent is not null
)
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac

-- TEMP TABLE Percent Population Vaccinated

CREATE TEMPORARY TABLE PercentPopulationVaccinated(Continent nvarchar(255), Location nvarchar(255), Date datetime, Population numeric, New_Vaccinations numeric, RollingPeopleVaccinated numeric);
INSERT INTO PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVacinated
FROM coronavirus_deaths dea
JOIN coronavirus_vacinations vac
ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3;
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PercentPopulationVaccinated


-- create view for later visualizations

-- create view percent population vaccinated

CREATE VIEW percentpopvaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVacinated
FROM coronavirus_deaths dea
JOIN coronavirus_vacinations vac
ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent is not null;

-- create view total cases vs total deaths

CREATE VIEW totalcasesvsdeaths AS
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM coronavirus_deaths

-- create view total cases vs total death specific countires (USA and Canada)

CREATE VIEW totalcasesvsdeathsusa AS
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM coronavirus_deaths
WHERE location like '%states%'


CREATE VIEW totalcasesvsdeathcan AS
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM coronavirus_deaths
WHERE location like '%canada%'

-- create view countries with highest infection rate compared to population

CREATE VIEW highestinfectinvspop AS
SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentagePopulationInfected
FROM coronavirus_deaths
GROUP BY location, population
order by PercentagePopulationInfected desc;

-- create view Countries with Highest Death Count per Population

CREATE VIEW highestdeathperpop AS
SELECT location, MAX(CAST(total_deaths as UNSIGNED)) as TotalDeathCount
FROM coronavirus_deaths
WHERE continent is not null or ' '
GROUP BY location
order by TotalDeathCount desc;

-- create view Highest Death Count per Population by continent

CREATE VIEW highestdeathperpopcontinent AS
SELECT continent, MAX(CAST(total_deaths as UNSIGNED)) as TotalDeathCount
FROM coronavirus_deaths
WHERE continent is not null or continent = ''
GROUP BY continent
order by TotalDeathCount desc;



