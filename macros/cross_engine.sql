{#- Cross-engine helpers (2026-10-13): the same model builds on Snowflake (prod) and DuckDB (dev target). Snowflake-only
    functions are isolated here so the model SQL stays engine-neutral. -#}

{% macro safe_timestamp(col) -%}
  {%- if target.type == 'snowflake' -%} try_to_timestamp_ntz({{ col }})
  {%- else -%} try_cast({{ col }} as timestamp)
  {%- endif -%}
{%- endmacro %}

{% macro ts_type() -%}
  {%- if target.type == 'snowflake' -%} timestamp_ntz(6) {%- else -%} timestamp {%- endif -%}
{%- endmacro %}
