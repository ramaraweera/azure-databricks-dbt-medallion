-- ============================================================
-- gold_queries.sql
-- Marketing analytics queries on Gold layer
-- Run AFTER dbt Cloud has created all Gold tables
-- ============================================================

-- Q1: Top genres by global sales
SELECT g.genre_name,
       ROUND(SUM(f.global_sales_millions),2) AS total_sales_M,
       COUNT(*)                               AS game_count,
       g.genre_category
FROM gaming_gold.fct_game_sales f
JOIN gaming_gold.dim_genre g ON f.genre_id = g.genre_id
GROUP BY g.genre_name, g.genre_category
ORDER BY total_sales_M DESC;

-- Q2: Publisher market share
SELECT p.publisher_name,
       ROUND(SUM(f.global_sales_millions),2)                          AS total_sales_M,
       COUNT(*)                                                        AS title_count,
       ROUND(SUM(f.global_sales_millions) /
             SUM(SUM(f.global_sales_millions)) OVER() * 100, 2)       AS market_share_pct
FROM gaming_gold.fct_game_sales f
JOIN gaming_gold.dim_publisher p ON f.publisher_id = p.publisher_id
GROUP BY p.publisher_name
ORDER BY total_sales_M DESC
LIMIT 15;

-- Q3: Regional sales by genre
SELECT g.genre_name,
       ROUND(SUM(f.na_sales_millions),2)    AS NA_M,
       ROUND(SUM(f.eu_sales_millions),2)    AS EU_M,
       ROUND(SUM(f.jp_sales_millions),2)    AS JP_M,
       ROUND(SUM(f.other_sales_millions),2) AS Other_M,
       ROUND(SUM(f.global_sales_millions),2) AS Global_M
FROM gaming_gold.fct_game_sales f
JOIN gaming_gold.dim_genre g ON f.genre_id = g.genre_id
GROUP BY g.genre_name
ORDER BY Global_M DESC;

-- Q4: Annual sales trend (1990-2016)
SELECT gm.year_of_release,
       ROUND(SUM(f.global_sales_millions),2) AS total_sales_M,
       COUNT(*)                               AS titles_released
FROM gaming_gold.fct_game_sales f
JOIN gaming_gold.dim_game gm ON f.game_id = gm.game_id
WHERE gm.year_of_release BETWEEN 1990 AND 2016
GROUP BY gm.year_of_release
ORDER BY gm.year_of_release;

-- Q5: Platform rankings
SELECT p.platform_name,
       ROUND(SUM(f.global_sales_millions),2) AS total_sales_M,
       COUNT(*)                               AS title_count
FROM gaming_gold.fct_game_sales f
JOIN gaming_gold.dim_platform p ON f.platform_id = p.platform_id
GROUP BY p.platform_name
ORDER BY total_sales_M DESC
LIMIT 20;

-- Q6: Sales tier breakdown
SELECT sales_tier,
       COUNT(*)                               AS game_count,
       ROUND(SUM(global_sales_millions),2)    AS total_sales_M,
       ROUND(AVG(global_sales_millions),3)    AS avg_sales_M
FROM gaming_gold.fct_game_sales
GROUP BY sales_tier
ORDER BY total_sales_M DESC;
