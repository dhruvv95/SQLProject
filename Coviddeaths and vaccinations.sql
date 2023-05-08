SELECT *
FROM Portfolio..CovidDeaths
where continent is not null
Order by 3,4


--SELECT *
--FROM Portfolio..CovidVaccinations
--Order by 3,4

-- SHOWS LIKELIHOOD OF DYING IF YOU CONTRACT COVID IN YOUR COUNTRY
SELECT location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as Deathperc
from Portfolio..CovidDeaths
where location = 'India'
order by 1,2

-- LOOKING AT TOTAL CASES VS POPULATION

SELECT location,date,population,total_cases,(total_cases/population)*100 as Covidaffectperc
from Portfolio..CovidDeaths
where location = 'India'
order by 1,2

-- Looking at countries with highest infection rate compared to population

SELECT location,population,MAX(total_cases) as HighestInfectioncnt,MAX((total_cases/population))*100 as Covidaffect
from Portfolio..CovidDeaths
--where location = 'India'
Group by location,population
order by Covidaffect desc

-- Showing countries with the highest death rates per population

Select location,max(cast(Total_deaths as int)) as Totaldeathcount
from Portfolio..CovidDeaths
where continent is not null
group by location
order by Totaldeathcount desc

--BREAK THINGS BY CONTINENT

Select location, max(cast(Total_deaths as int)) as Totaldeathcount
from Portfolio..CovidDeaths
where continent is null
group by location
order by Totaldeathcount desc

--SHOWING CONTINENTS WITH HIGHEST DEATH COUNTS PER POPULATION

select SUM(cast(new_cases as int)) as Total_case, SUM(cast(new_deaths as int)) as Total_death,
SUM(cast(new_deaths as int))/SUM(new_cases)*100 as Deathpercentage
from Portfolio..CovidDeaths
where continent is not null
order by 1,2


--TOTAL POPULATION VS VACCINATION

SELECT cd.continent,cd.location,cd.date,cd.population,cv.new_vaccinations,
SUM(cast(cv.new_vaccinations as int)) OVER (Partition by cd.location Order by cd.location,cd.date) as Peoplevaccinated
from Portfolio..CovidDeaths cd
Join Portfolio..CovidVaccinations cv
	on cd.location = cv.location
	and cd.date = cv.date
	where cd.continent is not null
	order by 2,3


--USE CTE

With Popvsvac(continent,location,date,population,new_vaccinations,Peoplevaccinated)
as
(
SELECT cd.continent,cd.location,cd.date,cd.population,cv.new_vaccinations,
SUM(cast(cv.new_vaccinations as int)) OVER (Partition by cd.location Order by cd.location,cd.date) as Peoplevaccinated
from Portfolio..CovidDeaths cd
Join Portfolio..CovidVaccinations cv
	on cd.location = cv.location
	and cd.date = cv.date
	where cd.continent is not null
	--order by 2,3
	)
	Select *, (Peoplevaccinated/population)*100
	from Popvsvac

--Temp Table

Drop table if exists #Percentpopulationvaccinated

CREATE TABLE #Percentpopulationvaccinated
(
Continent nvarchar(255), 
location nvarchar(255),
date datetime,
population numeric,
New_vaccination numeric,
peoplevaccinated numeric
)

insert into #Percentpopulationvaccinated
SELECT cd.continent,cd.location,cd.date,cd.population,cv.new_vaccinations,
SUM(cast(cv.new_vaccinations as int)) OVER (Partition by cd.location Order by cd.location,cd.date) as Peoplevaccinated
from Portfolio..CovidDeaths cd
Join Portfolio..CovidVaccinations cv
	on cd.location = cv.location
	and cd.date = cv.date
	where cd.continent is not null

Select * ,(peoplevaccinated/population)*100
from #Percentpopulationvaccinated


--CREATING VIEW TO STORE DATA FOR LATER VISUALIZATIONS

CREATE View Percentpopulationvaccinated as
SELECT cd.continent,cd.location,cd.date,cd.population,cv.new_vaccinations,
SUM(cast(cv.new_vaccinations as int)) OVER (Partition by cd.location Order by cd.location,cd.date) as Peoplevaccinated
from Portfolio..CovidDeaths cd
Join Portfolio..CovidVaccinations cv
	on cd.location = cv.location
	and cd.date = cv.date
	where cd.continent is not null
	--order by 2,3


	Select * from Percentpopulationvaccinated