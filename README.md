# Global Layoffs Data Cleaning & Analysis (2020–2023)

## Overview

Most real-world datasets are messy, inconsistent, and not immediately usable for analysis.

This project analyzes a global layoffs dataset covering the years **2020–2023** (including the **first three months of 2023**), focusing on transforming raw data into a clean, structured format and extracting meaningful insights.

The workflow was completed in SQL and includes two main stages:

1. **Data Cleaning and Preparation**
2. **Exploratory Data Analysis (EDA)**

The goal of the project was to transform raw layoff data into a clean, consistent, and analysis-ready dataset, and then explore patterns across companies, industries, countries, and time.

---

## Dataset Scope

The dataset contains global layoff records from **2020 to early 2023** and includes fields such as:

* Company
* Location
* Industry
* Total laid off
* Percentage laid off
* Date
* Funding stage
* Country
* Funds raised

---

## Part 1: Data Cleaning

The raw dataset contained several quality issues that required cleaning before analysis.

### Cleaning objectives

* Preserve the original raw data
* Remove duplicate records
* Standardize text fields
* Convert dates into a usable SQL format
* Handle missing values
* Remove non-informative rows

### Cleaning steps

#### 1. Created staging tables

I created staging tables to avoid modifying the raw dataset directly and to ensure a safer, reproducible workflow.

#### 2. Removed duplicates

Used `ROW_NUMBER()` with partitioning across all relevant columns to identify duplicate rows and delete records where `row_num > 1`.

#### 3. Standardized text values

Cleaned and standardized categorical fields by:

* trimming whitespace from company names
* unifying industry labels (e.g. `crypto%` → `crypto`)
* removing trailing punctuation from country names

#### 4. Converted dates

Converted the `date` field from text into SQL `DATE` format using `STR_TO_DATE`, then modified the column type accordingly.

#### 5. Handled missing values

* Replaced blank industry values with `NULL`
* Used self-joins to fill missing industry values based on matching company records

#### 6. Removed non-informative records

Deleted rows where both `total_laid_off` and `percentage_laid_off` were missing.

#### 7. Final cleanup

Dropped helper columns used only during the cleaning process.

### Cleaning outcome

The cleaned dataset is:

* free of duplicates
* more consistent across categorical fields
* properly formatted for time-based analysis
* ready for analysis and visualization

---

## Part 2: Data Analysis

After cleaning the dataset, I performed SQL-based exploratory data analysis to uncover patterns and trends.

### Analysis goals

* Understand the scale of layoffs over time
* Identify the most affected companies, industries, and countries
* Examine extreme layoff events
* Track monthly and yearly layoff trends
* Rank top companies by layoffs each year

### Analysis steps

#### 1. Initial exploration

Reviewed the cleaned table and identified maximum values for layoffs and layoff percentages.

#### 2. Extreme layoff cases

Analyzed companies with `percentage_laid_off = 1` to identify cases of full workforce reductions.

#### 3. Company-level analysis

Calculated total layoffs per company to identify the organizations most affected.

#### 4. Industry and country analysis

Aggregated layoffs by industry and country to determine which sectors and regions experienced the highest number of layoffs.

#### 5. Time-series analysis

Explored layoffs across time by:

* identifying the overall date range
* aggregating layoffs by year
* aggregating layoffs by month
* calculating rolling cumulative layoffs over time

#### 6. Stage-based analysis

Compared total layoffs across company funding stages.

#### 7. Ranking companies by year

Used `DENSE_RANK()` to rank companies by total layoffs within each year and extracted the top 5 companies per year.

### Analytical capabilities demonstrated

* Aggregation with `SUM()` and `GROUP BY`
* Time-based analysis using year and month breakdowns
* Window functions such as `DENSE_RANK()` and rolling totals
* Segmentation by company, industry, country, and stage
* Structured SQL workflow for exploratory analysis

---

## Key Insights

Based on the analysis, several patterns emerged:

- Layoffs peaked during specific periods, indicating strong economic cycles affecting multiple industries simultaneously  
- The tech sector showed a disproportionately high number of layoffs compared to other industries  
- A relatively small number of companies contributed to a large share of total layoffs each year  
- Several companies experienced full workforce reductions (100% layoffs), including both low-funded and well-funded organizations  
- Layoffs were heavily concentrated in specific countries, highlighting regional economic impact  

These findings demonstrate how raw data can be transformed into meaningful insights that reflect real-world economic trends.

---

## Skills Demonstrated

* SQL data cleaning and transformation
* Duplicate detection and removal
* Data standardization
* Missing value handling
* Exploratory data analysis (EDA)
* Time-series aggregation
* Ranking and window functions

---

## Files in This Repository

* `data_cleaning.sql` — SQL queries used for cleaning and preparing the dataset
* `data_analysis.sql` — SQL queries used for exploratory analysis
* `README.md` — project documentation

---

## Key Takeaway

This project demonstrates an end-to-end SQL workflow: starting with raw, inconsistent data and turning it into a structured dataset ready for analysis, followed by exploratory analysis to uncover meaningful trends in global layoffs between **2020 and early 2023**.

---

## Next Step

The next stage of this project is to build visualizations and dashboards to communicate the key trends more clearly.
