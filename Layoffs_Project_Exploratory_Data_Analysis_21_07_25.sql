-- Script Name : Layoffs Dataset - Exploratory Data Analysis (EDA)
-- Author      : Raj Ayush Nandi
-- Date        : 2025-07-21
-- Description : In-depth exploratory analysis of global tech layoffs data. This script covers:
--               - Temporal trends (monthly/yearly layoffs)
--               - Industry, country, and funding stage breakdowns
--               - Identification of companies with highest and lowest layoffs
--               - Cumulative and 3-month rolling summaries
--               - Ranked insights using window functions (DENSE_RANK)
--               Designed for stakeholder reporting, business impact assessment, and strategic workforce insights.


SELECT *
FROM layoffs_staging2;

-- Get the maximum layoffs and layoff percentage
SELECT MAX(num_laid_off), MAX(percentage_laid_off)
FROM layoffs_staging2;

-- Show records where 100% of employees were laid off, sorted by number laid off
SELECT *
FROM layoffs_staging2
WHERE percentage_laid_off = 1
ORDER BY num_laid_off DESC;

-- Show 100% layoff cases, sorted by funds raised
SELECT *
FROM layoffs_staging2
WHERE percentage_laid_off = 1
ORDER BY fund_raised_mn DESC;

-- Get total layoffs per company, sorted by highest layoffs
SELECT company, SUM(num_laid_off)
FROM layoffs_staging2
GROUP BY company
ORDER BY 2 DESC;

-- Get the earliest and latest layoff dates
SELECT MIN(`date`), MAX(`date`)
FROM layoffs_staging2;

-- Total layoffs by industry, sorted by layoffs
SELECT industry, SUM(num_laid_off)
FROM layoffs_staging2
GROUP BY industry
ORDER BY 2 DESC;

-- Total layoffs by country, sorted by layoffs
SELECT country, SUM(num_laid_off)
FROM layoffs_staging2
GROUP BY country
ORDER BY 2 DESC;

-- Total layoffs by date, sorted by layoffs
SELECT `date`, SUM(num_laid_off)
FROM layoffs_staging2
GROUP BY `date`
ORDER BY 2 DESC;

-- Yearly total layoffs, sorted by layoffs
SELECT YEAR(`date`), SUM(num_laid_off)
FROM layoffs_staging2
GROUP BY YEAR(`date`)
ORDER BY 2 DESC;

-- Total layoffs by funding stage, sorted by layoffs
SELECT stage, SUM(num_laid_off)
FROM layoffs_staging2
GROUP BY stage
ORDER BY 2 DESC;

-- Progression of Layoffs (Cumulative Total) partitioned by country

SELECT SUBSTRING(`date`,1,7) AS `month`, SUM(num_laid_off)
FROM layoffs_staging2
GROUP BY `month`
ORDER BY 1;

WITH Cumulative_Total AS (
	SELECT 
    SUBSTRING(`date`,1,7) AS `month`, country,
    SUM(num_laid_off) AS total_laid_off
FROM layoffs_staging2
GROUP BY `month`, country
ORDER BY 1
)
SELECT `month`, country, total_laid_off, 
SUM(total_laid_off) OVER(PARTITION BY country
ORDER BY `month`
) AS cumu_total_laid_off
FROM Cumulative_Total;

-- Progression of Layoffs (Rolling Total) 
-- Calculate rolling 3-month sum of layoffs to observe short-term trends partitioned by country

## rolling_sum_current_month = current + previous_1 + previous_2
WITH Rolling_Total AS (
	SELECT 
    SUBSTRING(`date`, 1, 7) AS `month`, country,
    SUM(num_laid_off) AS total_laid_off
FROM layoffs_staging2
GROUP BY `month`, country
ORDER BY 1
)
SELECT `month`, country, total_laid_off,
SUM(total_laid_off) OVER (
PARTITION BY country
ORDER BY `month` 
ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
) AS rolling_3_month_laid_off
FROM Rolling_Total;

