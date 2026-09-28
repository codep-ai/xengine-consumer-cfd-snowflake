# xengine-consumer-cfd-snowflake

The analytics/audit team's dbt project on **Snowflake** for the CFD tick estate. It depends on the producer only through
`models/staging/_sources.yml`: the four raw tick tables (`tick_*`) the Kafka Connect Iceberg sink writes to `s3://datapai-cfd-lake/lake/` and
catalogues in Glue (`glue:cfd.tick_*`), which Snowflake reads as Glue-backed Iceberg tables with AUTO_REFRESH (no pointer to
maintain). Models are the dbt-demo CFD models unchanged: staging per asset class → `fct_tick_unified` → `mart_spread_by_asset_hourly`,
written back as Snowflake-managed Iceberg in `DATAPAI.CFD_MESH`. The ClickHouse consumer (`xengine-consumer-cfd-clickhouse`)
builds the same models on the same tables; the estate (`xengine-estate-cfd`) stitches both into one column lineage.

    ./xdbt.sh build
    ./xdbt.sh docs generate
