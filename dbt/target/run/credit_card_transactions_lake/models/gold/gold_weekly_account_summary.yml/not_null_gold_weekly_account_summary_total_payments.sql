select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select total_payments
from "dbt_catalog"."main"."gold_weekly_account_summary"
where total_payments is null



      
    ) dbt_internal_test