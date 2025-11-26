select * from databaseproject.dbo.HousingData
----------------------------------------
 -- Standardize Date Format
 select SaleDateConverted, Convert(Date,SaleDate) from databaseproject.dbo.HousingData



 ALTER TABLE HousingData
 Add SaleDateConverted date;


  Update databaseproject.dbo.HousingData
 SET SaleDateConverted = Convert(Date,SaleDate)

 ----------------------------------------
 
-- Populate Property Address data

 select * from databaseproject.dbo.HousingData --where PropertyAddress is null
 order by ParcelID

 select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
 from databaseproject.dbo.HousingData a
 JOIN databaseproject.dbo.HousingData b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ]<>b.[UniqueID ]
Where a.PropertyAddress is null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
 from databaseproject.dbo.HousingData a
 JOIN databaseproject.dbo.HousingData b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ]<>b.[UniqueID ]
	Where a.PropertyAddress is null

	----------------------------------------------------------------------------------------------------------------------------------

	-- Breaking out Address into Individual Columns (Address, City, State)
	
Select PropertyAddress
from databaseproject.dbo.HousingData
--Where PropertyAddress is null
--order by ParcelID

Select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as City
from databaseproject.dbo.HousingData

 ALTER TABLE databaseproject.dbo.HousingData
 Add PropertySplitAddress Nvarchar(255);


  Update databaseproject.dbo.HousingData
 SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

  ALTER TABLE databaseproject.dbo.HousingData
 Add PropertySplitCity Nvarchar(255);


  Update databaseproject.dbo.HousingData
 SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

 Select * from databaseproject.dbo.HousingData




  Select OwnerAddress from databaseproject.dbo.HousingData
  Select
  PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
  PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
  PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
  from databaseproject.dbo.HousingData


   ALTER TABLE databaseproject.dbo.HousingData
 Add OwnerSplitAddress Nvarchar(255);
  Update databaseproject.dbo.HousingData
 SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)


  ALTER TABLE databaseproject.dbo.HousingData
 Add OwnerSplitCity Nvarchar(255);

  Update databaseproject.dbo.HousingData
 SET OwnerSplitCity =   PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

 
  ALTER TABLE databaseproject.dbo.HousingData
 Add OwnerSplitState Nvarchar(255);

  Update databaseproject.dbo.HousingData
 SET OwnerSplitState =   PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

 Select * from databaseproject.dbo.HousingData
 ---------------------------------------------------------------------------------------------------------------------
 
-- Change Y and N to Yes and No in "Sold as Vacant" field

Select Distinct (SoldAsVacant), Count (SoldAsVacant)
From databaseproject.dbo.HousingData
group by SoldAsVacant
Order by 2

Select SoldAsVacant, 
CASE When SoldAsVacant ='Y' THEN 'Yes'
When SoldAsVacant ='N' THEN 'No'
ELSE SoldAsVacant 
END
from databaseproject.dbo.HousingData

 Update databaseproject.dbo.HousingData
 SET SoldAsVacant = CASE When SoldAsVacant ='Y' THEN 'Yes'
When SoldAsVacant ='N' THEN 'No'
ELSE SoldAsVacant 
END

-------------------------------------------------------------------------
-- Remove Duplicates

WITH RowNumCTE AS (
    SELECT *,
        ROW_NUMBER() OVER(
            PARTITION BY ParcelID,
                         PropertyAddress,
                         SalePrice,
                         SaleDate,
                         LegalReference
            ORDER BY UniqueID
        ) AS row_num
    FROM databaseproject.dbo.HousingData
)


Select *
FROM RowNumCTE
WHERE row_num > 1
Order By PropertyAddress


-------------------------------------------------------------------------


-- Delete Unused Colmns

Select * 
From  databaseproject.dbo.HousingData

ALTER TABLE databaseproject.dbo.HousingData
DROP COLUMN OwnerAddress, taxdistrict, PropertyAddress