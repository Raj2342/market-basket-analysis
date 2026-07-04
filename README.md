# 🛒 Market Basket Analysis & Cross-Selling Engine
<p>
  <img src="https://img.shields.io/badge/Snowflake-29B5E8?style=flat&logo=snowflake&logoColor=white" alt="Snowflake">
  <img src="https://img.shields.io/badge/dbt_Core-FF6B6B?style=flat&logo=dbt&logoColor=white" alt="dbt Core">
  <img src="https://img.shields.io/badge/DuckDB-FFF100?style=flat&logo=duckdb&logoColor=black" alt="DuckDB">
  <img src="https://img.shields.io/badge/Tableau-E97627?style=flat&logo=tableau&logoColor=white" alt="Tableau">
</p>

*An independent enterprise-architecture case study demonstrating full-cycle ELT workflows, complex SQL association rules, and modern data stack implementation.*

## 🎯 The Business Problem
For major grocery delivery platforms, maximizing revenue relies heavily on increasing the Average Order Value (AOV) of existing users rather than solely acquiring new ones[cite: 2]. However, forcing random product recommendations creates friction, and poorly structured promotions often result in a "Discount Trap," where customers only purchase marked-down items without adding full-priced goods to their carts[cite: 2]. 

This project engineers a data-driven cross-selling analytical engine designed to solve these exact margin and revenue challenges. The core objectives of this architecture are to:
*   **Identify "Anchor" Products:** Pinpoint the high-volume staple items that drive total cart volume to optimize top-of-funnel marketing discounts[cite: 2].
*   **Map Association Rules:** Calculate the top 50 "Frequently Bought Together" pairs to fuel dynamic UI/UX recommendations[cite: 2].
*   **Determine Directional Pull:** Calculate conditional probabilities to establish "Lead" vs. "Follow" items within a pair, ensuring discounts are applied to the Lead item to organically drive the sale of both[cite: 2].
*   **Drive "Subscribe & Save" Subscriptions:** Differentiate between one-off "Impulse Buys" and "Habitual Reorders" to identify exactly which product pairs should be aggressively pushed into recurring subscription models[cite: 2].
*   **Demographic Bundling:** Segment basket combinations by household demographics (e.g., High-Income vs. Budget Shoppers) to design highly targeted promotional bundles[cite: 2].

---
<!-- (Steps 3, 4, 5, and 6 will go here: ELT Architecture, SQL Logic Snippets, Dashboard Screenshots, and Business Impact) -->
---

## 📂 Data Sourcing & Simulation
To ensure strict adherence to data privacy standards and completely separate this independent case study from any professional work experience, the raw transactional and demographic data powering this architecture is a synthetically scaled version of a public dataset: [Dunnhumby - The Complete Journey](https://www.kaggle.com/datasets/frtgnn/dunnhumby-the-complete-journey/data)[cite: 2]. 

The raw data was structurally modified, joined across multiple dimensional tables (transactions, demographics, campaigns), and scaled to simulate a massive enterprise B2C environment. This allowed me to rigorously stress-test the Snowflake + dbt ELT pipeline and demonstrate production-grade analytical capabilities without utilizing proprietary company data.
