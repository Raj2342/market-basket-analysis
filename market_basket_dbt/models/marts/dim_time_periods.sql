{{ config(materialized='table') }}

WITH base_time AS (
    -- Step 1: Raw data se saare unique Day aur Week nikalna
    SELECT DISTINCT 
        DAY,
        WEEK_NO
    FROM {{ ref('stg_transactions') }}
    WHERE DAY IS NOT NULL
)

SELECT 
    -- 1. The Anchor ID (Ye Fact tables ke 'DAY' se join hoga)
    DAY AS Time_ID,
    DAY AS Day_Number,
    
    -- 2. Week Level
    WEEK_NO AS Week_Number,
    'Week ' || TO_VARCHAR(WEEK_NO) AS Week_Label,
    
    -- 3. Day of Week Logic (1 to 7 ki cycle banane ke liye)
    MOD(DAY - 1, 7) + 1 AS Day_Of_Week_Number,
    
    -- Weekday vs Weekend (Assuming 6th aur 7th day of cycle is weekend)
    CASE 
        WHEN MOD(DAY - 1, 7) + 1 IN (6, 7) THEN 'Weekend'
        ELSE 'Weekday'
    END AS Day_Type,
    
    -- 4. Period Level (Retail Month Proxy = 4 Weeks)
    -- Har 4 hafte ko ek 'Period' maan liya (e.g., Week 1-4 = Period 1)
    CEIL(WEEK_NO / 4.0) AS Period_Number,
    'Period ' || TO_VARCHAR(CEIL(WEEK_NO / 4.0)) AS Period_Label,
    
    -- 5. Quarter Level (Retail Quarter = 13 Weeks)
    -- Har 13 hafte ko ek 'Quarter' maan liya (e.g., Week 1-13 = Q1)
    CEIL(WEEK_NO / 13.0) AS Quarter_Number,
    'Q' || TO_VARCHAR(CEIL(WEEK_NO / 13.0)) AS Quarter_Label

FROM base_time
ORDER BY Time_ID ASC