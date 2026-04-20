create or replace view "dbt_catalog"."main"."gold_daily_summary__dbt_int" as (
        select * from '/app/gold/daily_summary/data.parquet'
    );