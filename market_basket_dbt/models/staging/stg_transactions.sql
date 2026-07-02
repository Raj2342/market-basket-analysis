WITH raw_transactions AS (
    SELECT * FROM {{ source('market_basket_raw', 'raw_transaction_data') }}
),

-- STEP 1: Find the Basket Size (Using your data-backed logic)
basket_sizes AS (
    SELECT 
        BASKET_ID,
        COUNT(DISTINCT PRODUCT_ID) AS unique_item_count
    FROM 
        raw_transactions
    GROUP BY 
        BASKET_ID
),

-- STEP 2: The P99.9 Filter (Keep 99.9% of normal shoppers, kill the B2B buyers)
valid_baskets AS (
    SELECT 
        BASKET_ID
    FROM 
        basket_sizes
    WHERE 
        unique_item_count <= 90
)

-- STEP 3: Output the Final Clean Data
SELECT 
    t.BASKET_ID,
    t.HOUSEHOLD_KEY,
    t.PRODUCT_ID,
    t.QUANTITY,
    t.SALES_VALUE,
    t.RETAIL_DISC,
    t.COUPON_DISC,
    t.COUPON_MATCH_DISC,
    t.WEEK_NO,
    t.DAY,
    t.TRANS_TIME
FROM 
    raw_transactions t
JOIN 
    valid_baskets v ON t.BASKET_ID = v.BASKET_ID
WHERE 
    -- RULE 1: Remove Returns & Voids
    t.QUANTITY > 0               
    
    -- RULE 2: Cap extreme quantity anomalies per line item
    AND t.QUANTITY <= 50