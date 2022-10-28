
Select *
From PorfolioProject..CovidDeaths
Where continent is not null
order by 3,4

--Select *
--From PorfolioProject..CovidVaccinations
--order by 3,4

Select Location, date, total_cases, new_cases, total_deaths, population, (total_deaths/total_cases)*100 as DeathPercentage
From PorfolioProject..CovidDeaths
order by 1,2

--Looking at total case vs total deaths
--Shows the likeihood of dying if you catch covid in your country
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PorfolioProject..CovidDeaths
Where location like '%states%'
order by 1,2

--Look at total cases vs population
--Shows what percentage of population got covid
Select Location, date, Population, total_cases, (total_cases/population)*100 as PercentOfPopulationInfected
From PorfolioProject..CovidDeaths
--Where location like '%states%'
order by 1,2

--Looking at countries with Highest Infection Rate compared to Population
Select Location, Population, MAX(total_cases)as HighInfectionCount, MAX((total_cases/population))*100 as PercentOfPopulationInfected
From PorfolioProject..CovidDeaths
--Where location like '%states%'
Group by Location, Population
order by PercentOfPopulationInfected desc

--Showing Countries with Highest Death Count per Population
Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PorfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is not null
Group by Location
order by TotalDeathCount desc

--Break down by Location
Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PorfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is not null
Group by location
order by TotalDeathCount desc

--Break down by Continent
--Showing Continent with highest death count per population
Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PorfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is not null
Group by continent
order by TotalDeathCount desc

--Global Numbers
Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PorfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is not null
Group by date
order by 1,2

--Overall across the world total
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PorfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is not null
--Group by date
order by 1,2


--Looking at total Population vs Vaccinations
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
From PorfolioProject..CovidDeaths dea
Join PorfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
order by 2,3

--Total Population vs Vaccinations by location
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated--, (RollingPeopleVaccinated/population)*100
From PorfolioProject..CovidDeaths dea
Join PorfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
order by 2,3

--Use CTE
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated--, (RollingPeopleVaccinated/population)*100
From PorfolioProject..CovidDeaths dea
Join PorfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac


--Temp Table
DROP TABLE if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric,
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated--, (RollingPeopleVaccinated/population)*100
From PorfolioProject..CovidDeaths dea
Join PorfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


--Create View to store data for later visualizations
Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated--, (RollingPeopleVaccinated/population)*100
From PorfolioProject..CovidDeaths dea
Join PorfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by 2,3

Select *
From PercentPopulationVaccinated