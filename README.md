# global-tech-layoffs-analysis-2025

[![SQL](https://img.shields.io/badge/SQL-MySQL-blue)](#)  
[![Data-Cleaning](https://img.shields.io/badge/Process-Data%20Cleaning-success)](#)  
[![EDA](https://img.shields.io/badge/Analysis-EDA-orange)](#)  
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)  

---

## 📌 Overview  
This project analyzes global technology sector layoffs between **2022–2025** using SQL. The workflow covers **data cleaning, standardization, and exploratory data analysis (EDA)** to uncover patterns across companies, industries, countries, and investment stages.  

The aim is to transform raw layoff records into a reliable dataset and derive insights into the **scale, timing, and business impact of layoffs worldwide**.  

---

## 📂 Dataset  
- **Source:** Tech Layoffs Tracker (CSV file included)  LINK : https://layoffs.fyi/
- **Records:** 750+ company layoff entries  
- **Key Columns:**  
  - Company  
  - Location  
  - Number of Employees Laid Off  
  - Percentage Laid Off  
  - Industry  
  - Stage (Funding/Business Stage)  
  - Funding Raised (USD Millions)  
  - Country  
  - Date  

---

## ⚙️ Project Workflow  

### 1. Data Cleaning (`Layoffs_Project_Data_Cleaning_20_07_25.sql`)  
- Created staging tables to protect raw dataset.  
- Standardized column names and formats.  
- Removed duplicates using **ROW_NUMBER()** window function.  
- Handled null/blank values and propagated missing industries using self-joins.  
- Converted date fields into SQL `DATE` format.  
- Final cleaned dataset stored in `layoffs_staging2`.  

### 2. Exploratory Data Analysis (`Layoffs_Project_Exploratory_Data_Analysis_21_07_25.sql`)  
- Temporal trends: monthly and yearly layoffs.  
- Industry-wise, country-wise, and funding-stage breakdowns.  
- Identification of **top companies** with highest layoffs.  
- Rolling 3-month and cumulative layoffs to observe trend progression.  
- Ranking analysis using **DENSE_RANK()**:  
  - Top 5 companies with the highest layoffs per year.  
  - Bottom 5 companies with the least layoffs per year and per month.  

---

## 🔑 Key Insights  
- Layoff spikes observed in late 2022 and throughout 2023.  
- **Technology and consumer sectors** faced the greatest impact.  
- The **United States** recorded the largest share of layoffs, followed by India and Europe.  
- Companies in **late funding stages** and post-IPO were more affected than early-stage startups.  
- Rolling 3-month windows revealed clusters of mass layoffs rather than a smooth distribution.  

---

## 🛠️ Tools & Skills Applied  
- **SQL (MySQL):** Data cleaning, transformation, and EDA  
- **Window Functions:** ROW_NUMBER, DENSE_RANK, cumulative and rolling aggregates  
- **Data Wrangling:** Handling nulls, duplicates, and standardization  
- **Analytical Skills:** Business impact assessment, workforce trend analysis  

---

## 🚀 How to Use  
1. Import the dataset (`Layoffsfyi_Tech Layoffs Tracker_19_07_25.csv`) into MySQL.  
2. Run `Layoffs_Project_Data_Cleaning_20_07_25.sql` to generate the cleaned dataset.  
3. Run `Layoffs_Project_Exploratory_Data_Analysis_21_07_25.sql` to reproduce analysis queries and insights.  

---
