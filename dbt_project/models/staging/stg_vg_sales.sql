-- Staging model: selects from Silver Delta, generates a surrogate key.
-- This is the single source of truth for all downstream mart models.
-- Materialised as a VIEW (no data copy, always fresh from Silver).

WITH source AS (
    SELECT * FROM {{ source('silver', 'vg_sales_clean') }}
),

staged AS (
    SELECT
        {{ dbt_utils.generate_surrogate_key([
            'game_name', 'platform', 'year_of_release'
        ]) }}                               AS game_platform_key,
        game_name,
        platform,
        year_of_release,
        genre,
        publisher,
        na_sales_millions,
        eu_sales_millions,
        jp_sales_millions,
        other_sales_millions,
        global_sales_millions,
        na_sales_pct,
        eu_sales_pct,
        jp_sales_pct,
        sales_tier,
        is_global_hit
    FROM source
)

SELECT * FROM staged
