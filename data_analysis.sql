-- =========================================================
-- Data Analysis Project: Global Layoffs Dataset
-- =========================================================
-- Description:
-- This SQL script explores trends and patterns in a cleaned
-- global layoffs dataset. The analysis focuses on:
-- 1. Extreme layoff events
-- 2. Company-level layoffs
-- 3. Industry and country trends
-- 4. Time-based analysis
-- 5. Stage-based comparisons
-- 6. Ranking top companies by layoffs per year
--
-- Dataset scope:
-- Global layoffs data from 2020 to early 2023
-- =========================================================


-- =========================================================
-- 1. Review the cleaned dataset
-- =========================================================
SELECT *
FROM layoffs_staging2;


-- =========================================================
-- 2. Explore maximum layoff values
--    Identify the largest total layoff event and the highest
--    layoff percentage in the dataset
-- =========================================================
SELECT MAX(total_laid_off) AS max_total_laid_off,
       MAX(percentage_laid_off) AS max_percentage_laid_off
FROM layoffs_staging2;


-- =========================================================
-- 3. Analyze companies with 100% layoffs
--    These are cases where the entire workforce was laid off
-- =========================================================
SELECT *
FROM layoffs_staging2
WHERE percentage_laid_off = 1
ORDER BY total_laid_off DESC;


-- =========================================================
-- 4. Review fully laid-off companies by funds raised
--    This helps compare shutdown events with funding levels
-- =========================================================
SELECT *
FROM layoffs_staging2
WHERE percentage_laid_off = 1
ORDER BY funds_raised_millions DESC;


-- =========================================================
-- 5. Company-level analysis
--    Identify companies with the highest total layoffs
-- =========================================================
SELECT company,
       SUM(total_laid_off) AS total_layoffs
FROM layoffs_staging2
GROUP BY company
ORDER BY total_layoffs DESC;


-- =========================================================
-- 6. Identify dataset date range
--    Check the earliest and latest records available
-- =========================================================
SELECT MIN(`date`) AS earliest_date,
       MAX(`date`) AS latest_date
FROM layoffs_staging2;


-- =========================================================
-- 7. Industry-level analysis
--    Measure total layoffs by industry
-- =========================================================
SELECT industry,
       SUM(total_laid_off) AS total_layoffs
FROM layoffs_staging2
GROUP BY industry
ORDER BY total_layoffs DESC;


-- =========================================================
-- 8. Country-level analysis
--    Measure total layoffs by country
-- =========================================================
SELECT country,
       SUM(total_laid_off) AS total_layoffs
FROM layoffs_staging2
GROUP BY country
ORDER BY total_layoffs DESC;


-- =========================================================
-- 9. Yearly layoff trend
--    Aggregate layoffs by year to identify macro trends
-- =========================================================
SELECT YEAR(`date`) AS layoff_year,
       SUM(total_laid_off) AS total_layoffs
FROM layoffs_staging2
GROUP BY YEAR(`date`)
ORDER BY layoff_year DESC;


-- =========================================================
-- 10. Stage-level analysis
--     Compare total layoffs across company stages
-- =========================================================
SELECT stage,
       SUM(total_laid_off) AS total_layoffs
FROM layoffs_staging2
GROUP BY stage
ORDER BY stage ASC;


SELECT stage,
       SUM(total_laid_off) AS total_layoffs
FROM layoffs_staging2
GROUP BY stage
ORDER BY total_layoffs DESC;


-- =========================================================
-- 11. Total layoff percentage by stage
--     This query explores the summed layoff percentage by stage
--     (interpret carefully, as percentages are not always additive)
-- =========================================================
SELECT stage,
       SUM(percentage_laid_off) AS total_percentage_laid_off
FROM layoffs_staging2
GROUP BY stage
ORDER BY total_percentage_laid_off DESC;


-- =========================================================
-- 12. Monthly layoff trend
--     Aggregate layoffs by month
-- =========================================================
SELECT SUBSTRING(`date`, 1, 7) AS `month`,
       SUM(total_laid_off) AS total_layoffs
FROM layoffs_staging2
WHERE SUBSTRING(`date`, 1, 7) IS NOT NULL
GROUP BY `month`
ORDER BY `month` ASC;


-- =========================================================
-- 13. Rolling cumulative layoffs over time
--     This shows how layoffs accumulated month by month
-- =========================================================
WITH rolling_total AS (
    SELECT SUBSTRING(`date`, 1, 7) AS `month`,
           SUM(total_laid_off) AS total_off
    FROM layoffs_staging2
    WHERE SUBSTRING(`date`, 1, 7) IS NOT NULL
    GROUP BY `month`
)
SELECT `month`,
       total_off,
       SUM(total_off) OVER (ORDER BY `month`) AS rolling_total
FROM rolling_total;


-- =========================================================
-- 14. Company layoffs by year
--     Aggregate total layoffs by company and year
-- =========================================================
SELECT company,
       YEAR(`date`) AS layoff_year,
       SUM(total_laid_off) AS total_layoffs
FROM layoffs_staging2
GROUP BY company, YEAR(`date`)
ORDER BY total_layoffs DESC;


-- =========================================================
-- 15. Rank companies by layoffs within each year
--     DENSE_RANK is used to compare companies year by year
-- =========================================================
WITH company_year (company, years, total_laid_off) AS (
    SELECT company,
           YEAR(`date`) AS years,
           SUM(total_laid_off) AS total_laid_off
    FROM layoffs_staging2
    GROUP BY company, YEAR(`date`)
)
SELECT *,
       DENSE_RANK() OVER (
           PARTITION BY years
           ORDER BY total_laid_off DESC
       ) AS ranking
FROM company_year
WHERE years IS NOT NULL
ORDER BY years ASC, ranking ASC;


-- =========================================================
-- 16. Extract the top 5 companies by layoffs for each year
-- =========================================================
WITH company_year (company, years, total_laid_off) AS (
    SELECT company,
           YEAR(`date`) AS years,
           SUM(total_laid_off) AS total_laid_off
    FROM layoffs_staging2
    GROUP BY company, YEAR(`date`)
),
company_year_rank AS (
    SELECT *,
           DENSE_RANK() OVER (
               PARTITION BY years
               ORDER BY total_laid_off DESC
           ) AS ranking
    FROM company_year
    WHERE years IS NOT NULL
)
SELECT *
FROM company_year_rank
WHERE ranking <= 5;

