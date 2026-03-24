--Data Cleaning--
Select * from Project.dbo.NashvilleHousing;


--Standardize Date Format
Select  saleDate from Project.dbo.NashvilleHousing;
select SaleDate,CONVERT(date,SaleDate) as SalesDateFormat from Project.dbo.NashvilleHousing;

alter table  Project.dbo.NashvilleHousing
add ConvertedSalesDate Date;
 
update Project.dbo.NashvilleHousing
set ConvertedSalesDate=CONVERT(date,SaleDate) 

--Populate Property Address Data--
select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress, isnull(a.PropertyAddress,b.PropertyAddress) as populatedpropertyaddress
from Project.dbo.NashvilleHousing a
join Project.dbo.NashvilleHousing b
on a.ParcelID=b.ParcelID and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is Null

update a
set propertyAddress=isnull(a.PropertyAddress,b.PropertyAddress)
from Project.dbo.NashvilleHousing a
join Project.dbo.NashvilleHousing b
on a.ParcelID=b.ParcelID and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is Null

select * from Project.dbo.NashvilleHousing;

--Breaking out Address into individual Columns(Address,City,State)--
select propertyAddress from Project.dbo.NashvilleHousing;

select  substring(propertyAddress,1,charindex(',',propertyAddress)-1) as Address,
substring(propertyAddress,charindex(',',propertyAddress)+1,len(propertyAddress)) as City
from Project.dbo.NashvilleHousing 

alter table Project.dbo.NashvilleHousing
add PropertySplitAddress varchar(255);

update Project.dbo.NashvilleHousing
set PropertySplitAddress=substring(propertyAddress,1,charindex(',',propertyAddress)-1)

alter table Project.dbo.NashvilleHousing
add PropertySplitCity varchar(255);

update Project.dbo.NashvilleHousing
set PropertySplitCity=substring(propertyAddress,charindex(',',propertyAddress)+1,len(propertyAddress))

select * from Project.dbo.NashvilleHousing;

--Breaking out OwnerAddress into individual Columns(Address,City,State)--
select owneraddress from Project.dbo.NashvilleHousing;

select PARSENAME(REPLACE(OwnerAddress,',' , '.'),1),
PARSENAME(REPLACE(OwnerAddress,',' , '.'),2),
PARSENAME(REPLACE(OwnerAddress,',' , '.'),3)
from Project.dbo.NashvilleHousing;

select PARSENAME(REPLACE(OwnerAddress,',' , '.'),3),
PARSENAME(REPLACE(OwnerAddress,',' , '.'),2),
PARSENAME(REPLACE(OwnerAddress,',' , '.'),1)
from Project.dbo.NashvilleHousing;


alter table Project.dbo.NashvilleHousing
add newOwnerAddress varchar(255);

update Project.dbo.NashvilleHousing
set newOwnerAddress=PARSENAME(REPLACE(OwnerAddress,',' , '.'),3)

alter table Project.dbo.NashvilleHousing
add OwnerCity varchar(255);

update Project.dbo.NashvilleHousing
set OwnerCity=PARSENAME(REPLACE(OwnerAddress,',' , '.'),2)

alter table Project.dbo.NashvilleHousing
add OwnerState varchar(255);

update Project.dbo.NashvilleHousing
set OwnerState=PARSENAME(REPLACE(OwnerAddress,',' , '.'),1)

select *from Project.dbo.NashvilleHousing;

--Change Y and N to Yes and No in "Sold as Vacant" field
select distinct SoldasVacant, count(SoldAsVacant) as CountOfSoldasVacant
from Project.dbo.NashvilleHousing
group by SoldasVacant
order by 2;

select SoldasVacant,
case
when SoldasVacant ='Y' then 'Yes'
when SoldasVacant ='N' then 'No'
else SoldasVacant
end as NewSoldasVacant
from Project.dbo.NashvilleHousing


alter table Project.dbo.NashvilleHousing
add NewSoldasVacant varchar(255);

update Project.dbo.NashvilleHousing
set NewSoldasVacant=case
when SoldasVacant ='Y' then 'Yes'
when SoldasVacant ='N' then 'No'
else SoldasVacant
end

select *from Project.dbo.NashvilleHousing;

--Remove Duplicates--

with RownumberCTE as(
select *,ROW_NUMBER() over 
(partition by ParcelId,PropertyAddress,SalePrice,SaleDate,LegalReference order by uniqueID) row_number
from Project.dbo.NashvilleHousing
)
delete from RownumberCTE
where row_number>1

with RownumberCTE as(
select *,ROW_NUMBER() over 
(partition by ParcelId,PropertyAddress,SalePrice,SaleDate,LegalReference order by uniqueID) row_number
from Project.dbo.NashvilleHousing
)
select * from RownumberCTE
where row_number>1
order by PropertyAddress;

--Delete Unused Columns--
alter table Project.dbo.NashvilleHousing
drop column OwnerAddress,TaxDistrict,PropertyAddress;

select * from Project.dbo.NashvilleHousing

alter table Project.dbo.NashvilleHousing
drop column SaleDate;

select *from Project.dbo.NashvilleHousing

