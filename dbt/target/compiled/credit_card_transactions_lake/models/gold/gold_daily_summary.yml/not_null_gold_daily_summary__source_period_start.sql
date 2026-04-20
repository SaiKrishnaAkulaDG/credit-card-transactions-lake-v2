
    
    



select _source_period_start
from "dbt_catalog"."main"."gold_daily_summary"
where _source_period_start is null


