-- Dimension: one row per unique game title + platform combination.
-- Used to track which titles are blockbusters vs long-tail in marketing reports.

select
  {{ dbt_utils.generate_surrogate_key(['game_name', 'platform']) }} as game_id,
  game_name,
  platform,
  min(year_of_release) as year_of_release,
  max(is_global_hit) as is_global_hit,
  max(sales_tier) as sales_tier
from {{ ref('stg_vg_sales') }}
group by 1, 2, 3