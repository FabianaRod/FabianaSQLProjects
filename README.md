# SQL MS Projects

This repository is dedicated to SQL MS projects including a general analysis of COVID19 deaths up to 2023 and the evaluation of house pricing in the state of Nashville, USA.

## Data Exploration and Data Cleaning Project - COVID-19 (Spanish)🩹

This project focuses on exploring data related to COVID-19, specifically using data from the official WHO website ("Explore the global data on confirmed COVID-19 deaths").

### Source Data

Data were retrieved from the official Our World In Data official website (https://ourworldindata.org/covid-deaths) and are stored in the database using T-SQL. 

### Evaluations Performed ☑️

  1. Total Cases Worldwide vs. Total Deaths in Peru
  2. Infected Population in Peru
  3. Countries with the Highest Infection Rates
  4. Countries with Highest Mortality
  5. Death Count by Continent
  6. Global Numbers to 2023
  7. Vaccination Progress in Peru from 2020 to 2023
  8. World Population and Vaccination

### Functions and Commands Used 🆎

  - **Joins:** Combining tables to obtain correlated data.
  - **WHERE:** Data filtering based on specific conditions.
  - **Temp Table:** Use of temporary tables to store intermediate results.
  - **ORDER BY:** Sorting of results according to specific criteria.
  - **GROUP BY:** Grouping of data for aggregate calculations.
  - **NULLIF:** Treatment of null values.
  - **CONVERT:** Data type conversion.
  - **MAX:** Obtaining the maximum value.
  - **PARTITION BY:** Division of results in partitions to perform calculations by group.

### Code Example: ✍️

```sql
SELECT location, date, total_cases,total_deaths, 
(CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0)) * 100 AS death_percent
FROM ProyectoCovid.dbo.CovidDeaths
WHERE location = 'Peru' 
ORDER BY 1,2
```

![image](https://github.com/FabianaRod/SQLProjects/assets/155020943/3dfe248f-d81e-4d9b-80ab-349977804adc)


```sql
SELECT SUM(new_cases) as global_cases, SUM(new_deaths) as global_deaths,
(SUM(new_deaths) * 100.0 / NULLIF(SUM(new_cases), 0)) AS global_death_percentage
FROM ProyectoCovid.dbo.CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2
```

![image](https://github.com/FabianaRod/SQLProjects/assets/155020943/31e8b166-a367-4901-aeb8-8bc79296a9be)


```sql
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
```


## Nashville House Pricing (English)🏠

Data cleaning project of an excel file of Nashville house pricing with fictitious data on land use, property address, sale date, sale price, legal reference, owner name, acreage, tax district, among others. 

### Evaluations Performed ☑️

  1. Standarize date format
  2. Populate Property Address Column
  3. Split Property Address Column
  4. Split Owner Address Column
  5. Remove Duplicates

### Functions and Commands Used 🆎

1. **ALTER TABLE:** Modify the structure of the tables, such as adding or removing columns.
2. **UPDATE:** Update values in specific columns of the dataset.
3. **SET:** Updates during the UPDATE operations.
4. **Joins:** Combine data from different tables based on specified conditions.
5. **WHERE:** Filtering rows based on specific conditions.
6. **ORDER BY:** Sort the dataset based on one or more columns.
7. **CASE:** Conditional evaluations in SQL queries.
8. **SUBSTRING:** Extract parts of a text string.
9. **PARSENAME:** Extract specific parts of identifiers, such as database names or object names.
10. **ADD:** AddS new columns or constraints to existing tables.
11. **PARTITION BY:** Dividing the dataset into partitions for window functions.

### Code Example: ✍️

```sql
ALTER TABLE Housing..HousingData
ADD SaleDateConverted date

UPDATE Housing..HousingData
SET SaleDateConverted = TRY_CONVERT(date, SaleDate, 103)
```

```sql
SELECT 
PARSENAME(REPLACE(OwnerAddress, ',', '.'),3) as UpdatedOwnerAddress,
PARSENAME(REPLACE(OwnerAddress, ',', '.'),2) as UpdatedOwnerCity,
PARSENAME(REPLACE(OwnerAddress, ',', '.'),1) as UpdatedOwnerState
FROM Housing..HousingData
```

```sql
WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY 
		ParcelID, 
		AddressUpdated, 
		SaleDateConverted, 
		SalePrice, 
		LegalReference
		ORDER BY
		UniqueID
		) row_num
FROM Housing..HousingData
)
DELETE 
FROM RowNumCTE
WHERE row_num > 1
```

Contributions are welcome. If you find bugs or potential improvements, open an issue or submit a pull request.

Thanks for reading 🤓
