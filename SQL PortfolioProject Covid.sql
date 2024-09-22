
select *
from portfolioproject1..CovidDeaths
order by 1,2

select location,Date,total_cases,new_cases,total_deaths,population
from portfolioproject1..CovidDeaths
order by 1,2

--Looking at Total cases vs Total Deaths

--Alter table portfolioproject1..CovidDeaths
--Alter Column total_cases float


--Alter table portfolioproject1..CovidDeaths
--Alter Column total_deaths float

--Update portfolioproject1..CovidDeaths set total_cases = NULL where total_cases=0
--Update portfolioproject1..CovidDeaths set total_deaths = NULL where total_deaths=0

select location,Date,total_cases,total_deaths,(total_deaths/total_cases) * 100 as DeathPercentage
from portfolioproject1..CovidDeaths
Where location like '%India%'
order by 1,2

---Looking at total cases vs population

select location,Date,total_cases,total_deaths,population,(total_cases/population) * 100 as CasePercentage
from portfolioproject1..CovidDeaths
--Where location like '%states%'
order by 1,2

--Looking at Countries with Highest Infection rate compared to population

select location,population,Max(total_cases) as HighestInfectionCount,Max((total_cases/population)) * 100 as CasePercentage
from portfolioproject1..CovidDeaths
--Where location like '%states%'
Group by location,population
order by CasePercentage desc

--Let's break things down by continent


--Showing the countries with the highest death count per population


select location,Max(cast(total_deaths as int)) as HighestDeathCount--,Max((total_deaths/population)) * 100 as deathpercentage
from portfolioproject1..CovidDeaths
--Where location like '%states%'
where isnull(continent,'')<>''
Group by location
order by HighestDeathCount desc


select location,Max(cast(total_deaths as int)) as HighestDeathCount--,Max((total_deaths/population)) * 100 as deathpercentage
from portfolioproject1..CovidDeaths
--Where location like '%states%'
where isnull(continent,'')=''
Group by location
order by HighestDeathCount desc

-- GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject1..CovidDeaths
--Where location like '%states%'
where isnull(continent,'')<>''
--Group By date
order by 1,2

-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location Order by dea.location,dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject1..CovidDeaths dea
Join PortfolioProject1..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where isnull(dea.continent,'')<>''
order by 2,3

-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject1..CovidDeaths dea
Join PortfolioProject1..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (convert(float,RollingPeopleVaccinated)/cast(Population as float))*100
From PopvsVac


-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent varchar(255),
Location varchar(255),
Date varchar(20),
Population varchar(20),
New_vaccinations varchar(20),
RollingPeopleVaccinated bigint
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject1..CovidDeaths dea
Join PortfolioProject1..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (convert(float,RollingPeopleVaccinated)/cast(Population as float))*100
From #PercentPopulationVaccinated


-- Creating View to store data for later visualizations
--drop view PercentPopulationVaccinated
Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject1..CovidDeaths dea
Join PortfolioProject1..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where isnull(dea.continent,'')<>'' 

select * from PercentPopulationVaccinated order by location,date







