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
This project executes a comprehensive Market Basket Analysis to discover exactly which products are organically purchased together. Instead of relying on guesswork, this analytical framework uses advanced SQL to extract hard patterns from millions of rows. For example, if the data reveals that 75% of users who buy "Organic Strawberries" also buy "Almond Milk," this analysis provides the exact business rules needed by the product and marketing teams to deploy targeted, frictionless recommendations

**Real-World Business Impact:**
*   **"Frequently Bought Together" UI Feature:** By mapping item associations, the app can trigger high-conversion pop-ups. If a user adds 'Tortilla Chips' to their cart, the app instantly suggests 'Salsa Dip'. The user adds it to their cart effortlessly, generating instant profit.
*   **Smart Bundling & Promotional Offers:** This engine equips the marketing team with data-backed combinations to run highly profitable weekend combo sales (e.g., 'Organic Milk' & 'Bananas') rather than guessing which products pair well.
*   **App UI Optimization:** Insights from this analysis allow the product team to restructure the app's digital aisles, grouping highly correlated product categories together to smooth the customer journey and encourage broader catalogue browsing.

---
<!-- (Steps 3, 4, 5, and 6 will go here: ELT Architecture, SQL Logic Snippets, Dashboard Screenshots, and Business Impact) -->
---

## 📂 Data Sourcing & Simulation
To ensure strict adherence to data privacy standards and completely separate this independent case study from any professional work experience, the raw transactional and demographic data powering this architecture is a synthetically scaled version of a public dataset: [Dunnhumby - The Complete Journey](https://www.kaggle.com/datasets/frtgnn/dunnhumby-the-complete-journey/data)[cite: 2]. 

The raw data was structurally modified, joined across multiple dimensional tables (transactions, demographics, campaigns), and scaled to simulate a massive enterprise B2C environment. This allowed me to rigorously stress-test the Snowflake + dbt ELT pipeline and demonstrate production-grade analytical capabilities without utilizing proprietary company data.
