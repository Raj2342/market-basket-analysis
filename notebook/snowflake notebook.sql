-- -- Phase 1: Core Infrastructure Initialization
-- CREATE DATABASE IF NOT EXISTS market_basket_db;
-- USE DATABASE market_basket_db;

-- CREATE SCHEMA IF NOT EXISTS raw_data;
-- USE SCHEMA raw_data;

-- -- (Optional but recommended) Creating a clean schema for your dbt models later
-- CREATE SCHEMA IF NOT EXISTS analytics;



-- USE DATABASE market_basket_db;
-- USE SCHEMA raw_data;

-- -- 1. Create the Parquet File Format
-- CREATE OR REPLACE FILE FORMAT parquet_ff
--   TYPE = PARQUET
--   COMPRESSION = AUTO;

-- -- 2. Create the External Stage mapping to your S3 bucket
-- CREATE OR REPLACE STORAGE INTEGRATION s3_market_basket_int
--   TYPE = EXTERNAL_STAGE
--   STORAGE_PROVIDER = 'S3'
--   ENABLED = TRUE
--   STORAGE_AWS_ROLE_ARN = 'arn:aws:iam::507210367724:role/snowfl_market_basket_role'
--   STORAGE_ALLOWED_LOCATIONS = ('s3://instacart-basket-insights-raw-data/raw/');


 -- DESC INTEGRATION s3_market_basket_int;


USE DATABASE market_basket_db;
USE SCHEMA raw_data;

-- =====================================================================
-- STEP 1: DESTROY THE OLD EXTERNAL TABLES (JSON BASED)
-- =====================================================================
DROP TABLE IF EXISTS ext_hh_demographic;
DROP TABLE IF EXISTS ext_product;
DROP TABLE IF EXISTS ext_transaction_data;


-- =====================================================================
-- STEP 2: CREATE 100% PURE TABULAR TABLES
-- =====================================================================
CREATE OR REPLACE TABLE raw_hh_demographic (
    household_key          INT,
    age_desc               VARCHAR,
    marital_status_code    VARCHAR,
    income_desc            VARCHAR,
    homeowner_desc         VARCHAR,
    hh_comp_desc           VARCHAR,
    household_size_desc    VARCHAR,  
    kid_category_desc      VARCHAR
);

CREATE OR REPLACE TABLE raw_product (
   product_id            INT,
    manufacturer          INT,
    department            VARCHAR,
    brand                 VARCHAR,
    commodity_desc        VARCHAR,
    sub_commodity_desc    VARCHAR,
    curr_size_of_product  VARCHAR
);

CREATE OR REPLACE TABLE raw_transaction_data (
   basket_id          BIGINT,
    household_key      INT,
    product_id         INT,
    quantity           INT,
    sales_value        FLOAT,
    retail_disc        FLOAT,    -- Re-added
    coupon_disc        FLOAT,    -- Re-added
    coupon_match_disc  FLOAT,    -- Re-added
    store_id           INT,      -- Re-added
    trans_time         INT,      -- Re-added
    week_no            INT,
    day                INT
);


-- =====================================================================
-- STEP 3: COPY DATA FROM S3 DIRECTLY INTO COLUMNS (NO JSON)
-- =====================================================================
ALTER WAREHOUSE COMPUTE_WH SET WAREHOUSE_SIZE = 'LARGE';

COPY INTO raw_hh_demographic
FROM @my_s3_stage/hh_demographic/
FILE_FORMAT = (TYPE = PARQUET)
MATCH_BY_COLUMN_NAME = CASE_INSENSITIVE;

COPY INTO raw_product
FROM @my_s3_stage/product/
FILE_FORMAT = (TYPE = PARQUET)
MATCH_BY_COLUMN_NAME = CASE_INSENSITIVE;

COPY INTO raw_transaction_data
FROM @my_s3_stage/transaction_data/
FILE_FORMAT = (TYPE = PARQUET)
MATCH_BY_COLUMN_NAME = CASE_INSENSITIVE;


-- =====================================================================
-- PHASE 3: COOL DOWN (IMMEDIATE DOWNGRADE TO X-SMALL)
-- =====================================================================
ALTER WAREHOUSE COMPUTE_WH SET WAREHOUSE_SIZE = 'XSMALL';

SELECT * FROM raw_hh_demographic LIMIT 10;