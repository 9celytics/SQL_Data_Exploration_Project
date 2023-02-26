select *
from dbo.CovidVaccination

select *
from dbo.CovidDeaths

-- selecting data for exploration
select location, date, total_cases, new_cases, total_deaths, population
from dbo.CovidDeaths
where continent is not null
order by 1,2

-- The Total cases versus the total deaths = death_rate
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_rate
from dbo.CovidDeaths
where continent is not null
order by 1,2

-- The death_rate in China
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_rate
from dbo.CovidDeaths
where location = 'China' and continent is not null
order by 1,2

-- The death_rate in the United States
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_rate
from dbo.CovidDeaths
where location like '%States%' and continent is not null
order by 1,2

-- The Population versus the total cases
-- percentage of those who got covid
select location, date, population, total_cases, (total_cases/population)*100 as Total_case_rate
from dbo.CovidDeaths
where continent is not null
order by 1,2

-- The Population versus the total cases
-- percentage of those who got covid in the United States
select location, date, population, total_cases, (total_cases/population)*100 as Total_case_rate
from dbo.CovidDeaths
where location like '%States%' and continent is not null
order by 1,2

-- Countries with highest Infection Rate Compared to Population
select location, population,max(total_cases) as highestInfectionCount, max((total_cases/population))*100 as TotalpopulationInfected
from dbo.CovidDeaths
where continent is not null
group by location, population
order by TotalpopulationInfected desc

-- Countries with highest Death count per population
select location, max(total_deaths) as TotalDeathCount
from dbo.CovidDeaths
where continent is not null
group by location
order by TotalDeathCount desc

-- converting the total deaths to interger and adding where continent is not null
select location, max(cast(total_deaths as int)) as TotalDeathCount
from dbo.CovidDeaths
where continent is not null
group by location
order by TotalDeathCount desc

-- Looking at this as a continent
-- Continents with highest death counts per population
select continent, max(cast(total_deaths as int)) as TotalDeathCount
from dbo.CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount desc



--GLOBAL NUMBERS
-- TOTAL NEW CASES EVERYDAY ACCROSS THE WORLD
select date, sum(new_cases)
from dbo.CovidDeaths
where continent is not null
group by date
order by 1,2

-- TOTAL NEW CASES AND DEATHS EVERYDAY ACCROSS THE WORLD
select date, sum(new_cases) as TotalNewCases, sum(cast(new_deaths as int)) as TotalNewDeath
from dbo.CovidDeaths
where continent is not null
group by date
order by 1,2

-- DEATH PERCENTAGE ACCROSS THE WORLD EVERYDAY
select date, sum(new_cases) as TotalNewCases, sum(cast(new_deaths as int)) as TotalNewDeath, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from dbo.CovidDeaths
where continent is not null
group by date
order by 1,2


-- DEATH PERCENTAGE ACCROSS THE WORLD
select sum(new_cases) as TotalNewCases, sum(cast(new_deaths as int)) as TotalNewDeath, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from dbo.CovidDeaths
where continent is not null
order by 1,2




--JOINING THE TWO TABLES 
select *
from dbo.CovidDeaths dea
join dbo.CovidVaccination vac
on dea.location = vac.location
and dea.date = vac.date


-- TOTAL POPULATION VERSUS VACCINATION
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
from dbo.CovidDeaths dea
join dbo.CovidVaccination vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- TOTAL POPULATION VERSUS VACCINATION IN CHINA
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
from dbo.CovidDeaths dea
join dbo.CovidVaccination vac
on dea.location = vac.location
and dea.date = vac.date
where dea.location = 'China' and dea.continent is not null
order by 2,3  


-- -- TOTAL POPULATION VERSUS VACCINATION 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
from dbo.CovidDeaths dea
join dbo.CovidVaccination vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3  

--- USING PARTITION BY
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from dbo.CovidDeaths dea
join dbo.CovidVaccination vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3  

--USING CTE
WITH popvsvac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from dbo.CovidDeaths dea
join dbo.CovidVaccination vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3  
)
select*
from popvsvac

--USING CTE to find the total percentage vaccinated 
WITH popvsvac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from dbo.CovidDeaths dea
join dbo.CovidVaccination vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3  
)
select*, (RollingPeopleVaccinated/population)*100
from popvsvac


--- CREATING VIEW TO STORE DATA FOR VISUALIZATION LATER
--- 1
create view PopulationversusVaccination as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from dbo.CovidDeaths dea
join dbo.CovidVaccination vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3 

--- CREATING VIEW TO STORE DATA FOR VISUALIZATION LATER
--- 2
create view DeathPercentage as
select sum(new_cases) as TotalNewCases, sum(cast(new_deaths as int)) as TotalNewDeath, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from dbo.CovidDeaths
where continent is not null
--order by 1,2

--- CREATING VIEW TO STORE DATA FOR VISUALIZATION LATER
--- 3
create view TotalDeathCount as
select continent, max(cast(total_deaths as int)) as TotalDeathCount
from dbo.CovidDeaths
where continent is not null
group by continent
--order by TotalDeathCount desc