select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select _computed_at
from "dbt_catalog"."main"."gold_weekly_account_summary"
where _computed_at is null



      
    ) dbt_internal_test