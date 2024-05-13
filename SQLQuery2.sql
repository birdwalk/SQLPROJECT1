SELECT *
FROM PROJECT1..[ covidvaccine]
order by 3,4

--Nigeria Stats
Select Location,date,total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PROJECT1..coviddeath
WHERE Location like '%Nigeria%'
order by 1,2


--Total cases vs the population
--Shows the percentage of the population that got covid
Select Location,date,total_cases,Population, (total_cases/Population)*100 as PopulationPercentage
FROM PROJECT1..coviddeath
WHERE Location like '%Nigeria%'
order by 1,2


-- Location with Highest Infection count
Select Location, Population,MAX(total_cases) as HighestInfectioncount, MAX((total_cases/Population))*100 as InfectedPopulationPercentage
FROM PROJECT1..coviddeath
--WHERE Location like '%Nigeria%'
group by Location, Population
order by InfectedPopulationPercentage desc



--showing countries with highest count of death
Select Location,MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PROJECT1..coviddeath
WHERE continent is not NULL
--WHERE Location like '%Nigeria%'
group by Location
order by TotalDeathCount desc



--World stats
Select continent,MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PROJECT1..coviddeath
WHERE continent is not NULL
Group by continent
order by TotalDeathCount desc



-- Total Population vs Vaccinations
--Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
--,SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as culmulativeForVaccinated  
--From PROJECT1 ..coviddeath dea
--Join PROJECT1 ..[ covidvaccine] vac
--     on dea.location = vac.location
--	 and dea.date = vac.date
--Where dea.continent is not null
--order by 2,3



--CTE
With PopvsVac(continent, location, date, population, new_vaccinations, culmulativeForVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as culmulativeForVaccinated  
From PROJECT1 ..coviddeath dea
Join PROJECT1 ..[ covidvaccine] vac
     on dea.location = vac.location
	 and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3
)
select *, (culmulativeForVaccinated)
From PopvsVac


--UISNG TEMP TABLE
DROP Table if exists PercentPopulationVaccinated
Create Table PercentPopulationVaccinated
(
Continent nvarchar(225),
Location nvarchar(225),
Date datetime,
Population numeric,
New_vaccinations numeric,
culmulativeForVaccinated numeric
)

insert into PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as culmulativeForVaccinated  
From PROJECT1 ..coviddeath dea
Join PROJECT1 ..[ covidvaccine] vac
     on dea.location = vac.location
	 and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3

select*,(culmulativeForVaccinated/population)*100
From PercentPopulationVaccinated




--creating view to store data for later visualization

CREATE VIEW PercentPopulationVaccinatedView as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as culmulativeForVaccinated  
From PROJECT1 ..coviddeath dea
Join PROJECT1 ..[ covidvaccine] vac
     on dea.location = vac.location
	 and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3



CREATE VIEW PercentPopulationVaccinatedMainView AS
SELECT 
    dea.continent, 
    dea.location, 
    dea.date, 
    dea.population, 
    vac.new_vaccinations,
    (
        SELECT SUM(CONVERT(int, vac.new_vaccinations)) 
        FROM PROJECT1..[ covidvaccine] AS vac_inner
        WHERE dea.location = vac_inner.location
        AND dea.date >= vac_inner.date
    ) AS cumulativeForVaccinated  
FROM 
    PROJECT1..coviddeath AS dea
JOIN 
    PROJECT1..[ covidvaccine] AS vac ON dea.location = vac.location
                                    AND dea.date = vac.date
WHERE 
    dea.continent IS NOT NULL;


