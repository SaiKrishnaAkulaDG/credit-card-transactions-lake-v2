create or replace view "dbt_catalog"."main"."silver_transactions__dbt_int" as (
        select * from '/app/silver_temp/transactions/date=2024-01-01/data.parquet'
    );