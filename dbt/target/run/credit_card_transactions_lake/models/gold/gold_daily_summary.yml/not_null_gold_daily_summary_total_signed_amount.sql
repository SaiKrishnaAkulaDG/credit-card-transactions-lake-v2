select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select total_signed_amount
from "dbt_catalog"."main"."gold_daily_summary"
where total_signed_amount is null



      
    ) dbt_internal_test