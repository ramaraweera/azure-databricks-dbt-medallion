-- Override dbt's default schema naming so models land in the schema
-- defined in dbt_project.yml (+schema: gaming_silver / gaming_gold)
-- instead of <target_schema>_<custom_schema>.

{% macro generate_schema_name(custom_schema_name, node) -%}
    {%- if custom_schema_name is none -%}
        {{ target.schema }}
    {%- else -%}
        {{ custom_schema_name | trim }}
    {%- endif -%}
{%- endmacro %}
