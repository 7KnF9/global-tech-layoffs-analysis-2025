-- Script Name: Layoffs Dataset Cleaning
-- Author: Raj Ayush Nandi
-- Date: 2025-07-20
-- Description: Clean, dedupe, and standardize layoffs data for analysis.

-- Preview raw dataset
SELECT *
FROM layoffs;

-- ======================================================
-- Data Cleaning Workflow
-- ======================================================
-- 1. Create staging dataset (to preserve raw data)
-- 2. Standardize column names and data types
-- 3. Remove unnecessary columns
-- 4. Identify and remove duplicates
-- 5. Standardize values (trim spaces, format dates, etc.)
-- 6. Handle null / blank values (Populate if Possible)
-- ======================================================

-- 1. Create staging dataset
CREATE TABLE layoffs_staging
LIKE layoffs; 

-- Insert raw data into staging
INSERT layoffs_staging
SELECT * 
FROM layoffs;

-- 2. Standardize column names
ALTER TABLE layoffs_staging
RENAME COLUMN `ï»¿Company` TO company;
ALTER TABLE layoffs_staging
RENAME COLUMN `Location HQ` TO location;
ALTER TABLE layoffs_staging
RENAME COLUMN `# Laid Off` TO num_laid_off;
ALTER TABLE layoffs_staging
RENAME COLUMN `Date` TO date;
ALTER TABLE layoffs_staging
RENAME COLUMN `%` TO percentage_laid_off;
ALTER TABLE layoffs_staging
RENAME COLUMN `Industry` TO industry;
ALTER TABLE layoffs_staging
RENAME COLUMN `Stage` TO stage;
ALTER TABLE layoffs_staging
RENAME COLUMN `$ Raised (mm)` TO fund_raised_mn;
ALTER TABLE layoffs_staging
RENAME COLUMN `Country` TO country;
ALTER TABLE layoffs_staging
RENAME COLUMN `Date Added` TO date_added;

-- Remove special characters from numeric fields
UPDATE layoffs_staging
SET percentage_laid_off = REPLACE(percentage_laid_off, '%', '');
UPDATE layoffs_staging
SET fund_raised_mn = REPLACE(fund_raised_mn, '$', '');

-- Drop unused columns
ALTER TABLE layoffs_staging
DROP COLUMN `Source`;
ALTER TABLE layoffs_staging
DROP COLUMN `date_added`;

-- Preview updated staging dataset
SELECT *
FROM layoffs_staging;

-- 4. Identify duplicates
WITH duplicate_cte AS
(
SELECT *, 
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, 
num_laid_off, percentage_laid_off, `date`, 
country, stage, fund_raised_mn) AS row_num
FROM layoffs_staging
)
SELECT * 
FROM duplicate_cte
WHERE row_num > 1;

-- 4a. Create a second staging table to remove duplicates safely
CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `num_laid_off` text,
  `date` text,
  `percentage_laid_off` text,
  `industry` text,
  `stage` text,
  `fund_raised_mn` text,
  `country` text,
  `row_num` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Insert with row numbers
INSERT INTO layoffs_staging2
SELECT *, 
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, 
num_laid_off, percentage_laid_off, `date`, 
country, stage, fund_raised_mn) AS row_num
FROM layoffs_staging;

SELECT * 
FROM layoffs_staging2
WHERE row_num > 1;

-- Remove duplicates
DELETE FROM layoffs_staging2
WHERE row_num > 1;

-- Preview updated staging dataset
SELECT * 
FROM layoffs_staging2;

-- 5. Standardise the Data
SELECT DISTINCT company
FROM layoffs_staging2
ORDER BY 1;

UPDATE layoffs_staging2
SET company = TRIM(company); ## 17 Rows Affected

SELECT DISTINCT industry
from layoffs_staging2
ORDER BY 1;

UPDATE layoffs_staging2
SET industry = TRIM(industry);

SELECT DISTINCT location
FROM layoffs_staging2
ORDER BY 1;

-- Some entries include tags (e.g., 'Non-U.S.') to indicate regional scope.
-- Do not merge or trim these values blindly if such distinctions are relevant to the analysis.
UPDATE layoffs_staging2
SET location = TRIM(location);

SELECT DISTINCT country
FROM layoffs_staging2
ORDER BY 1;

UPDATE layoffs_staging2
SET country= TRIM(country);

-- Convert date column to proper DATE type
SELECT `date`,
STR_TO_DATE(`date`, '%m/%d/%Y')
FROM layoffs_staging2;

UPDATE layoffs_staging2
set `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

-- Date Column Definition Change from `text` to `date`

ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;

SELECT *
FROM layoffs_staging2;

-- 6. Handle null / blank values
-- Set blanks to NULL
SELECT *
FROM layoffs_staging2
WHERE industry IS NULL
OR TRIM(industry) = '';

SELECT *
FROM layoffs_staging2
WHERE company = 'Appsmith'; ## Single Layoff So Cant Populate Industry


-- If Needed to Populate USE JOIN

-- # STEP 1
## Set the Blanks to Nulls
UPDATE layoffs_staging2
SET industry = NULL
WHERE industry = '';

SELECT *
FROM world_layoffs.layoffs_staging2
WHERE industry IS NULL 
OR TRIM(industry) = ''
ORDER BY industry;

-- Populate missing industries using self-join where possible
SELECT *
FROM layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company = t2.company
WHERE t1.industry IS NULL
AND t2.industry IS NOT NULL; ## To Check if we get output

UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 t2
ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL
AND t2.industry IS NOT NULL;

SELECT *
FROM layoffs_staging2;

-- Remove rows with no layoff data
UPDATE layoffs_staging2
SET num_laid_off = NULL
WHERE TRIM(num_laid_off) = '';

UPDATE layoffs_staging2
SET percentage_laid_off = NULL
WHERE TRIM(percentage_laid_off) = '';

SELECT *
FROM layoffs_staging2
WHERE num_laid_off IS NULL
AND percentage_laid_off IS NULL;

DELETE FROM layoffs_staging2
WHERE num_laid_off IS NULL
AND percentage_laid_off IS NULL;

-- 7. Finalize column data types
-- Convert percentage to float (0–1 scale)
UPDATE layoffs_staging2
SET percentage_laid_off = ROUND(CAST(percentage_laid_off AS DECIMAL(5,2)) / 100,2);

-- Drop helper column
ALTER TABLE layoffs_staging2
DROP COLUMN row_num;

-- Handle blank fund_raised_mn values
UPDATE layoffs_staging2
SET fund_raised_mn = NULL
WHERE TRIM(fund_raised_mn) = '';

-- Convert numeric columns
ALTER TABLE layoffs_staging2
MODIFY COLUMN fund_raised_mn INT;

## Changing 'percentage_laid_off' column into decimal
UPDATE layoffs_staging2
SET percentage_laid_off = ROUND(CAST(percentage_laid_off AS DECIMAL(5,2)) / 100,2);

## Changing Column Defination of 'percentage_laid_off' and 'num_laid_off'
ALTER TABLE layoffs_staging2
MODIFY COLUMN num_laid_off INT; ## Convert num_laid_off column to INT

ALTER TABLE layoffs_staging2
MODIFY COLUMN percentage_laid_off FLOAT; ## Convert percentage_laid_off column to FLOAT

-- Final cleaned dataset
SELECT *
FROM layoffs_staging2;