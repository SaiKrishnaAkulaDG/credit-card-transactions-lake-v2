select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select week_start_date
from "dbt_catalog"."main"."gold_weekly_account_summary"
where week_start_date is null



      
    ) dbt_internal_test