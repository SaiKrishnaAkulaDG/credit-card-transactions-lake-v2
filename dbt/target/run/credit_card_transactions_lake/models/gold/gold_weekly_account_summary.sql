create or replace view "dbt_catalog"."main"."gold_weekly_account_summary__dbt_int" as (
        select * from '/app/gold/weekly_account_summary/data.parquet'
    );