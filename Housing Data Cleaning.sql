SELECT * FROM VashvilleHousing
select VERSION()
desc VashvilleHousing

----------------------------------------------------------------
-- Standardize Date Format
SELECT SaleDate,
STR_TO_DATE(SaleDate,'%M%d,%Y') 
from VashvilleHousing

Update VashvilleHousing
set SaleDate = STR_TO_DATE(SaleDate,'%M%d,%Y') 

alter table VashvilleHousing
add SaleDateConverted Date

update VashvilleHousing
set SaleDateConverted = SaleDate

---------------------------------------------------------
-- Populate Property Address Data
select v1.ParcelID,v1.PropertyAddress,v2.ParcelID, 
       v2.PropertyAddress,
			 ifnull(v1.PropertyAddress,v2.PropertyAddress)
from VashvilleHousing v1 join VashvilleHousing v2
on v1.ParcelID = v2.ParcelID
and v1.uniqueId <> v2.uniqueId
where v1.PropertyAddress  is null


update VashvilleHousing v1 
			inner join VashvilleHousing v2
			on v1.ParcelID = v2.ParcelID
			and v1.uniqueId <> v2.uniqueId
			
set v1.PropertyAddress = ifnull(v1.PropertyAddress,v2.PropertyAddress)
where v1.PropertyAddress  is null

-------------------------------------------------------------------------------------------------
-- breaking out address into individual columns. (Address, City, State)

SELECT SUBSTRING_INDEX(PropertyAddress,',',1) as Address,
				SUBSTRING_INDEX(PropertyAddress,',',-1) as address
 FROM VashvilleHousing


alter table VashvilleHousing
add PropertySplitAddress varchar(255);

update VashvilleHousing
set PropertySplitAddress = SUBSTRING_INDEX(PropertyAddress,',',1) 

alter table VashvilleHousing
add PropertySplitCity varchar(255)
	  
update VashvilleHousing
set PropertySplitCity = SUBSTRING_INDEX(PropertyAddress,',',-1) 

-- OwnerAddress

SELECT OwnerAddress,
			SUBSTRING_INDEX(OwnerAddress,',',1) as address,
			SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress,',',-2),',',1) as city,
			SUBSTRING_INDEX(OwnerAddress,',',-1)  as state
FROM VashvilleHousing

alter table VashvilleHousing
add OwnerSplitAddress varchar(255);

update VashvilleHousing
set OwnerSplitAddress = SUBSTRING_INDEX(OwnerAddress,',',1)

alter table VashvilleHousing
add OwnerSplitCity varchar(255)
	  
update VashvilleHousing
set OwnerSplitCity = 	SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress,',',-2),',',1)

alter table VashvilleHousing
add OwnerSplitState varchar(255)
	  
update VashvilleHousing
set OwnerSplitState = SUBSTRING_INDEX(OwnerAddress,',',-1)

-----------------------------------------------------------------------------------

-- Change Y and N to Yes and No in "Sold as vacant"


SELECT distinct(SoldAsVacant), count(SoldAsVacant)
 FROM VashvilleHousing
 group by SoldAsVacant
 order by 2
 
 select SoldAsVacant,
				case when SoldAsVacant = 'Y' then 'Yes'
				     when SoldAsVacant = 'N' then 'No'
						 else SoldAsVacant
			  end
 FROM VashvilleHousing
 
 update VashvilleHousing
 set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
				                 when SoldAsVacant = 'N' then 'No'
						              else SoldAsVacant
			                end
											
-----------------------------------------------------------------------
-- remove duplicates
 
with RowNumCTE as
(
SELECT *,
row_number() over(partition by 
									ParcelID,
									PropertyAddress,
									SalePrice,
									SaleDate,
									LegalReference
									order by UniqueID
                  ) rn
FROM VashvilleHousing 
 ) 

delete 
FROM RowNumCTE 
where rn >1 


----------------------------------------------------------------------------------
-- delete unused columns

alter table VashvilleHousing 

drop column TaxDistrict,
drop column PropertyAddress;

