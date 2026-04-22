select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select avg_purchase_amount
from "dbt_catalog"."main"."gold_weekly_account_summary"
where avg_purchase_amount is null



      
    ) dbt_internal_test