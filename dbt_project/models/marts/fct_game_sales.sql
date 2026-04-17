-- Fact table: one row per game + platform combination.
-- Central table for all marketing analytics dashboards.
-- Joins to all four dimension tables for a complete star schema.

WITH sales AS (
    -- Aggregate raw sales to one row per game + platform
    select
        game_platform_key,
        game_name,
        platform,
        genre,
        publisher,
        year_of_release,
        sales_tier,
        is_global_hit,

        -- Sales measures (all in millions of units)
        sum(na_sales_millions)    as na_sales_millions,
        sum(eu_sales_millions)    as eu_sales_millions,
        sum(jp_sales_millions)    as jp_sales_millions,
        sum(other_sales_millions) as other_sales_millions,
        sum(global_sales_millions) as global_sales_millions,

        -- Regional mix percentages (recomputed from totals)
        case
            when sum(global_sales_millions) > 0
                then round(sum(na_sales_millions) / sum(global_sales_millions), 4)
        end as na_sales_pct,
        case
            when sum(global_sales_millions) > 0
                then round(sum(eu_sales_millions) / sum(global_sales_millions), 4)
        end as eu_sales_pct,
        case
            when sum(global_sales_millions) > 0
                then round(sum(jp_sales_millions) / sum(global_sales_millions), 4)
        end as jp_sales_pct

    from {{ ref('stg_vg_sales') }}
    group by
        game_platform_key,
        game_name,
        platform,
        genre,
        publisher,
        year_of_release,
        sales_tier,
        is_global_hit
),

games      AS ( select * from {{ ref('dim_game') }} ),
genres     AS ( select * from {{ ref('dim_genre') }} ),
publishers AS ( select * from {{ ref('dim_publisher') }} ),
platforms  AS ( select * from {{ ref('dim_platform') }} )

SELECT
    -- Surrogate key at the fact grain: one row per game + platform
    s.game_platform_key                        AS sales_id,

    -- Foreign keys to dimensions
    g.game_id,
    ge.genre_id,
    pub.publisher_id,
    plat.platform_id,

    -- Degenerate dimensions (attributes stored directly on the fact)
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

    -- Derived marketing KPIs (based on aggregated totals)
    round(s.eu_sales_millions + s.jp_sales_millions, 2)       AS intl_ex_na_sales_M,
    round(s.global_sales_millions - s.na_sales_millions, 2)   AS row_sales_M

FROM sales s
LEFT JOIN games      g   ON {{ dbt_utils.generate_surrogate_key(['s.game_name', 's.platform']) }} = g.game_id
LEFT JOIN genres     ge  ON s.genre     = ge.genre_name
LEFT JOIN publishers pub ON s.publisher = pub.publisher_name
LEFT JOIN platforms  plat ON s.platform = plat.platform_name
;