-- Page 3 - Habitual vs. Impulse (G1-Q5)
{{ config(materialized='table') }}

-- ==========================================
-- 1. IMPORT CTE (Using staging models)
-- ==========================================
WITH transactions AS (
    SELECT 
        t.BASKET_ID, 
        t.HOUSEHOLD_KEY, 
        p.COMMODITY_DESC
    FROM {{ ref('stg_transactions') }} t
    JOIN {{ ref('stg_products') }} p 
        ON t.PRODUCT_ID = p.PRODUCT_ID
    WHERE t.HOUSEHOLD_KEY IS NOT NULL -- Guest checkouts filter out
),

-- ==========================================
-- 2. PAIR GENERATION ENGINE (Cart mein kya sath aaya)
-- ==========================================
basket_pairs AS (
    SELECT 
        t1.HOUSEHOLD_KEY,
        t1.BASKET_ID,
        t1.COMMODITY_DESC AS Item_A,
        t2.COMMODITY_DESC AS Item_B
    FROM transactions t1
    JOIN transactions t2
        ON t1.BASKET_ID = t2.BASKET_ID
        AND t1.COMMODITY_DESC < t2.COMMODITY_DESC -- Alphabetical sort to prevent A-B and B-A duplicates
),

-- ==========================================
-- 3. HOUSEHOLD TRACKING ENGINE (Kisine kitni baar kharida)
-- ==========================================
household_history AS (
    SELECT 
        HOUSEHOLD_KEY,
        Item_A,
        Item_B,
        COUNT(DISTINCT BASKET_ID) AS Purchase_Frequency
    FROM basket_pairs
    GROUP BY 
        HOUSEHOLD_KEY,
        Item_A,
        Item_B
),

-- ==========================================
-- 4. THE TAGGING & AGGREGATION LAYER
-- ==========================================
aggregated_metrics AS (
    SELECT 
        Item_A,
        Item_B,
        
        -- The Habitual Reorder: 3 ya usse zyada baar
        COUNT(DISTINCT CASE WHEN Purchase_Frequency >= 3 THEN HOUSEHOLD_KEY END) AS Habitual_Households,
        
        -- The Impulse Buy: Sirf 1 ya 2 baar
        COUNT(DISTINCT CASE WHEN Purchase_Frequency < 3 THEN HOUSEHOLD_KEY END) AS Impulse_Households,
        
        -- Total reach of this product pair
        COUNT(DISTINCT HOUSEHOLD_KEY) AS Total_Households
    FROM household_history
    GROUP BY 
        Item_A,
        Item_B
        
    -- SYSTEM SHIELD: Sirf wahi dikhao jo kam se kam 50 alag gharon mein sath bike hain.
    HAVING COUNT(DISTINCT HOUSEHOLD_KEY) > 50
)

-- ==========================================
-- 5. FINAL BI OUTPUT (The Strategy Layer)
-- ==========================================
SELECT 
    Item_A,
    Item_B,
    Habitual_Households,
    Impulse_Households,
    Total_Households,
    
    -- The "Aadat" Conversion Rate (%)
    ROUND((Habitual_Households * 100.0) / Total_Households, 2) AS Habitual_Conversion_Rate_Pct,
    
    -- The Impulse Rate (%)
    ROUND((Impulse_Households * 100.0) / Total_Households, 2) AS Impulse_Rate_Pct,
    
    -- The Checkout Bait Expose (Business Recommendation Engine)
    CASE 
        WHEN (Impulse_Households * 100.0) / Total_Households >= 80 
            THEN 'Checkout Bait (Last Minute Grab)'
        WHEN (Habitual_Households * 100.0) / Total_Households >= 20 
            THEN 'Subscribe & Save Target'
        ELSE 'Standard Assortment'
    END AS Business_Action_Tag

FROM aggregated_metrics
ORDER BY Habitual_Households DESC, Impulse_Households DESC