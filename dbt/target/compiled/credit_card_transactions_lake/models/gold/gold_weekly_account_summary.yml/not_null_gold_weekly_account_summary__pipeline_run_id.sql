
    
    



select _pipeline_run_id
from "dbt_catalog"."main"."gold_weekly_account_summary"
where _pipeline_run_id is null


