{#- defer to the lake (2026-10-13). On a DuckDB dev target with --vars '{defer_to_lake: true}', any ref() to a model that is NOT in
    this invocation's selection resolves to the Glue-catalogued copy of the PROD table (Snowflake-managed Iceberg on S3, registered in
    Glue by `xengine.py glue-sync`). The developer builds only what they are changing, against prod's real upstream data, read in
    place, with no warehouse. Everything else (Snowflake target, DuckDB full builds) behaves exactly as before.
    dbt lets a project override ref(): https://docs.getdbt.com/reference/dbt-jinja-functions/builtins -#}
{% macro ref() %}
  {% set version = kwargs.get('version') or kwargs.get('v') %}
  {% set packagename = none %}
  {% if (varargs | length) == 1 %}{% set modelname = varargs[0] %}
  {% else %}{% set packagename = varargs[0] %}{% set modelname = varargs[1] %}{% endif %}
  {% set rel = builtins.ref(*varargs, **kwargs) %}
  {% if target.type == 'duckdb' and var('defer_to_lake', false) %}
    {% set uid = 'model.' ~ (packagename or project_name) ~ '.' ~ modelname %}
    {% if execute and uid not in selected_resources %}
      {{ return(api.Relation.create(database=var('lake_catalog', 'glue'), schema=var('lake_schema', 'cfd_mesh'), identifier=modelname | lower)) }}
    {% endif %}
  {% endif %}
  {{ return(rel) }}
{% endmacro %}
