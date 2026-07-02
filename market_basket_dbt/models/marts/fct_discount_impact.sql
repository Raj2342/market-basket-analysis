{{ config(materialized='table') }}

-- ==========================================
-- 1. IMPORT CTE
-- ==========================================
WITH raw_transactions AS (
    SELECT * FROM {{ ref('stg_transactions') }}
),

-- ==========================================
-- 2. THE SANITIZATION LAYER (Killing the 36 Anomalies)
-- ==========================================
transactions AS (
    SELECT 
        BASKET_ID,
        DAY,
        WEEK_NO , 
        HOUSEHOLD_KEY,
        PRODUCT_ID,
        SALES_VALUE,
        RETAIL_DISC , 
        QUANTITY,
        -- Agar discount galti se positive hai, toh usko 0 kar do. Warna actual discount aane do.
        CASE 
            WHEN RETAIL_DISC > 0 THEN 0 
            ELSE RETAIL_DISC 
        END AS CLEAN_RETAIL_DISC
    FROM 
        raw_transactions
),

-- ==========================================
-- 3. THE PROFIT ENGINE
-- ==========================================
Order_Summary AS (
    SELECT 
        BASKET_ID,
        PRODUCT_ID,
        MAX(DAY) AS Transaction_Day,  
        SUM(QUANTITY) AS QUANTITY,
        
        SUM(SALES_VALUE) AS Order_Total_Sales,
        -- Ab humara engine sirf clean discount use karega
        SUM(CLEAN_RETAIL_DISC) AS Order_Total_Discount, 
        COUNT(*) OVER (PARTITION BY BASKET_ID) AS Total_Items_In_Basket,
        SUM(CASE WHEN SUM(CLEAN_RETAIL_DISC) < 0 THEN 1 ELSE 0 END) OVER (PARTITION BY BASKET_ID) AS Discounted_Items_Count,
        
        -- THE CLEAN PROFIT ENGINE 
        SUM(((SALES_VALUE - CLEAN_RETAIL_DISC) * 0.25) + CLEAN_RETAIL_DISC) AS Order_Estimated_Profit
    FROM 
        transactions
    GROUP BY 
        BASKET_ID, PRODUCT_ID
)

-- Step 2: The Tagging Engine (This goes straight to Power BI)
SELECT 
    BASKET_ID,
    Transaction_Day,
    PRODUCT_ID,
    QUANTITY,
    Order_Total_Sales,
    Order_Total_Discount,
    Order_Estimated_Profit,
    
    CASE 
        WHEN Discounted_Items_Count = 0 
            THEN 'The Loyalist (Pure Profit)'
        WHEN Discounted_Items_Count = Total_Items_In_Basket 
            THEN 'The Discount Trap (Margin Bleed)'
        WHEN Discounted_Items_Count > 0 AND Discounted_Items_Count < Total_Items_In_Basket 
            THEN 'The Halo Effect (Mix Shopping)'
        ELSE 'Unknown'
    END AS Promotion_Bucket
FROM 
    Order_Summary