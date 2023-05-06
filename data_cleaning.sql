-- sql queries for data cleaning
 
SELECT 
    *
FROM
    nashville_housing;

-- fill  property address missing data 
SELECT 
    a.ParcelID,
    a.PropertyAddress,
    b.ParcelID,
    b.PropertyAddress,
    IFNULL(a.PropertyAddress, b.PropertyAddress) AS filled_address
FROM
    nashville_housing a
        JOIN
    nashville_housing b ON a.ParcelID = b.ParcelID
        AND a.UniqueID <> b.UniqueID
WHERE
    a.PropertyAddress IS NULL;
    
-- updating the data 
    
UPDATE nashville_housing a
        JOIN
    nashville_housing b ON a.ParcelID = b.ParcelID
        AND a.UniqueID <> b.UniqueID 
SET 
    a.PropertyAddress = IFNULL(a.PropertyAddress, b.PropertyAddress)
WHERE
    a.PropertyAddress IS NULL;

-- Breaking out Address into individual columns (Address,city,state)

SELECT 
    PropertyAddress
FROM
    nashville_housing;

    
SELECT 
    LEFT(PropertyAddress,
        LOCATE(',', PropertyAddress) - 1) AS address,
    RIGHT(PropertyAddress,
        LENGTH(PropertyAddress) - LOCATE(',', PropertyAddress)) AS city
FROM
    nashville_housing;

ALTER TABLE nashville_housing
ADD COLUMN PropertySplitAddress VARCHAR(255);

ALTER TABLE nashville_housing
ADD COLUMN PropertySplitCity VARCHAR(255);

UPDATE nashville_housing 
SET 
    PropertySplitAddress = LEFT(PropertyAddress,
        LOCATE(',', PropertyAddress) - 1);

UPDATE nashville_housing 
SET 
    PropertySplitCity = RIGHT(PropertyAddress,
        LENGTH(PropertyAddress) - LOCATE(',', PropertyAddress));
        
        
        
-- working on owner address

SELECT 
    OwnerAddress
FROM
    nashville_housing;

SELECT 
    SUBSTRING_INDEX(REPLACE(OwnerAddress, ',', '.'), '.', 1) AS part_1,
    SUBSTRING_INDEX(SUBSTRING_INDEX(REPLACE(OwnerAddress, ',', '.'), '.', 2),
            '.',
            - 1) AS part_2,
    SUBSTRING_INDEX(REPLACE(OwnerAddress, ',', '.'),
            '.',
            - 1) AS part_3
FROM
    nashville_housing;
    
ALTER TABLE nashville_housing
ADD COLUMN   OwnerSplitAddress  VARCHAR(255);

UPDATE nashville_housing 
SET OwnerSplitAddress =  SUBSTRING_INDEX(REPLACE(OwnerAddress, ',', '.'), '.', 1) ;

ALTER TABLE nashville_housing
ADD COLUMN OwnerSplitCity   VARCHAR(255);

UPDATE nashville_housing 
SET OwnerSplitCity =  SUBSTRING_INDEX(SUBSTRING_INDEX(REPLACE(OwnerAddress, ',', '.'), '.', 2),
            '.',
            - 1);
            
ALTER TABLE nashville_housing
ADD COLUMN OwnerSplitState   VARCHAR(255);

UPDATE nashville_housing 
SET OwnerSplitState =  SUBSTRING_INDEX(REPLACE(OwnerAddress, ',', '.'),
            '.',
            - 1);   
SELECT 
    *
FROM
    nashville_housing;
    
-- Change Y and N to Yes and No in SoldAsVacant

SELECT DISTINCT
    SoldAsVacant
FROM
    nashville_housing; 

   SELECT DISTINCT
    CASE SoldAsVacant
        WHEN 'Y' THEN 'Yes'
        WHEN 'N' THEN 'No'
        ELSE SoldAsVacant
    END AS SoldAsVacant
FROM
    nashville_housing;
    
UPDATE nashville_housing 
SET 
    SoldAsVacant = CASE SoldAsVacant
        WHEN 'Y' THEN 'Yes'
        WHEN 'N' THEN 'No'
        ELSE SoldAsVacant
    END;

-- Showing Dublicates 

with cte as (
select * , row_number() over ( partition by ParcelId
,PropertyAddress
,SalePrice,
SaleDate
,LegalReference order by UniqueID)row_num
from nashville_housing
)
select * 
from cte
 where row_num > 1;




