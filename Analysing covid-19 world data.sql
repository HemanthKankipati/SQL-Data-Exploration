/*
Covid 19 Data Exploration 
Skills used: Sql commands(Basic), Joins, Aggregate Functions, Creating Views, Converting Data Types
*/


--Looking at the covid-19 deaths table


select * from [COVID-19 analysis]..['covid-19 Deaths']

select Location, date, total_cases, new_cases, total_deaths, population 
from [COVID-19 analysis]..['covid-19 Deaths']
order by 1,2;

--Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contact covid in Australia


select Location, date, total_cases, total_deaths, Round((total_deaths/total_cases)*100,2) as DeathPercentage
from [COVID-19 analysis]..['covid-19 Deaths']
where location = 'Australia' 
order by 2;


--Looking at Total Cases vs Total population
-- Shows what percentage of population got covid


select Location, date, total_cases, population, Round((total_cases/population)*100,3) as PositivePercentage
from [COVID-19 analysis]..['covid-19 Deaths']
where location = 'Australia'
order by 2;


-- Looking at Countries with Infection rate compared to Population from highest to lowest


select Location, population,MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PositivePercentage
from [COVID-19 analysis]..['covid-19 Deaths']
group by location, population
order by PositivePercentage DESC

--Showing countries with Highest Death Count per Population


select Location, max(cast(Total_deaths as int)) as TotalDeathCount 
from [COVID-19 analysis]..['covid-19 Deaths']
Where continent is not null
group by location
order by TotalDeathCount desc;


--Let's Break Things Down by Continent


select continent, max(cast(Total_deaths as int)) as TotalDeathCount 
from [COVID-19 analysis]..['covid-19 Deaths']
Where continent is not null
group by continent
order by TotalDeathCount desc;


-- Global Numbers


Select  year(date) as Year, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int)) / SUM(new_cases) * 100 as DeathPercentage
from [COVID-19 analysis]..['covid-19 Deaths']
where continent is not null
Group by year(date);


-- Looking at Total Population vs Vaccinations


select  dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
from [COVID-19 analysis]..['Covid-19 vaccinations'] vac JOIN
[COVID-19 analysis]..['Covid-19 Deaths'] dea on
dea.location = vac.location and dea.date= vac.date
where dea.continent is not null
order by 2,3


-- Creating View to store data for later visualizations


Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [COVID-19 analysis]..['covid-19 Deaths'] dea
Join [COVID-19 analysis]..['Covid-19 vaccinations'] vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
