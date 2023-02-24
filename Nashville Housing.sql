/*
Cleaning Data in SQL Queries
*/

select *
from portfolioproject..NashvilleHousing
where uniqueid = 54043;

-- Standardize Date Format

select saledateconverted , convert(date , saledate)
from portfolioproject..nashvillehousing    --This is a preferred approach to convert the dates

update portfolioproject..nashvillehousing
set saledate =  convert(date , saledate)


-- If it doesn't Update properly

alter table portfolioproject..nashvillehousing
add saledateconverted date;

update portfolioproject..nashvillehousing
set saledateconverted =  convert(date , saledate)


 --------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data

select *
from portfolioproject..nashvillehousing
--where propertyaddress is null
order by parcelid

select a.parcelid , a.propertyaddress , b.parcelid , b.propertyaddress , isnull(a.propertyaddress ,b.propertyaddress)  --isnull is used to check if null is present or not
from portfolioproject..nashvillehousing as a
join portfolioproject..nashvillehousing as b
on a.parcelid = b.parcelid
and a.uniqueid <> b.uniqueid
--where a.propertyaddress is null

update a
set propertyaddress = isnull(a.propertyaddress ,b.propertyaddress) 
from portfolioproject..nashvillehousing as a
join portfolioproject..nashvillehousing as b
on a.parcelid = b.parcelid
and a.uniqueid <> b.uniqueid
where a.propertyaddress is null




-- Breaking out Address into Individual Columns (Address, City, State)

select Propertyaddress
from portfolioproject..nashvillehousing

select 
SUBSTRING(Propertyaddress, 1 , CHARINDEX(',' , Propertyaddress)-1) as Address , 
SUBSTRING(Propertyaddress, CHARINDEX(',' , Propertyaddress)+1, LEN(Propertyaddress)) as Address
from portfolioproject..nashvillehousing

alter table portfolioproject..nashvillehousing
add propertysplitaddress nvarchar(255);

update portfolioproject..nashvillehousing
set propertysplitaddress =  SUBSTRING(Propertyaddress, 1 , CHARINDEX(',' , Propertyaddress)-1)

alter table portfolioproject..nashvillehousing
add propertysplitcity nvarchar(255);

update portfolioproject..nashvillehousing
set propertysplitcity =  SUBSTRING(Propertyaddress, CHARINDEX(',' , Propertyaddress)+1, LEN(Propertyaddress))

select *
from portfolioproject..nashvillehousing

--We are doing the same task but for Owneraddress (Splitting the state , city and address)
select 
PARSENAME(Replace(owneraddress, ',' ,'.'),3) ,
PARSENAME(Replace(owneraddress, ',' ,'.'),2) ,
PARSENAME(Replace(owneraddress, ',' ,'.'),1)
from portfolioproject..nashvillehousing

alter table portfolioproject..nashvillehousing
add ownersplitaddress nvarchar(255);

update portfolioproject..nashvillehousing
set ownersplitaddress =  PARSENAME(Replace(owneraddress, ',' ,'.'),3)

alter table portfolioproject..nashvillehousing
add ownersplitcity nvarchar(255);

update portfolioproject..nashvillehousing
set ownersplitcity =  PARSENAME(Replace(owneraddress, ',' ,'.'),2)

alter table portfolioproject..nashvillehousing
add ownersplitstate nvarchar(255);

update portfolioproject..nashvillehousing
set ownersplitstate =  PARSENAME(Replace(owneraddress, ',' ,'.'),1)


select *
from portfolioproject..nashvillehousing


-- Change Y and N to Yes and No in "Sold as Vacant" field

--checking the nos. of Y,N, yes and no

select distinct(soldasvacant), count(soldasvacant)
from portfolioproject..nashvillehousing
group by soldasvacant
order by 2

select soldasvacant,
case when soldasvacant  = 'Y' then 'YES'
	 when soldasvacant	= 'N' then 'NO'
	 else soldasvacant
end 
from portfolioproject..nashvillehousing

Update portfolioproject..nashvillehousing
Set soldasvacant = case when soldasvacant  = 'Y' then 'YES'
						when soldasvacant	= 'N' then 'NO'
						else soldasvacant
						end 



-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

 --using cte 

 WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertysplitAddress,
				 SalePrice,
				 SaleDateconverted,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From PortfolioProject..NashvilleHousing
--order by ParcelID
)
Select *
From RowNumCTE
Where row_num > 1
Order by PropertysplitAddress



Select *
From PortfolioProject..NashvilleHousing


---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns


select *
from portfolioproject..nashvillehousing

alter table portfolioproject..nashvillehousing
drop column propertyaddress , owneraddress , taxdistrict , saledate

