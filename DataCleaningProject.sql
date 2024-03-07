--PROJECT: DATA CLEANING IN SQL


SELECT * FROM DataCleaningProject.dbo.NashvilleHousing

-- Standardising the SaleDate --
SELECT SaleDate, CONVERT (Date, SaleDate) 
FROM DataCleaningProject.dbo.NashvilleHousing

UPDATE NashvilleHousing
SET SaleDate = CONVERT (Date, SaleDate)

ALTER TABLE NashvilleHousing
ADD New_SaleDate Date;

UPDATE NashvilleHousing
SET New_SaleDate = CONVERT (Date, SaleDate)

SELECT SaleDate, New_SaleDate 
FROM DataCleaningProject.dbo.NashvilleHousing   --The Standardised format


-- Populating the missing data --
SELECT *
FROM DataCleaningProject.dbo.NashvilleHousing
WHERE PropertyAddress IS NULL

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
FROM DataCleaningProject.dbo.NashvilleHousing a
JOIN DataCleaningProject.dbo.NashvilleHousing b
ON a.ParcelID = b.ParcelID 
AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS null

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM DataCleaningProject.dbo.NashvilleHousing a
JOIN DataCleaningProject.dbo.NashvilleHousing b
ON a.ParcelID = b.ParcelID 
AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS null

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM DataCleaningProject.dbo.NashvilleHousing a
JOIN DataCleaningProject.dbo.NashvilleHousing b
ON a.ParcelID = b.ParcelID 
AND a.[UniqueID ] <> b.[UniqueID ]   -- missing values are populated 


-- breaking out property address in individual columns --
SELECT PropertyAddress
FROM DataCleaningProject.dbo.NashvilleHousing

SELECT 
SUBSTRING (PropertyAddress, 1, CHARINDEX (',', PropertyAddress) -1) AS Address
FROM DataCleaningProject.dbo.NashvilleHousing

SELECT 
SUBSTRING (PropertyAddress, 1, CHARINDEX (',', PropertyAddress) -1) AS Address,
SUBSTRING (PropertyAddress, CHARINDEX (',', PropertyAddress) +1 ,LEN (PropertyAddress)) AS Address
FROM DataCleaningProject.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress Nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING (PropertyAddress, 1, CHARINDEX (',', PropertyAddress) -1)

ALTER TABLE NashvilleHousing
ADD PropertySplitCity Nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING (PropertyAddress, CHARINDEX (',', PropertyAddress) +1 ,LEN (PropertyAddress))


-- breaking out owner address --
SELECT 
PARSENAME (REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME (REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME (REPLACE(OwnerAddress, ',', '.'), 1)
FROM DataCleaningProject.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
ADD OwnerPropertyAddress Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerPropertyAddress = PARSENAME (REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE NashvilleHousing
ADD OwnerPropertyCity Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerPropertyCity = PARSENAME (REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE NashvilleHousing
ADD OwnerPropertyState Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerPropertyState = PARSENAME (REPLACE(OwnerAddress, ',', '.'), 1)


-- changing Y & N to yes & no in 'SoldAsVacant' field
SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM DataCleaningProject.dbo.NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
WHEN SoldAsVacant = 'N' THEN 'No'
ELSE SoldAsVacant
END
FROM DataCleaningProject.dbo.NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
WHEN SoldAsVacant = 'N' THEN 'No'
ELSE SoldAsVacant
END


-- remove duplicates --
WITH RowNumCTE AS(
SELECT *,
ROW_NUMBER () OVER (
PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
ORDER BY UniqueID ) row_num
FROM DataCleaningProject.dbo.NashvilleHousing
)
SELECT*
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress

WITH RowNumCTE AS(
SELECT *,
ROW_NUMBER () OVER (
PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
ORDER BY UniqueID ) row_num
FROM DataCleaningProject.dbo.NashvilleHousing
)
DELETE 
FROM RowNumCTE
WHERE row_num > 1


-- delete unused columns --
SELECT * 
FROM DataCleaningProject.dbo.NashvilleHousing

ALTER TABLE DataCleaningProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE DataCleaningProject.dbo.NashvilleHousing
DROP COLUMN SaleDate