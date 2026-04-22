
    
    



select _source_period_end
from "dbt_catalog"."main"."gold_daily_summary"
where _source_period_end is null


