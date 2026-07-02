-- Page 1 - Identify the Anchors (G1-Q1)
WITH transactions AS (
    -- Reading from the clean, filtered staging table (No outliers, no returns)
    SELECT * FROM {{ ref('stg_transactions') }}
),

products AS (
    -- Reading from the clean products table (No Fuel, no Coupons)
    SELECT * FROM {{ ref('stg_products') }}
),

-- STEP 1: Calculate the true physical volume of every basket
basket_sizes AS (
    SELECT 
        BASKET_ID,
        SUM(QUANTITY) AS total_basket_volume
    FROM 
        transactions
    GROUP BY 
        BASKET_ID
)

-- STEP 2: The Anchor Metrics (Hook vs Multiplier)
SELECT 
    p.COMMODITY_DESC ,
    
    -- THE HOOK: How many unique trips (baskets) did this product drive?
    COUNT(DISTINCT t.BASKET_ID) AS hook_traffic_trips,
    
    -- THE MULTIPLIER: Average total size of the basket when this product is bought
    ROUND(AVG(b.total_basket_volume), 1) AS avg_basket_volume
    
FROM 
    transactions t
JOIN 
    products p ON t.PRODUCT_ID = p.PRODUCT_ID
JOIN 
    basket_sizes b ON t.BASKET_ID = b.BASKET_ID
GROUP BY 
    p.COMMODITY_DESC
HAVING 
    COUNT(DISTINCT t.BASKET_ID) > 5000 -- Only focus on actual drivers/traffic/visiter, ignoring rare items
ORDER BY 
    avg_basket_volume DESC