-- Data Cleaning


SELECT * 
From Layoffs;


-- 1. Remove Duplicates
-- 2. Standardize the Data
-- 3. Null Values or blank values
-- 4. Remove any unnecessary columns or rows


-- creating a staging table
Create Table layoffs_staging
Like layoffs;

-- viewing the staging table
SELECT * 
From layoffs_staging;

-- inserting data from main table to staging table
Insert into layoffs_staging
Select  * from layoffs;

-- viewing data of staging table
SELECT * 
From layoffs_staging;

-- Giving row number to the data so that we can know the duplicates
SELECT *,
row_number() OVER (
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num 
From layoffs_staging;


--  creating CTE to view duplicate datas
WITH duplicate_cte AS
(
	SELECT *,
	row_number() OVER (
	PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num  
	From layoffs_staging
)
Select * from duplicate_cte
where row_num > 1;

 -- random data view
Select * from layoffs_staging
where company = 'Casper';

--  Creating another staging table so we can delete duplicate records
CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` INT 
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- viewing staging2 table
SELECT * 
From layoffs_staging2;

-- inserting datas into staging2 table plus adding row number column
Insert into layoffs_staging2
SELECT *,
row_number() OVER (
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num  
From layoffs_staging;


-- viewing the duplicate records in staging2
SELECT * 
From layoffs_staging2
where row_num > 1;

-- deleting the duplicate records
Delete 
from layoffs_staging2 where row_num > 1;

-- viewing the duplicate records again to ensure they are deleted
SELECT * 
From layoffs_staging2
where row_num > 1;


-- Standardizing Data

Select company, trim(company)
from layoffs_staging2;

-- Updating company column or standardizing company column
Update layoffs_staging2
SET company = trim(company);

-- viewing the staging2 table after update to ensure
SELECT * 
From layoffs_staging2;


-- viewing distinct industries to find out there are null, blank and multiple Crypto , Crypto Currency kinda datas
Select distinct industry 
from layoffs_staging2
Order by 1;

-- viewing datas that have industries like crypto
Select * 
from layoffs_staging2
where industry like 'Crypto%';

-- Updating table to update industry to Crypto
Update layoffs_staging2
set industry = 'Crypto'
where industry like 'Crypto%';

-- Viewing datas that have industy Crypto again to ensure its updated
Select * 
from layoffs_staging2
where industry like 'Crypto%';

-- viewing distinct location
SELECT distinct location
from layoffs_staging2
order by 1;
-- everything looks good with location


-- viewing distinct country
SELECT distinct country
from layoffs_staging2
order by 1;

SELECT distinct country, trim(Trailing '.' from Country)
From layoffs_staging2
Order by 1;

--  updating table to fix Double United States in country column
Update layoffs_staging2
SET country = trim(Trailing '.' from Country)
where country like 'United States%';

select * from layoffs_staging2;

-- Now we have to change date column to date format as it is in text format atm

select `date`,
str_to_date(`date`,'%m/%d/%Y')
FROM layoffs_staging2;

-- Updating table to convert date column to date format
Update layoffs_staging2
Set `date` = str_to_date(`date`,'%m/%d/%Y');

-- checking date column to ensure its updated
select `date`
FROM layoffs_staging2;

-- now converting datatype of date column 
ALTER TABLE layoffs_staging2
modify column `date` DATE;

-- viewing null values of total_laid off and percentage_laid_off 
select * from layoffs_staging2
where total_laid_off is NULL
and percentage_laid_off is NULL;

-- viewing datas having industry value null or blank
select * from layoffs_staging2
where industry is NULL
or industry = '';

-- viewing data with company airbnb 
select * from layoffs_staging2
where company = 'Airbnb';

select * 
from layoffs_staging2 t1
join layoffs_staging2 t2
	on t1.company = t2.company
    and t1.location = t2.location
where (t1.industry is NULL or t1.industry = '')
and t2.industry is not null;

Update layoffs_staging2 t1 
Join layoffs_staging2 t2
	on t1.company = t2.company
SET t1.industry = t2.industry
where (t1.industry is NULL or t1.industry = '')
and t2.industry is not null;
-- this didn't work because there were blank values and blank values are not null so we will try to update blank values of industry to null 


UPDATE layoffs_staging2
SET industry = NULL
where industry = '';


--  now we try again to update  industry values
Update layoffs_staging2 t1 
Join layoffs_staging2 t2
	on t1.company = t2.company
SET t1.industry = t2.industry
where t1.industry is NULL
and t2.industry is not null;

-- deleting datas where total laid off and percentage laid off are null because we dont need those datas
delete from layoffs_staging2
where total_laid_off is NULL
and percentage_laid_off is NULL;

Select * from 
layoffs_staging2;

Alter table layoffs_staging2
drop column row_num;
  