SELECT company, SUM(num_laid_off)
FROM layoffs_staging2
GROUP BY company
ORDER BY 2 DESC;

SELECT company, YEAR(`date`), SUM(num_laid_off)
FROM layoffs_staging2
GROUP BY company, YEAR(`date`)
ORDER BY company;

-- Identify top 5 companies with the highest layoffs per year using DENSE_RANK

SELECT company, YEAR(`date`), SUM(num_laid_off)
FROM layoffs_staging2
GROUP BY company, YEAR(`date`)
ORDER BY 3 DESC;

## Aggregate total layoffs per company per year
WITH Company_Year (Company, `Years`, Total_laid_off) AS
(
SELECT company, YEAR(`date`), SUM(num_laid_off)
FROM layoffs_staging2
GROUP BY company, YEAR(`date`)
), 
## Rank companies by layoffs within each year and return top 5
Company_Year_Rank AS
(
SELECT *, DENSE_RANK() OVER (
PARTITION BY Years 
ORDER BY Total_Laid_off DESC) AS Ranking
FROM Company_Year
WHERE Years IS NOT NULL
)
SELECT *
FROM Company_Year_Rank
WHERE Ranking <= 5;


-- Identify bottom 5 companies with the highest layoffs per month using DENSE_RANK

WITH Company_Month AS (
    SELECT 
        company,
        industry,
        country,
        DATE_FORMAT(`date`, '%Y-%m') AS `year_month`,
        SUM(num_laid_off) AS total_laid_off
    FROM layoffs_staging2
    GROUP BY company, industry, country, `year_month`
),
Company_Month_Rank AS (
    SELECT *,
        DENSE_RANK() OVER (
            PARTITION BY `year_month` 
            ORDER BY total_laid_off DESC
        ) AS ranking
    FROM Company_Month
    WHERE `year_month` IS NOT NULL
)
SELECT *
FROM Company_Month_Rank
WHERE ranking <= 5
ORDER BY `year_month`, ranking;


-- Identify bottom 5 companies with the least layoffs per year using DENSE_RANK

WITH Company_Year AS (
    -- Aggregate total layoffs by company, industry, country, and year
    SELECT 
        company,
        industry,
        country,
        YEAR(`date`) AS `year`,
        SUM(num_laid_off) AS total_laid_off
    FROM layoffs_staging2
    GROUP BY company, industry, country, `year`
),
Company_Year_Rank AS (
    -- Rank companies within each year based on lowest layoffs (excluding NULL totals)
    SELECT *,
        DENSE_RANK() OVER (
            PARTITION BY `year`
            ORDER BY total_laid_off ASC
        ) AS ranking
    FROM Company_Year
    WHERE `year` IS NOT NULL AND total_laid_off IS NOT NULL
)
-- Return companies ranked in the bottom 5 layoffs per year
SELECT *
FROM Company_Year_Rank
WHERE ranking <= 5
ORDER BY `year`, ranking;


-- Identify bottom 5 companies with the least layoffs per month using DENSE_RANK

WITH Company_Month AS (
    -- Aggregate total layoffs by company, industry, country, and year-month
    SELECT 
        company,
        industry,
        country,
        DATE_FORMAT(`date`, '%Y-%m') AS `year_month`,
        SUM(num_laid_off) AS total_laid_off
    FROM layoffs_staging2
    GROUP BY company, industry, country, `year_month`
),
Company_Month_Rank AS (
    -- Rank companies within each month based on lowest layoffs (excluding NULL totals)
    SELECT *,
        DENSE_RANK() OVER (
            PARTITION BY `year_month`
            ORDER BY total_laid_off ASC
        ) AS ranking
    FROM Company_Month
    WHERE `year_month` IS NOT NULL AND total_laid_off IS NOT NULL
)
-- Return companies ranked in the bottom 5 layoffs per month
SELECT *
FROM Company_Month_Rank
WHERE ranking <= 5
ORDER BY `year_month`, ranking;