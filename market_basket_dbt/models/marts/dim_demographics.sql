{{ config(materialized='table') }}

WITH raw_demographics AS (
    SELECT * FROM {{ ref('stg_demographics') }}
)

SELECT DISTINCT
    HOUSEHOLD_KEY,
    Age_Group,
    INCOME_DESC AS Income_Bracket,
FROM raw_demographics
WHERE HOUSEHOLD_KEY IS NOT NULL