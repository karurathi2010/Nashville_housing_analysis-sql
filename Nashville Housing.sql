SELECT * FROM "Nashville_housing_data";

-- Standardise date format

SELECT "SaleDate","SaleDate"::DATE
FROM "Nashville_housing_data";

UPDATE "Nashville_housing_data"
SET "SaleDate"="SaleDate"::DATE;

ALTER TABLE "Nashville_housing_data"
ALTER COLUMN "SaleDate" TYPE DATE USING "SaleDate"::DATE;
 
SELECT column_name
FROM information_schema.columns
WHERE table_name = 'Nashville_housing_data';

-- Populating property adddress column

SELECT a."ParcelID",a."PropertyAddress",b."ParcelID",b."PropertyAddress",COALESCE(a."PropertyAddress",b."PropertyAddress")
FROM "Nashville_housing_data" a
JOIN "Nashville_housing_data" b
ON a."ParcelID"=b."ParcelID"
AND a."UniqueID "<>b."UniqueID "
WHERE a."PropertyAddress" IS NULL

UPDATE "Nashville_housing_data"
SET "PropertyAddress"=COALESCE(a."PropertyAddress",b."PropertyAddress")
FROM "Nashville_housing_data" a
JOIN "Nashville_housing_data" b
ON a."ParcelID"=b."ParcelID"
AND a."UniqueID "<>b."UniqueID "
WHERE a."PropertyAddress" IS NULL


-- Breaking the PropertyAddress column into seperate columns(Address,City,State)


SELECT SPLIT_PART("PropertyAddress",',',1) AS Street,
       SPLIT_PART("PropertyAddress",',',2) AS City
FROM "Nashville_housing_data";

ALTER TABLE "Nashville_housing_data"
ADD COLUMN Street VARCHAR;

UPDATE "Nashville_housing_data"
SET Street=SPLIT_PART("PropertyAddress",',',1);
	   
ALTER TABLE "Nashville_housing_data"
ADD COLUMN City VARCHAR;

UPDATE "Nashville_housing_data"
SET City=SPLIT_PART("PropertyAddress",',',2);

-- Breaking the OwnerAddress column into seperate columns(Address,City,State)


SELECT SPLIT_PART("OwnerAddress",',',1) AS Street,
		SPLIT_PART("OwnerAddress",',',2) AS City,
		SPLIT_PART("OwnerAddress",',',-1) AS State
      
FROM "Nashville_housing_data";

ALTER TABLE "Nashville_housing_data"
ADD COLUMN Owner_street VARCHAR;

UPDATE "Nashville_housing_data"
SET Owner_street=SPLIT_PART("OwnerAddress",',',1);

ALTER TABLE "Nashville_housing_data"
ADD COLUMN Owner_city VARCHAR;

UPDATE "Nashville_housing_data"
SET Owner_city=SPLIT_PART("OwnerAddress",',',2);

ALTER TABLE "Nashville_housing_data"
ADD COLUMN Owner_state VARCHAR;

UPDATE "Nashville_housing_data"
SET Owner_state=SPLIT_PART("OwnerAddress",',',-1);

-- Change Yes and No values in "SoldAsVacant" column to Y and N.

UPDATE "Nashville_housing_data"
SET "SoldAsVacant"= CASE
WHEN "SoldAsVacant"='Yes' THEN 'Y'
ELSE 'N'
END 

SELECT DISTINCT "SoldAsVacant",COUNT("SoldAsVacant") 
FROM "Nashville_housing_data" 
GROUP BY DISTINCT "SoldAsVacant";

--Removing duplicates.

WITH dupe AS (
	SELECT ctid,
ROW_NUMBER() OVER(
	PARTITION BY "ParcelID",
	"PropertyAddress",
	"LegalReference" 
	ORDER BY "UniqueID ") AS row_num
FROM "Nashville_housing_data"
ORDER BY "UniqueID "
)

DELETE FROM "Nashville_housing_data"
WHERE ctid IN(SELECT ctid FROM dupe WHERE row_num>1);

--Remove the unused columns

ALTER TABLE "Nashville_housing_data"
DROP COLUMN "PropertyAddress",
DROP COLUMN "SaleDate",
DROP COLUMN "OwnerAddress",
DROP COLUMN "TaxDistrict";














