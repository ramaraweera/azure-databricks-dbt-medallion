-- Dimension: one row per unique game title + platform combination.
-- Used to track which titles are blockbusters vs long-tail in marketing reports.

SELECT DISTINCT
    {{ dbt_utils.generate_surrogate_key(['game_name', 'platform']) }} AS game_id,
    game_name,
    platform,
    year_of_release,
    is_global_hit,
    sales_tier
FROM {{ ref('stg_vg_sales') }}
