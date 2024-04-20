select * 
from nashvilleHousing 

--Standardize Date Format
select SaleDAteConverted,convert(date,SaleDate)
from nashvilleHousing 

Update nashvilleHousing
Set SaleDate=Convert(date,SaleDate)
-- as this method is not working

Alter table nashvilleHousing
Add SaleDAteConverted date;


Update nashvilleHousing
Set SaleDAteConverted=Convert(date,SaleDate)

Alter table nashvilleHousing
Drop column SaleDate ;


--Populate the property address
--here some same parcel id has property addres null,so we are going give address to the null
--so join the same table on parcel id 
--unique ID id diffreant for all
select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress,ISNULL(a.PropertyAddress,b.PropertyAddress)
from nashvilleHousing a
join nashvilleHousing b
on a.ParcelID=b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

--to update
update a
set PropertyAddress=ISNULL(a.PropertyAddress,b.PropertyAddress)
from nashvilleHousing a
join nashvilleHousing b
on a.ParcelID=b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null


--breaking Address into individual columns
select PropertyAddress
from nashvilleHousing 

select substring(PropertyAddress,1,charindex(',',PropertyAddress)-1) AS Splitaddress,
substring(PropertyAddress,charindex(',',PropertyAddress)+1,len(PropertyAddress)) AS Splitcity
from nashvilleHousing 

--t0 update
Alter table nashvilleHousing 
Add Splitaddress nvarchar(255);

update nashvilleHousing 
set Splitaddress=substring(PropertyAddress,1,charindex(',',PropertyAddress)-1)

Alter table nashvilleHousing 
Add Splitcity nvarchar(255);

update nashvilleHousing 
Set Splitcity =substring(PropertyAddress,charindex(',',PropertyAddress)+1,len(PropertyAddress))

select *
from nashvilleHousing 

--using parsename to split
select parsename(replace(OwnerAddress,',','.'),3),
parsename(replace(OwnerAddress,',','.'),2),
parsename(replace(OwnerAddress,',','.'),1)
from nashvilleHousing
where OwnerAddress is not null

--to update

Alter table nashvilleHousing 
Add Splitowneraddress nvarchar(255);

update nashvilleHousing 
Set Splitowneraddress =parsename(replace(OwnerAddress,',','.'),3)

Alter table nashvilleHousing 
Add Splitownercity  nvarchar(255);


update nashvilleHousing 
Set Splitownercity=parsename(replace(OwnerAddress,',','.'),2)

Alter table nashvilleHousing 
Add Splitownerstate  nvarchar(255);

update nashvilleHousing 
Set Splitownerstate=parsename(replace(OwnerAddress,',','.'),1)

select * 
from nashvilleHousing 



--change n to no and y to yes

select distinct(SoldAsVacant),count(SoldAsVacant) 
from nashvilleHousing 
group by SoldAsVacant
order by 2

select SoldAsVacant,
Case when SoldAsVacant ='N' then 'NO'
     when SoldAsVacant='Y' then 'YES'
	 Else SoldAsVacant
end
from nashvilleHousing

update nashvilleHousing
SET SoldAsVacant=Case when SoldAsVacant ='N' then 'NO'
     when SoldAsVacant='Y' then 'YES'
	 Else SoldAsVacant
end
from nashvilleHousing



--Remove duplicates
--here cte is used because to take row number >1 beacause without it may show error
--we checked the the address date etc which are same and gave ROW_NUMBER() to get the count
--so rownumbwr-2 means its being repeated,so all above 1 is deleted
with RowNUmCTE as(
select *,
         ROW_NUMBER() over (
		 partition by ParcelID,
		 PropertyAddress,
		 SalePrice,
		 SaleDAteConverted,
		 LegalReference
		 order by UniqueID) as  row_num
from nashvilleHousing)
Delete
from RowNUmCTE
where row_num >1
--order by propertyAddress



--Deleting unused column
alter table nashvilleHousing
Drop column PropertyAddress,OwnerAddress,TaxDistrict