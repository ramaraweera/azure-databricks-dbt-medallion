-- Dimension: one row per unique platform (PS2, Wii, X360, PC, DS, etc.)

SELECT DISTINCT
    {{ dbt_utils.generate_surrogate_key(['platform']) }} AS platform_id,
    platform                                             AS platform_name
FROM {{ ref('stg_vg_sales') }}
