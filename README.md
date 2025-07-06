# vietnam-dairy-export-performance
# 🇻🇳 Vietnam Dairy Export Analysis (2020–2023)

## 📌 Project Overview

This project explores the export performance of Vietnamese dairy products from 2020 to 2023, based on data retrieved from the **UN Comtrade** database. The focus is on identifying key markets, understanding product-level export dynamics, and uncovering strategic opportunities to expand Vietnam’s dairy export footprint.

As Vietnam continues to assert its presence in the global agri-food sector, data-driven analysis is essential to support sustainable trade development—especially for high-potential categories like dairy.

---

## 🎯 Objectives

- Analyze historical export data to determine top-performing markets and product categories
- Detect growth trends in value, volume, and unit pricing across regions
- Understand product-market fit by evaluating distribution share per category
- Generate strategic insights to support diversification and long-term partner development

---

## 🗂️ Dataset

- **Source**: [UN Comtrade](https://comtrade.un.org/)
- **Time period**: 2020 to 2023
- **Scope**: Vietnam’s dairy-related export records by partner country and HS code

**Key variables:**
- `export_year`: Year of export
- `partner`: Destination country
- `hs_code`: Harmonized System code of exported product
- `prd_desc`: Mapped product category (e.g., Powdered Milk, Soy Milk)
- `net_wgt`: Net weight of exports (kg)
- `export_value_usd`: FOB export value (USD)
- `unit_price_usd_per_kg`: Derived metric = export_value / net_wgt

**Data Cleaning Steps:**
- Normalized country names (e.g., “CIV” → “Ivory Coast”)
- Filtered out non-country entries (e.g., “World”, “Other Asia, nes”)
- Removed invalid records (0 net weight or export value)
- Mapped HS codes into product categories for interpretability

---

## 🧪 Methodology

The project follows a 5-step analytical pipeline inspired by data warehousing practices:

1. **Step 1 – Data Cleaning (Silver Layer)**  
   Structured and cleaned the raw dataset using SQL and stored it in a curated table `export_silver`.

2. **Step 2 – Market-Level Analysis**  
   Created view `vw_market_summary` to examine export value, unit price, and YoY growth across partner countries.

3. **Step 3 – Product-Level Analysis**  
   Built `vw_product_performance` to analyze unit pricing, volume, and revenue trends per product category.

4. **Step 4 – Country-Product Interaction**  
   Developed `vw_country_product_matrix` to compute the share of each product in total exports per country.

5. **Step 5 – Automation Potential**  
   Designed logic to simulate a refreshable pipeline via SQL views (future steps may include stored procedures).

**SQL Techniques Used:**
- Common Table Expressions (CTEs)
- Window Functions (`RANK()`, `PARTITION BY`)
- Aggregation, conditional logic, and share calculations

---

## 📊 Key Insights

- **Market Insights**:  
  The Philippines, United States, and China are Vietnam’s most valuable dairy export markets, showing strong growth in both value and volume. In contrast, Cambodia exhibited a sharp decline in both dimensions, signaling a need for market reassessment.

- **Product Insights**:  
  Powdered Milk dominates most markets in value and volume, but Soy Milk and Liquid Milk (>1% fat) have high unit prices and growth potential in markets like China and Iraq.

- **Country-Product Fit**:  
  Each market demonstrates a unique product mix. For instance, Condensed Milk accounts for over 50% of export value to Cambodia, while Soy Milk is underrepresented in high-growth markets like the U.S. and China—indicating diversification opportunities.

---

## 🛠 Tools Used

- **MySQL Workbench**  
- **SQL (CTEs, Views, Aggregation, Window Functions)**

---

## 📁 Project Structure

| Object Name                | Description                                      |
|----------------------------|--------------------------------------------------|
| `vietnam_export`           | Raw data table imported from UN Comtrade         |
| `export_silver`            | Cleaned & standardized dataset                   |
| `vw_market_summary`        | View for country-level analysis (YoY, price, value) |
| `vw_product_performance`   | View for product-level analysis over time        |
| `vw_country_product_matrix`| View showing product share per country           |

---

## 💡 Future Improvements

- Add data visualization dashboards using Tableau or Power BI  
- Incorporate import-side data to study trade balances  
- Automate data refresh with stored procedures or Python-based pipelines  
- Integrate marketing or policy factors to model trade performance drivers

---

## 🧑 About Me

I am an International Relations major with a strong interest in data-driven global business. This project was self-initiated as part of my application for the **Vinamilk International Business Talent Program**, showcasing my ability to derive strategic trade insights using SQL and real-world datasets.

Feel free to reach out or explore more of my work!
