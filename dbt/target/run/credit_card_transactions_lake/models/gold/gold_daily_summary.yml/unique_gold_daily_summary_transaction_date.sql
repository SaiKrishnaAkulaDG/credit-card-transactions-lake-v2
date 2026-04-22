select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    

select
    transaction_date as unique_field,
    count(*) as n_records

from "dbt_catalog"."main"."gold_daily_summary"
where transaction_date is not null
group by transaction_date
having count(*) > 1



      
    ) dbt_internal_test