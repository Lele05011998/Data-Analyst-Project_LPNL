/*
Data source: https://ourworldindata.org/covid-deaths
*/


Create database SQL_CovidData
use SQL_CovidData
go
select Location, Date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage from [Covid in data]
where location LIKE '%Viet%'
order by 1,2

/* countries with highest rate of infection*/

select Location, population, Max(cast(total_cases as int)) as highestinfection, Max((total_cases/population)*100) as percentinfected
from [Covid in data]
group by location, population
order by percentinfected desc

/* countries with highest death*/

select Location, Max(cast(total_deaths as int)) as totalDeaths, Max((total_deaths/total_cases)*100) as percentage_deaths
from [Covid in data]
where continent IS NOT NULL
group by location
order by totalDeaths desc

/*sp_rename '[Covid in data].iso_code', 'Code', 'COLUMN';*/
/*sp_rename '[Vaccine Dose].Day', 'Date', 'COLUMN';*/
/*sp_rename '[Vaccine Dose].total_vaccine', 'total_percentage_vaccine', 'COLUMN';*/

/*continent with highest deaths and cases*/

select continent, Max(cast(total_deaths as int)) as totalDeaths,Max(cast(total_cases as int)) as totalCase
from [Covid in data]
group by continent
order by totalDeaths desc

select date, continent, SUM(cast(new_cases as int)) as totalnewcase, SUM(cast (new_deaths as int)) as totalnewdeaths
from [Covid in data]
where continent IS NOT NULL
group by date,continent
order by date desc

/*vaccine vs population*/

;with CTE (continent, location, population, date,total_cases, total_percentage_vaccine, total_vaccine)
as
(
	select continent, location, population, CD.date, total_cases, total_percentage_vaccine, 
		sum(convert(int, total_percentage_vaccine)) over (partition by CD.Location order by CD.location, CD.date) as total_vaccine
	from [Covid in data] as CD JOIN [Vaccine Dose] as VD 
		ON CD.Code = VD.Code and CD.date = VD.Date
	where continent is Not Null
)
select * from CTE

/* begin tran
go
Alter table [Covid in data] drop column weekly_hosp_admissions, weekly_hosp_admissions_per_million, weekly_icu_admissions, weekly_icu_admissions_per_million
commit */