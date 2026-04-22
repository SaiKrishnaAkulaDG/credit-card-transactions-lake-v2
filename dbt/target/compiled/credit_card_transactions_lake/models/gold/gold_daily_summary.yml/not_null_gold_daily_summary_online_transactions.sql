
    
    



select online_transactions
from "dbt_catalog"."main"."gold_daily_summary"
where online_transactions is null


