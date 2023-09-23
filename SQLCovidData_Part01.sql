--select *
--from PortfolioProject..CovidDeaths
--order by 3, 4

--select *
--from PortfolioProject..CovidVaccinations
--order by 3, 4

--***Select data that we are going to be using***
--select location, date, total_cases, new_cases, total_deaths, population
--from PortfolioProject..CovidDeaths
--order by 1, 2

--***Looking at Total Cases VS Total Deaths***
--select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
--from PortfolioProject..CovidDeaths
--order by 1, 2
-- code above error by char cannot divided
--SELECT
--    location,
--    date,
--    CAST(total_cases AS FLOAT) AS total_cases,
--    CAST(total_deaths AS FLOAT) AS total_deaths,
--    (CAST(total_deaths AS FLOAT) / CAST(total_cases AS FLOAT)) * 100 AS DeathPercentage
--FROM
--    PortfolioProject..CovidDeaths
--where location like '%state%'
--ORDER BY
--    location,date desc;

-- Looking at Total Cases VS Population
-- Show what percentage of population got Covid

select location, date, population, total_cases, (total_cases/population)*100 as CovidToPopulationPercentage
from PortfolioProject..CovidDeaths
where location like '%thai%'
order by 1, 2 desc

-- Looking at Countries with Highest Infection Rate compared to Population

select location, population, 
Max(total_cases) as Sum_Total_Cases, 
Max((total_cases/population))*100 as PercenPopulationInfected
from PortfolioProject..CovidDeaths
where location like '%thai%'
group by location, population
order by PercenPopulationInfected desc

SELECT
    location,
    date,
    CAST(MAX(total_cases) AS FLOAT) AS total_cases,
    CAST(MAX(population) AS FLOAT) AS population,
    MAX(total_cases / population)*100 AS percenCases
FROM
    PortfolioProject..CovidDeaths
WHERE
    location LIKE '%thai%'
GROUP BY
    location,
    date
ORDER BY
    percenCases DESC;

-- Showing Countries with highest death count per population

SELECT
    location,
    date,
    CAST(MAX(total_deaths) AS FLOAT) AS total_deaths,
    CAST(MAX(population) AS FLOAT) AS population,
    MAX(total_deaths / population)*100 AS percenDeaths
FROM
    PortfolioProject..CovidDeaths
WHERE
    location LIKE '%state%'
GROUP BY
    location,
    date
ORDER BY
    percenDeaths DESC;

select
	location,
	max(cast(total_deaths as int)) as TotalDeathCount
from
	PortfolioProject..CovidDeaths
group by
	location
order by
	TotalDeathCount desc

select
	location,
	max(cast(total_deaths as int)) as TotalDeathCount
from
	PortfolioProject..CovidDeaths
where
	continent is not null
group by
	location
order by
	TotalDeathCount desc ;


-- LET'S BREAK THINGS DOWN BY CONTINENT

select 
	location, 
	max(cast(total_deaths as int)) as TotalDeathCount
from
	PortfolioProject..CovidDeaths
where
	continent is null
group by
	location
order by
	TotalDeathCount desc ;

select 
	continent, 
	max(cast(total_deaths as int)) as TotalDeathCount
from
	PortfolioProject..CovidDeaths
where
	continent is not null
group by
	continent
order by
	TotalDeathCount desc ;

-- Showing continents with the highest death count per population


-- Global numbers
-- by date
SELECT
    date,
    SUM(new_cases) AS TotalNewCases,
    SUM(CAST(new_deaths AS FLOAT)) AS TotalNewDeaths,
    CASE
        WHEN SUM(new_cases) = 0 THEN 0
        ELSE (SUM(CAST(new_deaths AS FLOAT)) / SUM(new_cases)) * 100
    END AS DeathPercentage
FROM
    PortfolioProject..CovidDeaths
WHERE
    continent IS NOT NULL
GROUP BY
    date
ORDER BY
    1, 2;

--by all
SELECT
	--date,
    SUM(new_cases) AS TotalNewCases,
    SUM(CAST(new_deaths AS FLOAT)) AS TotalNewDeaths,
    CASE
        WHEN SUM(new_cases) = 0 THEN 0
        ELSE (SUM(CAST(new_deaths AS FLOAT)) / SUM(new_cases)) * 100
    END AS DeathPercentage
FROM
    PortfolioProject..CovidDeaths
WHERE
    continent IS NOT NULL
--GROUP BY
--    date
ORDER BY
    1, 2;


-- About Vaccine
-- Looking at total population vs vaccinations
select
	dea.continent,
	dea.location,
	dea.date,
	dea.population,
	vac.new_vaccinations
from
	PortfolioProject..CovidVaccinations vac
join
	PortfolioProject..CovidDeaths dea
	on dea.location = vac.location
	and dea.date = vac.date
where
	dea.continent is not null and
	dea.location like '%canada%'
order by 
	1, 2, 3;

-- Sum vaccinations
select
	dea.continent,
	dea.location,
	dea.date,
	dea.population,
	vac.new_vaccinations,
	sum(convert(float,vac.new_vaccinations)) over (partition by dea.location order by dea.date) as
	RollingPeopleVaccinated,
	--sum(convert(float,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date )
	(sum(convert(float,vac.new_vaccinations)) over (partition by dea.location order by dea.date) / 
	dea.population)*100 as PercenVaccine
from
	PortfolioProject..CovidVaccinations vac
join
	PortfolioProject..CovidDeaths dea
	on dea.location = vac.location
	and dea.date = vac.date
where
	dea.continent is not null and 
	dea.location like '%thai%'
order by 
	 dea.location, dea.date;


-- Use CTE
with PopVSVac(
	continent, 
	location,
	date,
	population,
	new_vaccinations,
	RollingVaccin)
as(
select
	dea.continent,
	dea.location,
	dea.date,
	dea.population,
	vac.new_vaccinations,
	sum(convert(float,vac.new_vaccinations)) over (partition by dea.location order by dea.date) as
	RollingPeopleVaccinated
from
	PortfolioProject..CovidVaccinations vac
join
	PortfolioProject..CovidDeaths dea
	on dea.location = vac.location
	and dea.date = vac.date
where
	dea.continent is not null)

select
*,
(RollingVaccin / population)*100 as PercenVacc
from PopVSVac


-- Creating view to store data for later visualizations
create view PercenPopulationVaccinated as
select
	dea.continent,
	dea.location,
	dea.date,
	dea.population,
	vac.new_vaccinations,
	sum(convert(float,vac.new_vaccinations)) over (partition by dea.location order by dea.date) as
	RollingPeopleVaccinated
	--sum(convert(float,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date )
	--(sum(convert(float,vac.new_vaccinations)) over (partition by dea.location order by dea.date) / 
	--dea.population)*100 as PercenVaccine
from
	PortfolioProject..CovidVaccinations vac
join
	PortfolioProject..CovidDeaths dea
	on dea.location = vac.location
	and dea.date = vac.date
where
	dea.continent is not null 
--order by 
--	 dea.location, dea.date;


--- Show a create view that we just create
select *
from PercenPopulationVaccinated;