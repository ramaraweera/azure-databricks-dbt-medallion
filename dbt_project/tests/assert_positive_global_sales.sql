-- Custom singular test: returns rows that FAIL the assertion.
-- dbt expects 0 rows to be returned for a passing test.
-- This ensures every fact row has a positive global sales figure.

SELECT *
FROM {{ ref('fct_game_sales') }}
WHERE global_sales_millions <= 0
