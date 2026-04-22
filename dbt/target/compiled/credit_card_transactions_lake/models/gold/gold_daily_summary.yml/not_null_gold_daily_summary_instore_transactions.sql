
    
    



select instore_transactions
from "dbt_catalog"."main"."gold_daily_summary"
where instore_transactions is null


