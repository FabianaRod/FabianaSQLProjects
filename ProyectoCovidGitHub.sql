-- SELECCIONAR DATA 

SELECT *
FROM ProyectoCovid.dbo.CovidVacc
WHERE continent IS NOT NULL
ORDER BY 3, 4

SELECT *
FROM ProyectoCovid.dbo.CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3,4

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM ProyectoCovid.dbo.CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2

-- CASOS TOTALES VS. DECESOS TOTALES PERU

SELECT location, date, total_cases,total_deaths, 
(CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0)) * 100 AS death_percent
FROM ProyectoCovid.dbo.CovidDeaths
WHERE location = 'Peru' 
ORDER BY 1,2

-- POBLACIÓN INFECTADA EN PERU

SELECT location, date, population, total_cases, 
(CONVERT(float, total_cases) / NULLIF(CONVERT(float, population), 0)) * 100 AS infection_percent
FROM ProyectoCovid.dbo.CovidDeaths
WHERE location = 'Peru'
ORDER BY 1,2

-- PAISES CON EL % DE INFECCION MAS ELEVADO 

SELECT location, population, MAX(total_cases) as total_infection, 
MAX((CONVERT(float, total_cases) / NULLIF(CONVERT(float, population), 0)))* 100 AS infection_percent
FROM ProyectoCovid.dbo.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY infection_percent DESC

-- PAISES CON MORTALIDAD MAS ELEVADA

SELECT location, MAX(CAST(total_deaths AS int)) as total_deathcount
FROM ProyectoCovid.dbo.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY total_deathcount DESC

-- RECUENTO DE MUERTES POR CONTINENTE

SELECT continent,  SUM(new_deaths) as total_continent_deathcount
FROM ProyectoCovid.dbo.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY total_continent_deathcount DESC

-- NUMEROS GLOBALES A 2023

SELECT SUM(new_cases) as global_cases, SUM(new_deaths) as global_deaths,
(SUM(new_deaths) * 100.0 / NULLIF(SUM(new_cases), 0)) AS global_death_percentage
FROM ProyectoCovid.dbo.CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2

-- AVANCE DE VACUNACION EN PERU DE 2020 A 2023

SELECT Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations,
(CONVERT(float, Vac.new_vaccinations) / NULLIF(CONVERT(float, Dea.population), 0)) * 100.0 as vaccination_percentage
FROM ProyectoCovid.dbo.CovidDeaths Dea
JOIN ProyectoCovid.dbo.CovidVacc Vac
	ON Dea.location = Vac.location
	and Dea.date = vac.date
WHERE Dea.continent IS NOT NULL AND Dea.location = 'Peru'
ORDER BY 1,2,3

-- POBLACIÓN MUNDIAL Y VACUNACIÓN
---TEMP TABLE 
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(50),
Location nvarchar(50),
Date date,
Population bigint,
New_vaccinations nvarchar(50),
People_vaccinated bigint
)

INSERT INTO #PercentPopulationVaccinated
SELECT Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations, 
SUM(CONVERT(float, Vac.new_vaccinations)) OVER (PARTITION BY Dea.location ORDER BY Dea.location, Dea.date) as People_vaccinated
FROM ProyectoCovid.dbo.CovidDeaths Dea
JOIN ProyectoCovid.dbo.CovidVacc Vac
	ON Dea.location = Vac.location
	and Dea.date = vac.date

SELECT *, (People_vaccinated/population)*100
FROM #PercentPopulationVaccinated

CREATE VIEW PercentPopulationVaccinated as
SELECT Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations, 
SUM(CONVERT(float, Vac.new_vaccinations)) OVER (PARTITION BY Dea.location ORDER BY Dea.location, Dea.date) as People_vaccinated
FROM ProyectoCovid.dbo.CovidDeaths Dea
JOIN ProyectoCovid.dbo.CovidVacc Vac
	ON Dea.location = Vac.location
	AND Dea.date = vac.date
WHERE Dea.continent IS NOT NULL