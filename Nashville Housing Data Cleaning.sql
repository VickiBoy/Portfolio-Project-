Select *
from NashvilleHousing

--Let's make SaleDate standard time
Select SaleDate, CONVERT(Date, SaleDate) 
from NashvilleHousing

update NashvilleHousing
set SaleDate = CONVERT(Date, SaleDate)

Alter table NashvilleHousing
Add StandardSaleDate Date

update NashvilleHousing
set StandardSaleDate = CONVERT(Date, SaleDate)

Select StandardSaleDate, CONVERT(Date, SaleDate) 
from NashvilleHousing

--Update Property Address data
Select [UniqueID ], ParcelID, PropertyAddress
from NashvilleHousing

--Property with the same parcelid has the same address
--We can put those with null with the corressponding address

Select a.[UniqueID ], a.ParcelID, a.PropertyAddress, b.[UniqueID ], b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
from NashvilleHousing a
join NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
	where a.PropertyAddress is null

update a
set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from NashvilleHousing a
join NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
	where a.PropertyAddress is null;

--Dividing Address into individual column (Address, State, City)
Select PropertyAddress
from NashvilleHousing

Select SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) Address,
		SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) City
from NashvilleHousing

Alter table NashvilleHousing
Add PropertySplitAddress nvarchar(255)

update NashvilleHousing
set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

Alter table NashvilleHousing
Add PropertySplitCity nvarchar(255)

update NashvilleHousing
set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

Select *
from NashvilleHousing

--Doing the same change to ownerAddress
Select OwnerAddress
from NashvilleHousing

Select PARSENAME(Replace(OwnerAddress, ',','.'), 3),
PARSENAME(Replace(OwnerAddress, ',','.'), 2),
PARSENAME(Replace(OwnerAddress, ',','.'), 1)
from NashvilleHousing

Alter table NashvilleHousing
Add OwnerStreet nvarchar(255)

Alter table NashvilleHousing
Add OwnerCity nvarchar(255)

Alter table NashvilleHousing
Add OwnerState nvarchar(255)

update NashvilleHousing
set OwnerStreet = PARSENAME(Replace(OwnerAddress, ',','.'), 3)

update NashvilleHousing
set OwnerCity = PARSENAME(Replace(OwnerAddress, ',','.'), 2)

update NashvilleHousing
set OwnerState = PARSENAME(Replace(OwnerAddress, ',','.'), 1)

Select *
from NashvilleHousing

--Updating Outliers in SoldAsVacant

Select distinct (SoldAsVacant), COUNT(SoldAsVacant)
from NashvilleHousing
group by SoldAsVacant
order by 2

Select SoldAsVacant,
Case when SoldAsVacant = 'N' then 'No'
	 when SoldAsVacant = 'Y' then 'Yes'
	 else SoldAsVacant
	 End
from NashvilleHousing

update NashvilleHousing
set SoldAsVacant = Case when SoldAsVacant = 'N' then 'No'
	 when SoldAsVacant = 'Y' then 'Yes'
	 else SoldAsVacant
	 End


--Remove duplicate data
With RowNumCTE as (
Select *, 
	ROW_NUMBER() over(
	partition by ParcelID,
				PropertyAddress,
				SaleDate,
				SalePrice,
				LegalReference,
				BuildingValue
				order by 
					UniqueID
					) row_num

from NashvilleHousing
)

select *
from RowNumCTE
--where row_num > 1

--Delete obsolete columns
Select *
from NashvilleHousing

Alter Table NashvilleHousing
Drop column OwnerAddress, PropertyAddress

Alter Table NashvilleHousing
Drop column SaleDate

