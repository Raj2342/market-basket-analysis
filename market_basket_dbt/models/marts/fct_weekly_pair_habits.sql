{{ config(
    materialized='table',
    tags=['weekly_habits', 'core_business']
) }}

WITH stg_transactions AS (
    SELECT * FROM {{ ref('stg_transactions') }} 
),

stg_products AS (
    SELECT * FROM {{ ref('stg_products') }}
),

-- Step 1: Map items to the baskets using your staging tables
basket_items AS (
    SELECT 
        t.basket_id,
        t.household_key,
        t.week_no,
        p.commodity_desc AS item_name
    FROM stg_transactions t
    JOIN stg_products p 
        ON t.product_id = p.product_id
),

-- Step 2: The Self-Join (Creating the Pairs without duplicates)
basket_pairs AS (
    SELECT DISTINCT
        a.household_key,
        a.week_no,
        a.basket_id,
        a.item_name AS item_a,
        b.item_name AS item_b
    FROM basket_items a
    JOIN basket_items b 
        ON a.basket_id = b.basket_id 
        AND a.item_name < b.item_name
),

-- Step 3: Get unique weeks a household bought a specific pair
household_weekly_pairs AS (
    SELECT DISTINCT 
        household_key,
        week_no,
        item_a,
        item_b
    FROM basket_pairs
),

-- Step 4: The Time-Machine (Window Function to track history)
pair_history AS (
    SELECT 
        household_key,
        week_no,
        item_a,
        item_b,
        ROW_NUMBER() OVER (
            PARTITION BY household_key, item_a, item_b 
            ORDER BY week_no ASC
        ) AS purchase_sequence
    FROM household_weekly_pairs
),

-- Step 5: Final Aggregation for Tableau (Pre-chewed data)
final_weekly_aggregation AS (
    SELECT 
        week_no,
        item_a || ' + ' || item_b AS product_pair, -- Pre-combined for easy Tableau filtering
        item_a,
        item_b,
        COUNT(DISTINCT household_key) AS total_households,
        
        -- Sequence >= 3 means Habitual (returning for this pair)
        COUNT(DISTINCT CASE WHEN purchase_sequence >= 3 THEN household_key END) AS habitual_households,
        
        -- Sequence < 3 means Impulse (first time buying this pair)
        COUNT(DISTINCT CASE WHEN purchase_sequence < 3 THEN household_key END) AS impulse_households
        
    FROM pair_history
    GROUP BY 1, 2, 3, 4
)

SELECT * FROM final_weekly_aggregation