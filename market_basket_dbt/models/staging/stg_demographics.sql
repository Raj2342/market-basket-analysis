{{ config(materialized='view') }}

WITH source_data AS (
    -- Reading directly from the raw source
    SELECT * 
    FROM {{ source('market_basket_raw', 'raw_hh_demographic') }}
),

staged AS (
    SELECT 
        -- Keys
        HOUSEHOLD_KEY,
        
        -- Categorical Attributes
        INCOME_DESC , 

        AGE_DESC AS Age_Group
        
        -- Note: Agar tumhari table mein 'AGE_DESC' ya 'MARITAL_STATUS' jaise 
        -- aur bhi columns hain, toh tum unhe yahan list kar sakte ho.
        
    FROM source_data
)

SELECT * 
FROM staged