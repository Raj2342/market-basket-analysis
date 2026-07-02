{{ config(materialized='view') }}

-- ==========================================
-- IMPORT CTEs (Fetching clean staging data)
-- ==========================================
WITH transactions AS (
    SELECT * FROM {{ ref('stg_transactions') }}
),

products AS (
    SELECT * FROM {{ ref('stg_products') }}
),

demographics AS (
    SELECT * FROM {{ ref('stg_demographics') }}
),

-- ==========================================
-- LOGIC CTEs
-- ==========================================
Segmented_Households AS (
    SELECT 
        HOUSEHOLD_KEY,
        CASE 
            WHEN INCOME_DESC IN ('Under 15K', '15-24K', '25-34K') THEN 'Budget Shopper'
            WHEN INCOME_DESC IN ('100-124K', '125-149K', '150-174K', '175-199K', '200-249K', '250K+') THEN 'High Income'
            ELSE 'Middle Income'
        END AS "Income_Segment"
    FROM 
        demographics
),

Basket_Pairs AS (
    SELECT 
        t1.BASKET_ID,
        t1.HOUSEHOLD_KEY,
        p1.COMMODITY_DESC AS "Item_A",
        p2.COMMODITY_DESC AS "Item_B"
    FROM 
        transactions t1
    JOIN 
        transactions t2 
        ON t1.BASKET_ID = t2.BASKET_ID 
        AND t1.PRODUCT_ID != t2.PRODUCT_ID  -- Kept the correct != logic
    JOIN 
        products p1 ON t1.PRODUCT_ID = p1.PRODUCT_ID
    JOIN 
        products p2 ON t2.PRODUCT_ID = p2.PRODUCT_ID
    WHERE 
        p1.COMMODITY_DESC < p2.COMMODITY_DESC
)

-- ==========================================
-- FINAL OUTPUT
-- ==========================================
SELECT 
    sh."Income_Segment",
    bp."Item_A",
    bp."Item_B",
    COUNT(DISTINCT bp.BASKET_ID) AS "Times_Bought_Together"
FROM 
    Basket_Pairs bp
JOIN 
    Segmented_Households sh ON bp.HOUSEHOLD_KEY = sh.HOUSEHOLD_KEY
GROUP BY 
    sh."Income_Segment", 
    bp."Item_A", 
    bp."Item_B"
QUALIFY 
    ROW_NUMBER() OVER (PARTITION BY sh."Income_Segment" ORDER BY COUNT(DISTINCT bp.BASKET_ID) DESC) <= 20
ORDER BY 
    sh."Income_Segment", 
    "Times_Bought_Together" DESC