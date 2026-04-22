create or replace view "dbt_catalog"."main"."silver_accounts__dbt_int" as (
        select * from '/app/silver/accounts/data.parquet'
    );