select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select instore_transactions
from "dbt_catalog"."main"."gold_daily_summary"
where instore_transactions is null



      
    ) dbt_internal_test