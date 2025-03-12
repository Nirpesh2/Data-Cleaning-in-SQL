# Layoffs Data Cleaning Project

This project demonstrates my SQL skills by cleaning and standardizing a dataset of company layoffs. The goal was to prepare the raw data for analysis by removing duplicates, standardizing entries, handling null values, and formatting columns appropriately.

## Objective
- Clean the `layoffs.csv` dataset to ensure data quality and consistency.
- Perform data cleaning steps such as duplicate removal, standardization, null handling, and column formatting.

## Dataset
- **File**: `layoffs.csv`
- **Description**: Contains information on layoffs across various companies, including company name, location, industry, total laid off, percentage laid off, date, stage, country, and funds raised.
- **Source**: Kaggle

## Tools
- **SQL**: Used for all data cleaning operations (executed in [specify your SQL environment, e.g., MySQL, PostgreSQL, SQLite]).

## Cleaning Process
1. **Staging Tables**:
   - Created `layoffs_staging` and `layoffs_staging2` tables to work on a copy of the raw data.
2. **Remove Duplicates**:
   - Identified duplicates using `ROW_NUMBER()` partitioned by all key columns.
   - Deleted records where `row_num > 1`.
3. **Standardize Data**:
   - Trimmed whitespace from `company` names.
   - Unified variations of "Crypto" in the `industry` column.
   - Removed trailing periods from `country` (e.g., "United States." to "United States").
   - Converted `date` from text to DATE format using `STR_TO_DATE`.
4. **Handle Null/Blank Values**:
   - Converted blank `industry` values to `NULL`.
   - Populated missing `industry` values by joining with records of the same company.
   - Removed rows where both `total_laid_off` and `percentage_laid_off` were `NULL`.
5. **Remove Unnecessary Columns**:
   - Dropped the `row_num` column after cleaning.

## Key Queries
- **View Duplicates**:
  ```sql
  WITH duplicate_cte AS (
      SELECT *,
          ROW_NUMBER() OVER (
              PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions
          ) AS row_num
      FROM layoffs_staging
  )
  SELECT * FROM duplicate_cte WHERE row_num > 1;
