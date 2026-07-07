# 🛒 Market Basket Analysis & Cross-Selling Engine
<p>
  <img src="https://img.shields.io/badge/Snowflake-29B5E8?style=flat&logo=snowflake&logoColor=white" alt="Snowflake">
  <img src="https://img.shields.io/badge/dbt_Core-FF6B6B?style=flat&logo=dbt&logoColor=white" alt="dbt Core">
  <img src="https://img.shields.io/badge/DuckDB-FFF100?style=flat&logo=duckdb&logoColor=black" alt="DuckDB">
  <img src="https://img.shields.io/badge/Tableau-E97627?style=flat&logo=tableau&logoColor=white" alt="Tableau">
</p>

*An independent enterprise-architecture case study demonstrating full-cycle ELT workflows, complex SQL association rules, and modern data stack implementation.*

## 🎯 The Business Problem: The Instacart Case Study

Instacart is a leading grocery delivery platform with a primary objective: maximize revenue. However, sustainable revenue growth cannot rely solely on the expensive acquisition of new users. The most effective strategy is to increase the amount each existing customer spends per checkout—a metric known as Average Order Value (AOV).

But increasing cart size cannot be forced. If a customer adds 'Bread' to their cart and the app randomly recommends 'Shampoo', the customer will simply ignore it. It creates a frustrating user experience. 

**The Objective:** 
How can Instacart organically increase its Average Order Value without relying on new customer acquisition?

**The Solution (Data-Driven Association Rules):**
This project executes a comprehensive Market Basket Analysis to discover exactly which products are organically purchased together. Instead of relying on guesswork, this analytical framework uses advanced SQL to extract hard patterns from millions of rows. For example, if the data reveals that 75% of users who buy "Organic Strawberries" also buy "Almond Milk," this analysis provides the exact business rules needed by the product and marketing teams to deploy targeted, frictionless recommendations.

**Real-World Business Impact:**
*   **"Frequently Bought Together" UI Feature:** By mapping item associations, the app can trigger high-conversion pop-ups. If a user adds 'Tortilla Chips' to their cart, the app instantly suggests 'Salsa Dip'. The user adds it to their cart effortlessly, generating instant profit.
*   **Smart Bundling & Promotional Offers:** This engine equips the marketing team with data-backed combinations to run highly profitable weekend combo sales (e.g., 'Organic Milk' & 'Bananas') rather than guessing which products pair well.
*   **App UI Optimization:** Insights from this analysis allow the product team to restructure the app's digital aisles, grouping highly correlated product categories together to smooth the customer journey and encourage broader catalogue browsing.

---

## ⚙️ Core Analytical Execution & SQL Logic

To translate the business objectives into actionable data, I engineered a 6-pillar analytical framework executed via complex SQL and dbt transformations:

1. **Identifying "Anchor" Products (The Cart Drivers):** Calculated order volume and Average Basket Size to identify high-volume staples that drive platform traffic.
2. **Mapping the Top 10 "Frequently Bought Together" Pairs:** Utilized advanced SQL `SELF JOINs` to identify exact item-to-item relationships that happen consistently, directly powering the UI recommendation logic.
3. **Determining "Directional Pull" (Lead vs. Follow):** Calculated conditional probability to determine if discounting a specific lead item organically drives the sale of its paired counterpart.
4. **Isolating "Impulse Buys" vs. "Habitual Reorders":** Cross-referenced top product pairs with reorder flags to calculate the Reorder Ratio, isolating habitual purchases for targeted "Subscribe & Save" campaigns.
5. **Demographic-Based Bundling:** Joined transaction data with household demographics to design specific product bundles tailored uniquely to high-income versus budget shoppers.
6. **Analyzing The Discount Trap & Halo Effect:** Evaluated promotional data to reveal if customers buying discounted items also purchased full-priced items, validating the true profitability of marketing promotions.

---
##  ELT Architecture and Data flow
### Security & Trust Setup
<img width="501" height="451" alt="deno2 drawio" src="https://github.com/user-attachments/assets/dce9834d-2c51-4051-b279-a45b76d1a7fa" />

### Automated Data Ingestion & Transformation
<img width="2295" height="1471" alt="deno drawio" src="https://github.com/user-attachments/assets/3ae4b51e-f8c7-40fc-a75c-32ee26390645" />

---
### 📂 Raw Data Sourcing & Scale

The pipeline ingests and processes the following raw datasets to simulate a high-volume enterprise environment:

| Table Name | Total Rows |
| :--- | :--- |
| `RAW_TRANSACTION_DATA` | 2.6M |
| `RAW_PRODUCT` | 92.4K |
| `RAW_HH_DEMOGRAPHIC` | 801 |
<img width="1916" height="861" alt="image" src="https://github.com/user-attachments/assets/28e684cd-b919-4928-8b72-4a84958a0f31" />

---
## dbt Data Lineage & Transformation DAG
<img width="832" height="896" alt="broraj-Page-3 drawio" src="https://github.com/user-attachments/assets/670a88be-9b47-45fd-aad1-8b4c0086606e" />

### 📂 Repository Structure & SQL Models

To maintain enterprise-grade code hygiene and modularity, the entire data transformation layer is built using dbt Core. Below is the directory structure detailing the staging, analytical marts, and configuration files.

*Note: Navigate directly into the `models/marts/` directory to review the complex `SELF JOIN` logic and conditional probability calculations powering the Market Basket engine.*

```text
DBT_INSTACART_BASKET_INSIGHTS/
├── models/
│   ├── staging/                            # Raw data standardization & type casting
│   │   ├── stg_demographics.sql
│   │   ├── stg_products.sql
│   │   └── stg_transactions.sql
│   ├── marts/                              # Core business logic & star schema models
│   │   ├── dim_demographics.sql
│   │   ├── dim_products.sql
│   │   ├── dim_time_periods.sql
│   │   ├── fct_basket_anchors.sql
│   │   ├── fct_customer_habits.sql
│   │   ├── fct_directional_pull.sql
│   │   ├── fct_discount_impact.sql
│   │   ├── fct_market_basket_demographics.sql
│   │   ├── fct_market_basket_pairs.sql
│   │   └── fct_weekly_pair_habits.sql
│   └── source.yml                          # Source definitions mapped to Snowflake raw tables
├── logs/
│   └── dbt.log                             # Execution logs for debugging
├── target/                                 # Compiled SQL (generated post dbt run)
├── dbt_project.yml                         # Main dbt project configuration and materialization rules
├── .gitignore                              
├── cammand.txt                             # Stored execution commands (e.g., dbt run, dbt test)
└── README.md                               # Project documentation (You are here)


## 📂 Data Sourcing & Simulation
To ensure strict adherence to data privacy standards and completely separate this independent case study from any professional work experience, the raw transactional and demographic data powering this architecture is a synthetically scaled version of a public dataset: [Dunnhumby - The Complete Journey](https://www.kaggle.com/datasets/frtgnn/dunnhumby-the-complete-journey/data)[cite: 2]. 

The raw data was structurally modified, joined across multiple dimensional tables (transactions, demographics, campaigns), and scaled to simulate a massive enterprise B2C environment. This allowed me to rigorously stress-test the Snowflake + dbt ELT pipeline and demonstrate production-grade analytical capabilities without utilizing proprietary company data.
