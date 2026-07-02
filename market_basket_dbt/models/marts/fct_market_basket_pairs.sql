-- Page 1 - Top Pairs by Demographic (G1-Q2) AND Page 2 - Directional Pull (G1-Q3)

{{ config(materialized='view') }}

WITH transactions AS (
    SELECT * FROM {{ ref('stg_transactions') }}
),

products AS (
    SELECT * FROM {{ ref('stg_products') }}
),

Individual_Traffic AS (
    -- STEP 1: Pehle har ek product ka apna khud ka total basket count nikal lo (Bina pair ke)
    SELECT 
        p.COMMODITY_DESC,
        COUNT(DISTINCT t.BASKET_ID) AS total_baskets
    FROM transactions t
    JOIN products p ON t.PRODUCT_ID = p.PRODUCT_ID
    GROUP BY p.COMMODITY_DESC
),

Pair_Traffic AS (
    -- STEP 2: Ab tumhara pair nikalne wala logic (Jo sir pairs ka count dega)
    SELECT 
        p1.COMMODITY_DESC AS item_first,
        p2.COMMODITY_DESC AS item_second, 
        COUNT(DISTINCT t1.BASKET_ID) AS joint_traffic
    FROM transactions t1
    JOIN transactions t2 
        ON t1.basket_id = t2.basket_id 
    JOIN products p1 
        ON p1.PRODUCT_ID = t1.PRODUCT_ID
    JOIN products p2 
        ON p2.PRODUCT_ID = t2.PRODUCT_ID
    WHERE p1.COMMODITY_DESC < p2.COMMODITY_DESC
    GROUP BY item_first, item_second
)

-- STEP 3: Ab un dono ko JOIN karke ek master view bana do
SELECT 
    pt.item_first,
    it1.total_baskets AS traffic_first_alone,    -- Item 1 ka actual individual traffic
    
    pt.item_second,
    it2.total_baskets AS traffic_second_alone,   -- Item 2 ka actual individual traffic
    
    pt.joint_traffic                             -- Dono ek sath kitni baar bike
    
FROM Pair_Traffic pt
-- Item 1 ka count lane ke liye JOIN
JOIN Individual_Traffic it1 ON pt.item_first = it1.COMMODITY_DESC
-- Item 2 ka count lane ke liye JOIN
JOIN Individual_Traffic it2 ON pt.item_second = it2.COMMODITY_DESC

ORDER BY pt.joint_traffic DESC
LIMIT 50