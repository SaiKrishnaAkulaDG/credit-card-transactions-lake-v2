-- Gold — Daily Transaction Summary
--
-- One aggregated record per calendar day (transaction_date) from resolvable Silver transactions.
-- Provides comprehensive daily metrics: transaction counts, amounts, channel breakdown, and type analysis.
--
-- AGGREGATION LOGIC:
--   1. Filter Silver transactions where _is_resolvable = true
--   2. Group by transaction_date to create one record per day
--   3. Compute: total count, total signed amount, channel breakdown (ONLINE vs IN_STORE)
--   4. Compute: transaction type breakdown (count & sum per type) as STRUCT
--   5. Track: _pipeline_run_id, _computed_at timestamp, source period (min/max transaction_date)
--
-- CONSTRAINTS: GOLD-D-01 (unique transaction_date), INV-04 (non-null _pipeline_run_id)
-- MATERIALIZATION: external (non-partitioned, overwrites on re-run)
--
{{
  config(
    materialized='external',
    location='/app/gold/daily_summary/data.parquet'
  )
}}

with filtered_transactions as (
  select
    transaction_date,
    transaction_type,
    channel,
    _signed_amount,
    _pipeline_run_id
  from read_parquet('/app/silver/transactions/date=*/data.parquet')
  where _is_resolvable = true
),

daily_aggregates as (
  select
    transaction_date,
    count(*) as total_transactions,
    sum(_signed_amount) as total_signed_amount,
    sum(case when channel = 'ONLINE' then 1 else 0 end) as online_transactions,
    sum(case when channel = 'IN_STORE' then 1 else 0 end) as instore_transactions,
    max(_pipeline_run_id) as _pipeline_run_id
  from filtered_transactions
  group by transaction_date
),

transaction_type_breakdown as (
  select
    transaction_date,
    map_agg(
      transaction_type,
      struct_pack(
        count := count(*),
        total_signed_amount := sum(_signed_amount)
      )
    ) as transactions_by_type
  from filtered_transactions
  group by transaction_date
)

select
  da.transaction_date,
  da.total_transactions,
  da.total_signed_amount,
  ttb.transactions_by_type,
  da.online_transactions,
  da.instore_transactions,
  current_timestamp as _computed_at,
  da._pipeline_run_id,
  min(ft.transaction_date) as _source_period_start,
  max(ft.transaction_date) as _source_period_end
from daily_aggregates da
left join transaction_type_breakdown ttb on da.transaction_date = ttb.transaction_date
cross join filtered_transactions ft
group by
  da.transaction_date,
  da.total_transactions,
  da.total_signed_amount,
  ttb.transactions_by_type,
  da.online_transactions,
  da.instore_transactions,
  da._pipeline_run_id
order by da.transaction_date
