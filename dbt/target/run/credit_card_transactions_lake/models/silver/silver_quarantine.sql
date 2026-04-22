create or replace view "dbt_catalog"."main"."silver_quarantine__dbt_int" as (
        select * from '/app/silver/quarantine/data.parquet'
    );