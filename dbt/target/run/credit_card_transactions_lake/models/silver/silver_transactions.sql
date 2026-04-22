create or replace view "dbt_catalog"."main"."silver_transactions__dbt_int" as (
        select * from '/app/silver/transactions/date=2024-01-06/data.parquet'
    );