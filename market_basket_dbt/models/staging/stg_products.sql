WITH raw_products AS (
    SELECT * FROM {{ source('market_basket_raw', 'raw_product') }}
)

SELECT 
    PRODUCT_ID,
    DEPARTMENT,
    COMMODITY_DESC,
    SUB_COMMODITY_DESC,
    BRAND
FROM 
    raw_products
WHERE 
    -- RULE 3: Exclude non-grocery categories at the product level
    COMMODITY_DESC NOT IN ('COUPON/MISC ITEMS', 'FUEL')