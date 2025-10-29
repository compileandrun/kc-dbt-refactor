with 
orders as (
    SELECT
        id as order_id,
        user_id as customer_id,
        order_date as order_placed_at,
        status as order_status,
        order_date
    FROM {{source('raw_data','orders')}} as Orders
)

select * from orders