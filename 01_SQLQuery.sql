--select * 
--from PortfolioProject..['Covid deaths$']
where continent is not null
--order by 3,4

--select * 
--from PortfolioProject..['Covid Vaccinations$']
--order by 3,4

Select location,date,total_cases,total_deaths,new_cases,population
from PortfolioProject..['Covid deaths$']
where continent is not null
order by 1,2


--looking at total vs total  cases
Select location,date,total_cases,total_deaths, (cast(total_deaths as float)/cast(total_cases as float))*100  as DeathPercentage
from PortfolioProject..['Covid deaths$']
where location like 'ind%'
order by 1,2

--looking at total cases vs population
Select location,date,population,total_cases, (cast(total_cases as float)/cast( population as float))*100  as CasePercentage
from PortfolioProject..['Covid deaths$']
--where location like '%states%'
order by 1,2

--looking at countries with highest infection rate compared to  population
Select location,population,max(total_cases) as HIghestInfectioncount, max(cast(total_cases as int)/cast( population as float))*100  as Population_infecPercentage
from PortfolioProject..['Covid deaths$']
--where location='india'
group by location,population
order by Population_infecPercentage desc

--Showing countries with highest death rate
Select location, max(cast(total_deaths as int))  as maxdeath
from PortfolioProject..['Covid deaths$']
--where location='india'
where continent is not null
group by location,population
order by maxdeath desc


--datas globally

Select date, sum(new_cases) as totalcases,sum(cast(new_deaths as int))  as totaldeath, sum(cast(new_deaths as int))/sum(new_cases)*100 as deathpercentage
from PortfolioProject..['Covid deaths$']
--where location='india'
where continent is  not null
group by date
order by 1,2




--select *
--from PortfolioProject..['Covid Vaccinations$']


--USING CTE
--Rolling peoplevaccinated and total population vs vaccination by using CTE
with POPvsVAC (continent,location,date,population,new_vaccinations,rollingPeopleVaccinated)
as
(
select det.continent,det.location,det.date,det.population,vac.new_vaccinations,
sum(convert(bigint,vac.new_vaccinations)) over (partition by det.location order by det.location,det.date) as rollingPeopleVaccinated
from PortfolioProject..['Covid deaths$'] det
join PortfolioProject..['Covid Vaccinations$'] vac
on det.date=vac.date
and det.location=vac.location
where det.continent is  not null
--order by 2,3
)
select * ,(rollingPeopleVaccinated/population)*100 as vaccPercentage
from POPvsVAC


--USING TEMP
Drop table if exists #POPvsVAC
create table #POPvsVAC
(continent nvarchar(255),location nvarchar(255),
date datetime,Population numeric,new_vaccinations numeric
,rollingPeopleVaccinated numeric)

insert into  #POPvsVAC
select det.continent,det.location,det.date,det.population,vac.new_vaccinations,
sum(convert(bigint,vac.new_vaccinations)) over (partition by det.location order by det.location,det.date) as rollingPeopleVaccinated
from PortfolioProject..['Covid deaths$'] det
join PortfolioProject..['Covid Vaccinations$'] vac
on det.date=vac.date
and det.location=vac.location
where det.continent is  not null
--order by 2,3

select * ,(rollingPeopleVaccinated/Population)*100 as vaccPercentage
from #POPvsVAC

--creating view to store for future use 
Create view POPvsVAC as
select det.continent,det.location,det.date,det.population,vac.new_vaccinations,
sum(convert(bigint,vac.new_vaccinations)) over (partition by det.location order by det.location,det.date) as rollingPeopleVaccinated
from PortfolioProject..['Covid deaths$'] det
join PortfolioProject..['Covid Vaccinations$'] vac
on det.date=vac.date
and det.location=vac.location
where det.continent is  not null
--order by 2,3

select * 
from POPvsVAC
