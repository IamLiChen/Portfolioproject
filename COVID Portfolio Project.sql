
SELECT *
FROM PortfolioProject.dbo.CovidDeaths$
WHERE continent is not null
ORDER BY 3,4

--SELECT *
--FROM PortfolioProject.dbo.CovidVaccinations$
--ORDER BY 3,4


-- Select Data that we are going to be using


SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject.dbo.CovidDeaths$
WHERE continent is not null
ORDER BY 1,2


--looking at Total Cases vs Toal Deaths

SELECT Location, date, total_cases, total_deaths, (Total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths$
WHERE Location = 'China'
ORDER BY 1,2


SELECT Location, date, total_cases, total_deaths, (Total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths$
WHERE Location like '%state%'
and continent is not null
ORDER BY 1,2


--Lookinga at Total cases vs Population
-- Shows what percentage of population got Covid

SELECT Location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
FROM PortfolioProject.dbo.CovidDeaths$
WHERE Location like '%state%'
ORDER BY 1,2



-- Looking at Countries with Highest Infection Rate compared to Population


SELECT Location, population, MAX(total_cases) AS HighestInfectionCount, Max((total_cases/population))*100 as PercentPopulationInfected
FROM PortfolioProject.dbo.CovidDeaths$
--WHERE Location like '%state%'
GROUP BY Location, Population
ORDER BY PercentPopulationInfected desc



-- Showing Countries with Highes Death Count per Population

SELECT Location, MAX( CAST (Total_deaths as INT)) AS TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths$
WHERE continent is not null
GROUP BY Location 
ORDER BY TotalDeathCount DESC


-- Let's Break Things down by Continent

-- Showing contintents with the highest death count per population

SELECT continent, MAX( CAST (Total_deaths as INT)) AS TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths$
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC


--GLOBAL NUMBERS

SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths AS INT)) as total_deaths, SUM(cast(new_deaths AS INT))/SUM(New_cases)*100 as DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths$
--WHERE Location like '%state%'
WHERE continent is not null
--GROUP BY date
ORDER BY 1,2



--Looking at Total population vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) AS RollingPeopleVaccinated--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject.dbo.CovidDeaths$ AS dea
JOIN PortfolioProject.dbo.CovidVaccinations$ AS vac
	ON dea.location=vac.location
	and dea.date=vac.date
WHERE dea.continent is not null
ORDER BY 2,3



-- Use Cte

with PopvsVac (Continent, location, date, population, New_Vaccination, RollingPeopleVaccinated)
as

(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, 
dea.date) AS RollingPeopleVaccinated--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject.dbo.CovidDeaths$ AS dea
JOIN PortfolioProject.dbo.CovidVaccinations$ AS vac
	ON dea.location=vac.location
	and dea.date=vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
)

SELECT *, (RollingPeopleVaccinated/population)*100
FROM PopvsVac



--Temp Table

DROP TABLE if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
	Continent nvarchar(255),
	Location nvarchar(255),
	Date datetime,
	Population numeric,
	New_vacccinations numeric,
	RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, 
dea.date) AS RollingPeopleVaccinated--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject.dbo.CovidDeaths$ AS dea
JOIN PortfolioProject.dbo.CovidVaccinations$ AS vac
	ON dea.location=vac.location
	and dea.date=vac.date
WHERE dea.continent is not null
--ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated



--Create view to store data for later visualizations

CREATE view PercentPopulationVaccinated as 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, 
dea.date) AS RollingPeopleVaccinated--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject.dbo.CovidDeaths$ AS dea
JOIN PortfolioProject.dbo.CovidVaccinations$ AS vac
	ON dea.location=vac.location
	and dea.date=vac.date
WHERE dea.continent is not null
--ORDER BY 2,3


SELECT *
FROM PercentPopulationVaccinated;