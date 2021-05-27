Select *
From PortfolioProject..CovidDeaths$
Where continent is not null
order by 3,4
--Select *
--From PortfolioProject..CovidVaccination$
--order by 3,4
--Select data which we will use
Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths$
order by 1,2

--Looking at total cases vs total deaths
--shows likelihood of dying if you contract covid in your country
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths$
Where location like '%India%'
order by 1,2

--Looking at Total cases vs Population
--Shows what percentage of population got covid
Select location, date, population, total_cases,  (total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths$
--Where location like '%India%'
order by 1,2

--Looking at countries with highest infection rate compared t population
Select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths$
--Where location like '%India%'
Group by location, population
order by PercentPopulationInfected desc

--Showing countries with highest death count per population
Select location,  MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths$
--Where location like '%India%'
Where continent is not null
Group by location
order by TotalDeathCount desc

--Lets break things down by continent 
Select location,  MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths$
--Where location like '%India%'
Where continent is null
Group by location
order by TotalDeathCount desc
--OR
--Showing continents with the highestd deathcounts

Select continent,  MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths$
--Where location like '%India%'
Where continent is not null
Group by continent
order by TotalDeathCount desc

--Global numbers
Select date, Sum(new_cases)as total_cases, sum(cast(new_deaths as Int)) as total_deaths, Sum(cast(new_deaths as Int))/sum(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths$
Where continent is not null
group by date
order by 1,2

--Total cases all over the world:

Select Sum(new_cases)as total_cases, sum(cast(new_deaths as Int)) as total_deaths, Sum(cast(new_deaths as Int))/sum(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths$
Where continent is not null
--group by date
order by 1,2

--Looking at total population vs vaccinations
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/Population)*100

From PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccination$ vac
on dea.location=vac.location 
and dea.date=vac.date 
where dea.continent is not null
order by 2,3

--USE CTE
with PopvsVac (continent, location, date, population,new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/Population)*100

From PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccination$ vac
on dea.location=vac.location 
and dea.date=vac.date 
where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/population)*100
from popvsVac



--TEMP Table
DROP Table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/Population)*100

From PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccination$ vac
on dea.location=vac.location 
and dea.date=vac.date 
--where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated


--creating view to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/Population)*100

From PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccination$ vac
on dea.location=vac.location 
and dea.date=vac.date 
--where dea.continent is not null
--order by 2,3

Select*
From PercentPopulationVaccinated