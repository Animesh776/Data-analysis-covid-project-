select * from portfolioproject.dbo.coviddeaths
order by 3,4

----select * from portfolioproject.dbo.covidvacinations
----order by 3,4



select location,date,total_cases,new_cases,total_deaths,population from portfolioproject.dbo.coviddeaths
order by 1,2

-- looking at total cases vs total deaths 

select location,date,total_cases,total_deaths, (total_deaths/total_cases)*100 as deathpercentage 
from portfolioproject.dbo.coviddeaths
where location like'%india%'
order by 1,2




--looking at total cases vs population



select location,date,population,total_cases, (total_cases/population)*100 as percentageinfected 
from portfolioproject.dbo.coviddeaths
--where location like'%india%'
order by 1,2

--Looking at countries with highest infection rate compared to population


select location,population,max(total_cases) as highestinfectioncount, max((total_cases/population))*100 as poppercentageinfected 
from portfolioproject.dbo.coviddeaths
--where location like'%india%'
group by location,population
order by poppercentageinfected desc



--showing countries highest death count per population 

select location,MAX(cast(total_deaths as int)) as totaldeathcount
from portfolioproject.dbo.coviddeaths
--where location like'%india%'
where continent is not null
group by location
order by totaldeathcount desc



--lets break things down by continent




select continent,MAX(cast(total_deaths as int)) as totaldeathcount
from portfolioproject.dbo.coviddeaths
--where location like'%india%'
where continent is not  null
group by continent
order by totaldeathcount desc


--showing continents with highest death count per population



select continent,MAX(cast(total_deaths as int)) as totaldeathcount
from portfolioproject.dbo.coviddeaths
--where location like'%india%'
where continent is not null
group by continent
order by totaldeathcount desc



--GLOBAL numbers



select sum(new_cases) as total_cases,sum(cast(new_deaths as int)) as total_deaths,sum(new_cases)/sum(cast(new_deaths as int))*100 as deathpercentage 
from portfolioproject.dbo.coviddeaths
--where location like'%india%'
where continent is not null
--group by date
order by 1,2



-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine



Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..coviddeaths dea
Join PortfolioProject..covidvacinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3





-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..coviddeaths dea
Join PortfolioProject..covidvacinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac




-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..coviddeaths dea
Join PortfolioProject..covidvacinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated





-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..coviddeaths dea
Join PortfolioProject..covidvacinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 


select * from PercentPopulationVaccinated