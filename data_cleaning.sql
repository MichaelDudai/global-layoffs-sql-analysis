-- =========================================================
-- Data Cleaning Project: Global Layoffs Dataset
-- =========================================================
-- Description:
-- This SQL script cleans and prepares a global layoffs dataset
-- for analysis. The workflow includes:
-- 1. Creating staging tables
-- 2. Identifying and removing duplicates
-- 3. Standardizing text fields
-- 4. Converting dates into SQL DATE format
-- 5. Handling missing values
-- 6. Removing non-informative records
--
-- Dataset scope:
-- Global layoffs data from 2020 to early 2023
-- =========================================================


-- =========================================================
-- 1. Inspect the raw dataset
-- =========================================================
SELECT *
FROM layoffs;


-- =========================================================
-- 2. Create a staging table to preserve the raw data
-- =========================================================
CREATE TABLE layoffs_staging LIKE layoffs;

INSERT INTO layoffs_staging
SELECT *
FROM layoffs;


-- =========================================================
-- 3. Identify duplicate records using ROW_NUMBER()
--    Partitioning by all relevant columns allows detection
--    of repeated rows in the dataset
-- =========================================================
SELECT *,
       ROW_NUMBER() OVER (
           PARTITION BY company, location, industry, total_laid_off,
                        percentage_laid_off, `date`, stage, country,
                        funds_raised_millions
       ) AS row_num
FROM layoffs_staging;


-- Optional inspection of a specific company
SELECT *
FROM layoffs_staging
WHERE company = 'CASPER';


-- =========================================================
-- 4. Create a second staging table with a helper column
--    for duplicate tracking
-- =========================================================
CREATE TABLE layoffs_staging2 (
    company TEXT,
    location TEXT,
    industry TEXT,
    total_laid_off INT DEFAULT NULL,
    percentage_laid_off TEXT,
    `date` TEXT,
    stage TEXT,
    country TEXT,
    funds_raised_millions INT DEFAULT NULL,
    row_num INT
) ENGINE=InnoDB
DEFAULT CHARSET=utf8mb4
COLLATE=utf8mb4_0900_ai_ci;


-- Verify table creation
SELECT *
FROM layoffs_staging2;


-- =========================================================
-- 5. Insert data into the new staging table with row numbers
-- =========================================================
INSERT INTO layoffs_staging2
SELECT *,
       ROW_NUMBER() OVER (
           PARTITION BY company, location, industry, total_laid_off,
                        percentage_laid_off, `date`, stage, country,
                        funds_raised_millions
       ) AS row_num
FROM layoffs_staging;


-- =========================================================
-- 6. Review duplicate rows
-- =========================================================
SELECT *
FROM layoffs_staging2
WHERE row_num > 1;


-- =========================================================
-- 7. Remove duplicate records
--    Keep only the first occurrence of each duplicated row
-- =========================================================
DELETE
FROM layoffs_staging2
WHERE row_num > 1;


-- Verify results after duplicate removal
SELECT *
FROM layoffs_staging2;


-- =========================================================
-- 8. Standardize company names
--    Remove leading/trailing whitespace
-- =========================================================
SELECT company, TRIM(company)
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET company = TRIM(company);


-- =========================================================
-- 9. Standardize industry values
--    Example: unify all crypto-related labels as 'crypto'
-- =========================================================
SELECT industry
FROM layoffs_staging2
ORDER BY 1;

SELECT *
FROM layoffs_staging2
WHERE industry LIKE 'crypto%';

UPDATE layoffs_staging2
SET industry = 'crypto'
WHERE industry LIKE 'crypto%';

SELECT DISTINCT industry
FROM layoffs_staging2;


-- =========================================================
-- 10. Review location values
-- =========================================================
SELECT DISTINCT location
FROM layoffs_staging2
ORDER BY 1;


-- =========================================================
-- 11. Standardize country values
--    Example: remove trailing punctuation from country names
-- =========================================================
SELECT DISTINCT country
FROM layoffs_staging2
WHERE country LIKE 'united states%';

SELECT DISTINCT country,
       TRIM(TRAILING '.' FROM country)
FROM layoffs_staging2
ORDER BY 1;

UPDATE layoffs_staging2
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'united states%';

SELECT DISTINCT country
FROM layoffs_staging2
ORDER BY 1;


-- =========================================================
-- 12. Convert the date column from text to DATE format
-- =========================================================
SELECT `date`,
       STR_TO_DATE(`date`, '%m/%d/%Y')
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;


-- =========================================================
-- 13. Identify rows with missing layoff information
-- =========================================================
SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL
  AND percentage_laid_off IS NULL;


-- =========================================================
-- 14. Convert blank industry values into NULL
-- =========================================================
UPDATE layoffs_staging2
SET industry = NULL
WHERE industry = '';


-- Optional inspection of a specific company
SELECT *
FROM layoffs_staging2
WHERE company = 'Airbnb';


-- =========================================================
-- 15. Fill missing industry values using other rows from
--     the same company and location
-- =========================================================
SELECT *
FROM layoffs_staging2 AS t1
JOIN layoffs_staging2 AS t2
    ON t1.company = t2.company
   AND t1.location = t2.location
WHERE t1.industry IS NULL
  AND t2.industry IS NOT NULL;

UPDATE layoffs_staging2 AS t1
JOIN layoffs_staging2 AS t2
    ON t1.company = t2.company
   AND t1.location = t2.location
SET t1.industry = t2.industry
WHERE t1.industry IS NULL
  AND t2.industry IS NOT NULL;


-- Review rows that still have missing industry values
SELECT *
FROM layoffs_staging2
WHERE industry IS NULL;


-- Optional inspection of a specific company
SELECT *
FROM layoffs_staging2
WHERE company LIKE 'Bally''s Interactive';


-- =========================================================
-- 16. Remove rows with no useful layoff information
--    These records contain neither total layoffs nor layoff percentage
-- =========================================================
SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL
  AND percentage_laid_off IS NULL;

DELETE
FROM layoffs_staging2
WHERE total_laid_off IS NULL
  AND percentage_laid_off IS NULL;


-- =========================================================
-- 17. Final review of the cleaned dataset
-- =========================================================
SELECT *
FROM layoffs_staging2;


-- =========================================================
-- 18. Drop helper column used for duplicate detection
-- =========================================================
ALTER TABLE layoffs_staging2
DROP COLUMN row_num;

