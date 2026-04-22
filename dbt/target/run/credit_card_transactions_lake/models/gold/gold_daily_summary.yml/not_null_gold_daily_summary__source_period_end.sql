select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select _source_period_end
from "dbt_catalog"."main"."gold_daily_summary"
where _source_period_end is null



      
    ) dbt_internal_test