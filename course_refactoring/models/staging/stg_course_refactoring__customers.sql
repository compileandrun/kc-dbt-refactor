{{config(
    materialized = 'table'
)}}

with 

customers as (
    select 
        first_name  as customer_first_name,
        last_name   as customer_last_name,
        id as customer_id
    FROM {{source('raw_data','customers')}}

)

select * from customers