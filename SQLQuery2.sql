select *
from CovidDeath
order by 3,4

select *
from CovidVaccinations
order by 3,4

--I will select data i need for my analysis

Select  Location, continent, date, total_cases, total_deaths, new_deaths, population
from CovidDeath
order by 1,2

--Comparing Totalcases with TotalDeaths

Select  Location, date, total_cases, total_deaths, (total_deaths/total_cases) as PercentDeath
from CovidDeath
order by 1,2

-- Error with datatype being nvarchar. Need to chec the datatype

Select 
TABLE_CATALOG,
TABLE_SCHEMA,
TABLE_NAME, 
COLUMN_NAME, 
DATA_TYPE 
FROM INFORMATION_SCHEMA.COLUMNS
where TABLE_NAME = 'CovidDeath'

Select  Location, date, total_cases, total_deaths,
(CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0))*100 PercentDeath
from CovidDeath
where location like '%Kingdom%'
order by 1,2

-- The above % shows the likelihood of dieing from covid which is less than 1% in UK presently

-- What is the percentage of infected people in the population
Select  Location, date, total_cases, total_deaths, population, 
(CONVERT(float, total_cases))/population*100 PercentInfected
from CovidDeath
where location like '%Kingdom%'
order by 1,2

-- country with highest infection rate
Select  Location, new_cases, max(CONVERT(float, total_cases)) HighestInfected_cases, total_deaths, population, 
Max((CONVERT(float, total_cases))/population)*100 PercentInfected
from CovidDeath
--where location like '%Kingdom%')
group by  Location, new_cases, total_deaths, population
order by 6 desc

--Country with highest death count
Select  Location, max(cast (total_deaths as int)) Maxdeath
from CovidDeath
--where location like '%Kingdom%'
where continent is not null
group by  Location
order by 2 desc



Select  Location, max(cast (total_deaths as int)) Maxdeath
from CovidDeath
--where location like '%Kingdom%'
where continent is null
group by  Location
order by 2 desc

--Continent exploration with maximum death
Select  continent, max(cast (total_deaths as int)) Maxdeath
from CovidDeath
where continent is not null
group by  continent
order by 2 desc

--showing continents with the highest deathcount per population in percentage
Select  continent, max(cast (total_deaths as int)) Maxdeath,  (max(cast (total_deaths as int))/population)*100 PercentageMaxdeathperpopulation
from CovidDeath
where continent is not null
group by  continent, population
order by 3 desc

--Global Overview of cases and death
Select  date, SUM(new_cases) Sumofnewcases, SUM(new_deaths) Sumofnewdeaths, (SUM(new_deaths)/SUM(new_cases))*100 DeathPercentagepercase
from CovidDeath
where continent is not null
group by date
order by 4 desc

--Total %of deaths, cases and deaths
Select SUM(new_cases) Sumofnewcases, SUM(new_deaths) Sumofnewdeaths, (SUM(new_deaths)/SUM(new_cases))*100 DeathPercentagepercase
from CovidDeath
where continent is not null
--group by date
--order by 3 desc


--Let's explore The Covid Vaccination table
Select *
from CovidVaccinations

--Joining the two tables
Select *
from CovidVaccinations Vacc
join CovidDeath Det
	on Det.location=Vacc.location
	and Det.date=Vacc.date

--Total Vaccination in a population (using CTE)
Select Det.continent, Det.location, Det.date, Det.population, Vacc.new_vaccinations,
(SUM(cast(Vacc.new_vaccinations as bigint)) over (partition by det.location order by det.date)) cumulativesumofvaccination
from CovidVaccinations Vacc
join CovidDeath Det
	on Det.location=Vacc.location
	and Det.date=Vacc.date
	where Det.continent is not null 
	order by 2,3
	
With VaccvsPop (continent, location, date, population, new_vaccinations,cumulativesumofvaccination)
as
(
Select Det.continent, Det.location, Det.date, Det.population, Vacc.new_vaccinations,
(SUM(cast(Vacc.new_vaccinations as bigint)) over (partition by det.location order by det.date)) cumulativesumofvaccination
from CovidVaccinations Vacc
join CovidDeath Det
	on Det.location=Vacc.location
	and Det.date=Vacc.date
	where Det.continent is not null 
	--order by 2,3
)

Select*, (cumulativesumofvaccination/population)*100 
from VaccvsPop
where location like 'United Kingdom'

--using temp table

Create table #VaccvsPop
(continent nvarchar (255),
location nvarchar (255),
date datetime,
population numeric,
new_vaccinations numeric,
cumulativesumofvaccination numeric)

Insert into #VaccvsPop
Select Det.continent, Det.location, Det.date, Det.population, Vacc.new_vaccinations,
(SUM(cast(Vacc.new_vaccinations as bigint)) over (partition by det.location order by det.date)) cumulativesumofvaccination
from CovidVaccinations Vacc
join CovidDeath Det
	on Det.location=Vacc.location
	and Det.date=Vacc.date
	where Det.continent is not null 
	--order by 2,3

	select*, (cumulativesumofvaccination/population)*100
	from #VaccvsPop

--Create view for data visualization

Create view VaccvsPop as
Select Det.continent, Det.location, Det.date, Det.population, Vacc.new_vaccinations,
(SUM(cast(Vacc.new_vaccinations as bigint)) over (partition by det.location order by det.date)) cumulativesumofvaccination
from CovidVaccinations Vacc
join CovidDeath Det
	on Det.location=Vacc.location
	and Det.date=Vacc.date
	where Det.continent is not null 
	--order by 2,3