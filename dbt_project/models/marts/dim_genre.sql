-- Dimension: genre enriched with marketing category labels from the seed file.
-- genre_category (Core Gaming / Casual Gaming / Other) enables
-- high-level marketing segmentation without changing raw genre values.

WITH genres AS (
    SELECT DISTINCT genre FROM {{ ref('stg_vg_sales') }}
)

SELECT
    {{ dbt_utils.generate_surrogate_key(['g.genre']) }} AS genre_id,
    g.genre                 AS genre_name,
    COALESCE(gc.genre_category, 'Other')  AS genre_category,
    COALESCE(gc.is_competitive, false)    AS is_competitive
FROM genres g
LEFT JOIN {{ ref('genre_categories') }} gc
    ON g.genre = gc.genre
