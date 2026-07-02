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

-- ==========================================
-- LOGIC CTEs
-- ==========================================
-- Step 1: Har product category ka individual base volume (total trips) nikal lo
Category_Volume AS (
    SELECT 
        p.COMMODITY_DESC,
        COUNT(DISTINCT t.BASKET_ID) AS Total_Trips
    FROM transactions t
    JOIN products p ON t.PRODUCT_ID = p.PRODUCT_ID
    GROUP BY p.COMMODITY_DESC
),

-- Step 2: Apna base pair engine (Kitni baar dono sath bike)
Pair_Volume AS (
    SELECT 
        p1.COMMODITY_DESC AS Item_A,
        p2.COMMODITY_DESC AS Item_B,
        COUNT(DISTINCT t1.BASKET_ID) AS Times_Bought_Together
    FROM transactions t1
    JOIN transactions t2 
        ON t1.BASKET_ID = t2.BASKET_ID AND t1.PRODUCT_ID != t2.PRODUCT_ID
    JOIN products p1 ON t1.PRODUCT_ID = p1.PRODUCT_ID
    JOIN products p2 ON t2.PRODUCT_ID = p2.PRODUCT_ID
    WHERE p1.COMMODITY_DESC < p2.COMMODITY_DESC
    GROUP BY p1.COMMODITY_DESC, p2.COMMODITY_DESC
    HAVING COUNT(DISTINCT t1.BASKET_ID) > 5000 -- Excellent noise filter!
)

-- ==========================================
-- FINAL OUTPUT
-- ==========================================
-- Step 3: The Final Math (A to B vs B to A)
SELECT 
    pv.Item_A,
    pv.Item_B,
    pv.Times_Bought_Together,
    cv_A.Total_Trips AS "Total_A_Trips",
    cv_B.Total_Trips AS "Total_B_Trips",
    ROUND((pv.Times_Bought_Together * 100.0) / cv_A.Total_Trips, 1) AS "Pull_A_to_B_Percent",
    ROUND((pv.Times_Bought_Together * 100.0) / cv_B.Total_Trips, 1) AS "Pull_B_to_A_Percent", 

    -- THE CORRECTED UPGRADE: Explicit Lead and Follower Columns
    CASE 
        -- Agar A -> B ka percentage BADA hai, matlab A dependent hai. So B is the Lead.
        WHEN (pv.Times_Bought_Together * 100.0 / cv_A.Total_Trips) > (pv.Times_Bought_Together * 100.0 / cv_B.Total_Trips) THEN pv.Item_B
        WHEN (pv.Times_Bought_Together * 100.0 / cv_B.Total_Trips) > (pv.Times_Bought_Together * 100.0 / cv_A.Total_Trips) THEN pv.Item_A
        ELSE 'Equal Pull' 
    END AS "Lead_Item",
    
    CASE 
        -- Jiska conversion percentage zyada hai, wo Follower (dependent) hai.
        WHEN (pv.Times_Bought_Together * 100.0 / cv_A.Total_Trips) > (pv.Times_Bought_Together * 100.0 / cv_B.Total_Trips) THEN pv.Item_A
        WHEN (pv.Times_Bought_Together * 100.0 / cv_B.Total_Trips) > (pv.Times_Bought_Together * 100.0 / cv_A.Total_Trips) THEN pv.Item_B
        ELSE 'Equal Pull' 
    END AS "Follower_Item"

    


FROM Pair_Volume pv
JOIN Category_Volume cv_A ON pv.Item_A = cv_A.COMMODITY_DESC
JOIN Category_Volume cv_B ON pv.Item_B = cv_B.COMMODITY_DESC
ORDER BY pv.Times_Bought_Together DESC
