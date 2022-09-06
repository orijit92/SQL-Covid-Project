
select location, date, total_cases, new_cases, total_deaths, population from [Portfolio Project].dbo.[Portfolio Project].dbo.[Covid Deaths]
order by 1,2


--Looking at total cases vs total deaths
-- Shows likelihood of dying if you contract covid in your country
select location, date, total_cases, total_deaths, round ((total_deaths/total_cases)*100,2) as DeathPercentage 
from [Portfolio Project].[Portfolio Project].dbo.[Portfolio Project].dbo.[Covid Deaths] where location like '%states%'
order by 1,2
-- As of March 2022, there is a 1.22% chance of dying if you contract covid in the United States

--Looking at total cases vs population

select location, date, total_cases, population, (total_cases/population)*100 as InfectionRate 
from [Portfolio Project].dbo.[Covid Deaths]
where location like '%states%'

--Looking at Countries with highest infection rate

select location, population,max(total_cases) as HighestInfectionCount, max((total_cases/population)*100) as HighestInfectionRate
from [Portfolio Project].dbo.[Covid Deaths]
group by location, population
order by 4 desc

--Looking at Countries with highest death rate

select location, population, max(cast (total_deaths as int)) as TotalDeathCount, max((total_deaths/population)*100) as MaxDeathRate
from [Portfolio Project].dbo.[Covid Deaths]
group by location, population
order by 3 desc


--Seeing places like world, income batches and continents which is not what we want

select * from [Portfolio Project].dbo.[Covid Deaths] where continent is null

-- we can see that continent is null where location is that of a continent. hence, we filter on continent where it is not null

select location, population, max(cast (total_deaths as int)) as TotalDeathCount, max((total_deaths/population)*100) as MaxDeathRate
from [Portfolio Project].dbo.[Covid Deaths]
where continent is not null
group by location, population
order by 3 desc


-- breaking things down by continent

select location, population, max(cast (total_deaths as int)) as TotalDeathCount, max((total_deaths/population)*100) as MaxDeathRate
from [Portfolio Project].dbo.[Covid Deaths]
where continent is null and location not like '%income%'
group by location, population
order by 3 desc

--There were income levels in location which I had to remove

select * from [Portfolio Project].dbo.[Covid Deaths] where continent is null

--showing continents with the highest death rate

select location, population, max(cast (total_deaths as int)) as TotalDeathCount, max((total_deaths/population)*100) as MaxDeathRate
from [Portfolio Project].dbo.[Covid Deaths]
where continent is null and location not like '%income%'
group by location, population
order by 4 desc

--Global numbers

----Global numbers by date
select date, sum(new_cases) as TotalCases, sum ( cast( new_deaths as int)) as TotalDeaths, sum ( cast( new_deaths as int))/sum(new_cases) * 100  as DeathPercentage
from [Portfolio Project].dbo.[Covid Deaths]
where continent is not null
group by date
order by 1

----Global Numbers in total

select sum(new_cases) as TotalCases, sum ( cast( new_deaths as int)) as TotalDeaths, sum ( cast( new_deaths as int))/sum(new_cases) * 100  as DeathPercentage
from [Portfolio Project].dbo.[Covid Deaths]
where continent is not null
--group by date


--Looking at Total Population vs Vaccination

select dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from [Portfolio Project].dbo.CovidVaccinations vac
join [Portfolio Project].dbo.[Covid Deaths] dea
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null and dea.location='Albania'
order by 2,3

--USE CTE

with PopVsVac ( Continent, Location, date, population,New_Vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from [Portfolio Project].dbo.CovidVaccinations vac
join [Portfolio Project].dbo.[Covid Deaths] dea
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
--order by 2,3 
)

select  location, coalesce((max(RollingPeopleVaccinated)/max(population))*100, 0) as VaccinatedPercentage
from
PopVsVac
group by Location

--Derived Table

select location, coalesce((max(RollingPeopleVaccinated)/max(population))*100, 0) as VaccinatedPercentage
from
(
select dea.continent as continent,dea.location as location, dea.date as date, dea.population as population, vac.new_vaccinations as new_vaccinations,
sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from [Portfolio Project].dbo.CovidVaccinations vac
join [Portfolio Project].dbo.[Covid Deaths] dea
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null) t
group by location

--Creating view to store data for later visualizations

Create View PercentPopulationVaccinated as
select dea.continent as continent,dea.location as location, dea.date as date, dea.population as population, vac.new_vaccinations as new_vaccinations,
sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from [Portfolio Project].dbo.CovidVaccinations vac
join [Portfolio Project].dbo.[Covid Deaths] dea
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null