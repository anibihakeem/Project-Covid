select *
from PortfolioProject..CovidDeaths
where continent is not null
order by 3,4

select *
from PortfolioProject..CovidVaccinations
order by 3,4

-- Focused Data
Select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
order by 1,2

-- Total cases vs Total deaths
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)* 100 as DeathPercentage
from PortfolioProject..CovidDeaths
where location = 'Nigeria'
order by 1,2

-- Total cases vs Population
Select location, date, total_cases, Population, (total_cases/Population)* 100 as PercentInfected
from PortfolioProject..CovidDeaths
where location = 'Nigeria'
order by 1,2

-- Countries with highest infection rate
Select Population, location, max(total_cases)HighestInfectedCount, max((total_cases/Population))* 100 as PercentInfected
from PortfolioProject..CovidDeaths
group by Population, location
order by PercentInfected desc;

-- Countries with the highest death count per popuplation
Select location, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
group by location
order by TotalDeathCount desc;

-- Continents with the highest death count per popuplation
Select continent, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount desc;


-- Global rate of death

select sum(new_cases) total_cases,sum(cast(new_deaths as int)) total_deaths,sum(cast(new_deaths as int))/sum(new_cases) *100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null

-- Global rate of death per day

select date, sum(new_cases) total_cases,sum(cast(new_deaths as int)) total_deaths,sum(cast(new_deaths as int))/sum(new_cases) *100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
group by date
order by 1,2

-- Total population vs vaccination

select dt.continent,dt.location, dt.date, dt.population, vt.new_vaccinations
from PortfolioProject..CovidDeaths dt
join PortfolioProject..CovidVaccinations vt
on dt.location = vt.location and dt.date = vt.date
where dt.continent is not null
order by 2,3

-- 
select dt.continent,dt.location, dt.date, dt.population, vt.new_vaccinations, 
sum(cast(vt.new_vaccinations as int)) OVER (Partition by dt.location order by dt.location, dt.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dt
join PortfolioProject..CovidVaccinations vt
on dt.location = vt.location and dt.date = vt.date
where dt.continent is not null
order by 2,3;

-- Using Common Table Expression (CTE) to get the RollingPeopleVaccinated per population

with pop -- (continent,location,date,population,new_vaccinations,RollingPeopleVaccinated)
as (select dt.continent,dt.location, dt.date, dt.population, vt.new_vaccinations, 
sum(cast(vt.new_vaccinations as int)) OVER (Partition by dt.location order by dt.location, dt.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dt
join PortfolioProject..CovidVaccinations vt
on dt.location = vt.location and dt.date = vt.date
where dt.continent is not null
-- order by 2,3 
)
select *,(RollingPeopleVaccinated/population) * 100
from pop

-- OR using a temp table
Drop Table if exists #populate
create table populate
(continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric)

insert into populate
select dt.continent,dt.location, dt.date, dt.population, vt.new_vaccinations, 
sum(cast(vt.new_vaccinations as int)) OVER (Partition by dt.location order by dt.location, dt.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dt
join PortfolioProject..CovidVaccinations vt
on dt.location = vt.location and dt.date = vt.date
where dt.continent is not null

-- Creation of view
create view PercentPopulationVaccinated as
select dt.continent,dt.location, dt.date, dt.population, vt.new_vaccinations, 
sum(cast(vt.new_vaccinations as int)) OVER (Partition by dt.location order by dt.location, dt.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dt
join PortfolioProject..CovidVaccinations vt
on dt.location = vt.location and dt.date = vt.date
where dt.continent is not null

