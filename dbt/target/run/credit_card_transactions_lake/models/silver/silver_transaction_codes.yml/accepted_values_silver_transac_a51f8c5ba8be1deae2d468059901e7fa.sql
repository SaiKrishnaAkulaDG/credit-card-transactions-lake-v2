select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    

with all_values as (

    select
        debit_credit_indicator as value_field,
        count(*) as n_records

    from "dbt_catalog"."main"."silver_transaction_codes"
    group by debit_credit_indicator

)

select *
from all_values
where value_field not in (
    'DR','CR'
)



      
    ) dbt_internal_test