select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select online_transactions
from "dbt_catalog"."main"."gold_daily_summary"
where online_transactions is null



      
    ) dbt_internal_test