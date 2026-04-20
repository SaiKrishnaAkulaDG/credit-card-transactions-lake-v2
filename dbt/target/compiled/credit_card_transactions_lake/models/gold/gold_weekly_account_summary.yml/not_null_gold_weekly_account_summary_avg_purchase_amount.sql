
    
    



select avg_purchase_amount
from "dbt_catalog"."main"."gold_weekly_account_summary"
where avg_purchase_amount is null


