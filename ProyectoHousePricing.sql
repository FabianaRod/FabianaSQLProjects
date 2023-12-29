-- CLEANING DATA - NASHVILLE HOUSING PRICES PROJECT

SELECT *
FROM Housing..HousingData

-- STANDIRIZE DATE FORMAT

ALTER TABLE Housing..HousingData
ADD SaleDateConverted date

UPDATE Housing..HousingData
SET SaleDateConverted = TRY_CONVERT(date, SaleDate, 103)

SELECT *
FROM Housing..HousingData
WHERE SaleDateConverted IS NULL -- TO VERIFY REMAINING NULL VALUES 

ALTER TABLE Housing..HousingData
DROP COLUMN SaleDate

-- POPULATE PROPERTY ADDRESS COLUMN 

SELECT *
FROM Housing..HousingData
WHERE PropertyAddress IS NULL
ORDER BY ParcelID

SELECT A.ParcelID, A.PropertyAddress, B.ParcelID, B.PropertyAddress, ISNULL(A.PropertyAddress, B.PropertyAddress) AS TempColumn
FROM Housing..HousingData A
JOIN Housing..HousingData B
	ON A.ParcelID = B.ParcelID
	AND A.UniqueID <> B.UniqueID
WHERE A.PropertyAddress IS NULL

UPDATE A
SET PropertyAddress = ISNULL(A.PropertyAddress, B.PropertyAddress)
FROM Housing..HousingData A
JOIN Housing..HousingData B
	ON A.ParcelID = B.ParcelID
	AND A.UniqueID <> B.UniqueID

SELECT *
FROM Housing..HousingData
WHERE PropertyAddress IS NULL 

UPDATE Housing..HousingData
SET PropertyAddress = 'NO ADDRESS'
WHERE PropertyAddress IS NULL 

-- SPLIT PROPERTYADDRESS COLUMN INTO INDIVIDUAL COLUMNS

SELECT
  CASE 
    WHEN CHARINDEX(',', PropertyAddress) > 0 
    THEN SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) 
    ELSE PropertyAddress 
  END as ADDRESS,
  CASE 
    WHEN CHARINDEX(',', PropertyAddress) > 0 
    THEN SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))
    ELSE 'NO CITY'
  END as CITY
FROM Housing..HousingData

ALTER TABLE Housing..HousingData
ADD AddressUpdated NVARCHAR(255)

ALTER TABLE Housing..HousingData
ADD City NVARCHAR(255)

UPDATE Housing..HousingData
SET
  AddressUpdated = 
    CASE 
      WHEN CHARINDEX(',', PropertyAddress) > 0 
      THEN SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) 
      ELSE PropertyAddress 
    END,
  City = 
    CASE 
      WHEN CHARINDEX(',', PropertyAddress) > 0 
      THEN SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))
      ELSE NULL 
    END

ALTER TABLE Housing..HousingData
DROP COLUMN PropertyAddress


-- SPLIT THE OWNERADDRESS COLUMN INTO INDIVIDUAL VALUES (ALTERNATIVE METHOD)

SELECT 
PARSENAME(REPLACE(OwnerAddress, ',', '.'),3) as UpdatedOwnerAddress,
PARSENAME(REPLACE(OwnerAddress, ',', '.'),2) as UpdatedOwnerCity,
PARSENAME(REPLACE(OwnerAddress, ',', '.'),1) as UpdatedOwnerState
FROM Housing..HousingData

ALTER TABLE Housing..HousingData
ADD UpdatedOwnerAddress NVARCHAR(255)

ALTER TABLE Housing..HousingData
ADD UpdatedOwnerCity NVARCHAR(255)

ALTER TABLE Housing..HousingData
ADD UpdatedOwnerState NVARCHAR(255)

UPDATE Housing..HousingData
SET
UpdatedOwnerAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'),3),
UpdatedOwnerCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'),2),
UpdatedOwnerState = PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)

ALTER TABLE Housing..HousingData
DROP COLUMN OwnerAddress

-- REMOVE DUPLICATES

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
SELECT * 
FROM RowNumCTE
WHERE row_num > 1
ORDER BY AddressUpdated

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

