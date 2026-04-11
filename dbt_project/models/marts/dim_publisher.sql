-- Dimension: one row per unique publisher.
-- Used in publisher market share and portfolio analysis.

SELECT DISTINCT
    {{ dbt_utils.generate_surrogate_key(['publisher']) }} AS publisher_id,
    publisher                                             AS publisher_name
FROM {{ ref('stg_vg_sales') }}
