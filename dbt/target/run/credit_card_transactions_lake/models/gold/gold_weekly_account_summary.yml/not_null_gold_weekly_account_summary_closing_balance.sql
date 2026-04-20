select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select closing_balance
from "dbt_catalog"."main"."gold_weekly_account_summary"
where closing_balance is null



      
    ) dbt_internal_test