{{ config(materialized='table') }}

WITH raw_products AS (
    SELECT * FROM {{ ref('stg_products') }}
)

SELECT DISTINCT
    PRODUCT_ID,
    DEPARTMENT,
    COMMODITY_DESC AS Category,
    SUB_COMMODITY_DESC AS Sub_Category,
    BRAND
FROM raw_products
-- Optional: Handle missing values
WHERE PRODUCT_ID IS NOT NULL