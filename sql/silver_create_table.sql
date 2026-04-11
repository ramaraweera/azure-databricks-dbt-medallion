-- ============================================================
-- silver_create_table.sql
-- Alternative to Notebook 02: run in Databricks SQL Editor
-- Requires gaming_bronze.vg_sales_raw to exist first
-- ============================================================

CREATE DATABASE IF NOT EXISTS gaming_silver;

CREATE OR REPLACE TABLE gaming_silver.vg_sales_clean
USING DELTA
PARTITIONED BY (genre)
AS
SELECT
    game_name,
    platform,
    CAST(year_of_release AS INT)            AS year_of_release,
    genre,
    COALESCE(publisher, 'Unknown')          AS publisher,
    na_sales                                AS na_sales_millions,
    eu_sales                                AS eu_sales_millions,
    jp_sales                                AS jp_sales_millions,
    other_sales                             AS other_sales_millions,
    global_sales                            AS global_sales_millions,
    ROUND(na_sales    / global_sales * 100, 1) AS na_sales_pct,
    ROUND(eu_sales    / global_sales * 100, 1) AS eu_sales_pct,
    ROUND(jp_sales    / global_sales * 100, 1) AS jp_sales_pct,
    CASE
        WHEN global_sales >= 10  THEN 'Blockbuster'
        WHEN global_sales >= 1   THEN 'Hit'
        WHEN global_sales >= 0.1 THEN 'Mid-Tier'
        ELSE 'Long-Tail'
    END                                     AS sales_tier,
    CASE WHEN global_sales >= 1.0 THEN TRUE ELSE FALSE END AS is_global_hit
FROM gaming_bronze.vg_sales_raw
WHERE game_name IS NOT NULL
  AND global_sales IS NOT NULL
  AND global_sales > 0;

OPTIMIZE gaming_silver.vg_sales_clean;

SELECT COUNT(*) AS silver_rows FROM gaming_silver.vg_sales_clean;
