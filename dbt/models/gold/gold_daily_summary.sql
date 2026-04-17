{{
  config(
    materialized='external',
    location='/app/gold/daily_summary/data.parquet'
  )
}}

with filtered_transactions as (
  select
    transaction_date,
    _signed_amount,
    _pipeline_run_id
  from read_parquet('/app/silver/transactions/date=*/data.parquet')
  where _is_resolvable = true
)

select
  transaction_date,
  sum(_signed_amount) as total_signed_amount,
  count(*) as total_transactions,
  max(_pipeline_run_id) as _pipeline_run_id
from filtered_transactions
group by transaction_date
order by transaction_date
