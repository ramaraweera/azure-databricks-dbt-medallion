-- Fact table: one row per game + platform combination.
-- Central table for all marketing analytics dashboards.
-- Joins to all four dimension tables for a complete star schema.

WITH sales AS (
    SELECT * FROM {{ ref('stg_vg_sales') }}
),
games      AS ( SELECT * FROM {{ ref('dim_game') }} ),
genres     AS ( SELECT * FROM {{ ref('dim_genre') }} ),
publishers AS ( SELECT * FROM {{ ref('dim_publisher') }} ),
platforms  AS ( SELECT * FROM {{ ref('dim_platform') }} )

SELECT
    s.game_platform_key              AS sales_id,

    -- Foreign keys to dimensions
    g.game_id,
    ge.genre_id,
    pub.publisher_id,
    plat.platform_id,

    -- Degenerate dimensions
    s.year_of_release,
    s.sales_tier,
    s.is_global_hit,

    -- Sales measures (all in millions of units)
    s.na_sales_millions,
    s.eu_sales_millions,
    s.jp_sales_millions,
    s.other_sales_millions,
    s.global_sales_millions,

    -- Regional mix percentages
    s.na_sales_pct,
    s.eu_sales_pct,
    s.jp_sales_pct,

    -- Derived marketing KPIs
    ROUND(s.eu_sales_millions + s.jp_sales_millions, 2)        AS intl_ex_na_sales_M,
    ROUND(s.global_sales_millions - s.na_sales_millions, 2)    AS row_sales_M

FROM sales s
LEFT JOIN games      g    ON {{ dbt_utils.generate_surrogate_key(['s.game_name', 's.platform']) }} = g.game_id
LEFT JOIN genres     ge   ON s.genre     = ge.genre_name
LEFT JOIN publishers pub  ON s.publisher = pub.publisher_name
LEFT JOIN platforms  plat ON s.platform  = plat.platform_name
