

with filtered_transactions as (
  select
    account_id,
    transaction_date,
    _signed_amount,
    debit_credit_indicator,
    _pipeline_run_id
  from read_parquet('/app/silver/transactions/date=*/data.parquet')
  where _is_resolvable = true
),

weekly_grouped as (
  select
    account_id,
    date_trunc('week', cast(transaction_date as date)) as week_start_date,
    count(*) as total_purchases,
    avg(_signed_amount) as avg_purchase_amount,
    sum(case when debit_credit_indicator = 'DR' then 1 else 0 end) as total_payments,
    sum(case when debit_credit_indicator = 'FEE' then 1 else 0 end) as total_fees,
    sum(case when debit_credit_indicator = 'INT' then 1 else 0 end) as total_interest,
    max(_pipeline_run_id) as _pipeline_run_id
  from filtered_transactions
  group by account_id, date_trunc('week', cast(transaction_date as date))
)

select
  wg.account_id,
  wg.week_start_date,
  wg.total_purchases,
  wg.avg_purchase_amount,
  wg.total_payments,
  wg.total_fees,
  wg.total_interest,
  sa.current_balance as closing_balance,
  wg._pipeline_run_id
from weekly_grouped wg
inner join read_parquet('/app/silver/accounts/data.parquet') sa on wg.account_id = sa.account_id
order by wg.account_id, wg.week_start_date