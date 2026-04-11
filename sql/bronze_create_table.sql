-- ============================================================
-- bronze_create_table.sql
-- Alternative to Notebook 01: run this in Databricks SQL Editor
-- Requires vgsales.csv already uploaded to /mnt/gaming/raw/
-- ============================================================

CREATE DATABASE IF NOT EXISTS gaming_bronze;

CREATE OR REPLACE TABLE gaming_bronze.vg_sales_raw
USING DELTA
AS
SELECT
    Rank            AS rank_id,
    Name            AS game_name,
    Platform        AS platform,
    Year_of_Release AS year_of_release,
    Genre           AS genre,
    Publisher       AS publisher,
    CAST(NA_Sales    AS DOUBLE) AS na_sales,
    CAST(EU_Sales    AS DOUBLE) AS eu_sales,
    CAST(JP_Sales    AS DOUBLE) AS jp_sales,
    CAST(Other_Sales AS DOUBLE) AS other_sales,
    CAST(Global_Sales AS DOUBLE) AS global_sales,
    current_timestamp()          AS _ingested_at,
    'vgsales.csv'                AS _source_file,
    'bronze'                     AS _layer
FROM read_files(
    '/mnt/gaming/raw/vgsales.csv',
    format  => 'csv',
    header  => true
)
WHERE Name IS NOT NULL
  AND CAST(Global_Sales AS DOUBLE) > 0;

OPTIMIZE gaming_bronze.vg_sales_raw;

SELECT COUNT(*) AS bronze_rows FROM gaming_bronze.vg_sales_raw;
