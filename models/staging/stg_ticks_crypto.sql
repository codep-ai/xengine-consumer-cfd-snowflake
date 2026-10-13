{{ config(
    materialized = 'view',
    tags         = ['staging', 'cfd', 'crypto'],
) }}

-- ─────────────────────────────────────────────────────────────────────────────
-- stg_ticks_crypto — staging view over CFD_LAKE.fct_tick_crypto, the SF-registered
-- Iceberg table that points at the Kafka-Connect-written metadata.json in
-- s3://datapai-cfd-lake/lake/fct_tick_crypto/. Casts TS_UTC (VARCHAR in the
-- raw Iceberg) to TIMESTAMP_NTZ and emits a synthetic ingested_at from
-- current_timestamp at view materialization (no native ingest timestamp
-- in the Kafka Connect Iceberg sink output).
-- ─────────────────────────────────────────────────────────────────────────────

with raw as (
    select * from {{ source('cfd_lake', 'tick_crypto') }}
),

final as (
    select
        symbol,
        cast({{ safe_timestamp('ts_utc') }} as {{ ts_type() }}) as ts_utc,
        bid,
        ask,
        mid,
        spread_pips,
    session       as exchange_region,
        source,
    asset_class,
        cast({{ dbt.current_timestamp() }} as {{ ts_type() }}) as ingested_at
    from raw
)

select * from final
