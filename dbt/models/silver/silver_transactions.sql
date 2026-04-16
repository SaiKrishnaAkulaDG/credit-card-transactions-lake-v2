-- Silver Transactions: Validation, sign assignment, resolvability flagging
-- Excludes quarantine-bound records (those matching rejection rules)
-- _signed_amount: CASE WHEN debit_credit_indicator = 'DR' THEN amount ELSE -amount END
-- _is_resolvable: true if account_id in silver_accounts, false otherwise (SIL-T-08)
-- _promoted_at: timestamp when record was promoted to Silver layer
-- _bronze_ingested_at: timestamp from Bronze ingestion
-- INV-04: _pipeline_run_id is non-null (enforced via schema test)

{{ config(
    materialized='external',
    location='/app/silver/transactions/date={{ var("date_var", "2024-01-01") }}/data.parquet',
    file_format='parquet'
) }}

with bronze_transactions as (
    select * from read_parquet('/app/bronze/transactions/date={{ var("date_var", "2024-01-01") }}/data.parquet')
),

silver_accounts as (
    select distinct account_id from read_parquet('/app/silver/accounts/data.parquet')
),

silver_transaction_codes as (
    select transaction_code, debit_credit_indicator from read_parquet('/app/silver/transaction_codes/data.parquet')
),

quarantine_transaction_ids as (
    select distinct transaction_id from read_parquet('/app/quarantine/data.parquet')
    where record_type = 'TRANSACTION' and transaction_id is not null
),

-- Filter out quarantine records and join for sign assignment
valid_transactions as (
    select
        bt.transaction_id,
        bt.account_id,
        bt.transaction_date,
        bt.amount,
        bt.transaction_code,
        bt.merchant_name,
        bt.channel,
        stc.debit_credit_indicator,
        bt._pipeline_run_id,
        bt._ingested_at as _bronze_ingested_at,
        bt._source_file
    from bronze_transactions bt
    left join silver_transaction_codes stc on bt.transaction_code = stc.transaction_code
    where bt.transaction_id not in (select transaction_id from quarantine_transaction_ids)
),

-- Add sign assignment, resolvability flag, and promotion timestamp
signed_transactions as (
    select
        vt.transaction_id,
        vt.account_id,
        vt.transaction_date,
        vt.amount,
        vt.transaction_code,
        vt.merchant_name,
        vt.channel,
        vt.debit_credit_indicator,
        case
            when vt.debit_credit_indicator = 'DR' then try_cast(vt.amount as decimal)
            else -try_cast(vt.amount as decimal)
        end as _signed_amount,
        case
            when sa.account_id is not null then true
            else false
        end as _is_resolvable,
        vt._pipeline_run_id,
        vt._bronze_ingested_at,
        vt._source_file,
        current_timestamp as _promoted_at
    from valid_transactions vt
    left join silver_accounts sa on vt.account_id = sa.account_id
)

select
    transaction_id,
    account_id,
    transaction_date,
    amount,
    transaction_code,
    merchant_name,
    channel,
    debit_credit_indicator,
    _signed_amount,
    _is_resolvable,
    _pipeline_run_id,
    _bronze_ingested_at,
    _source_file,
    _promoted_at
from signed_transactions
