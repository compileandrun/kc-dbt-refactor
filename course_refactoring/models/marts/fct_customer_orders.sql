{{config(
   materialized = 'incremental',
   unique_key = 'order_id',
   incremental_strategy = 'merge',
   on_schema_change = 'fail'
   )
   }}



WITH 

orders as (
    SELECT
        order_id,
        customer_id,
        order_placed_at,
        order_status,
        order_date
    FROM {{ref('stg_course_refactoring__orders')}} as Orders
),

payments as (
    select 
        p.order_id, 
        max(p.payment_date) as payment_finalized_date, 
        sum(p.amount) / 100.0 as total_amount_paid
    from {{ref('stg_course_refactoring__payments')}} p
    where p.payment_status <> 'fail'
    group by 1
),

customers as (
    select 
        c.customer_first_name,
        c.customer_last_name,
        c.customer_id
    FROM {{ref('stg_course_refactoring__customers')}} c

),

paid_orders as ( #grain payment
    select 
        orders.order_id,
        orders.customer_id,
        orders.order_placed_at,
        orders.order_status,
        p.total_amount_paid,
        p.payment_finalized_date,
        c.customer_first_name,
        c.customer_last_name
    FROM orders
    left join payments p ON orders.order_id = p.order_id
    left join customers c on orders.customer_id = c.customer_id 
    
),

customer_orders as ( #grain orders

    select 
        c.customer_id, 
        min(orders.order_date) as first_order_date,
        max(orders.order_date) as most_recent_order_date,
        count(orders.order_id) AS number_of_orders
    from customers c 
    left join orders
    on orders.customer_id = c.customer_id 
    group by 1
),

clv as ( #grain order
 #Im correcting this cte because I dont know why we cross joined on paid orders.
    select
        p.order_id,
        sum(t2.total_amount_paid) as customer_lifetime_value
    from paid_orders p
    left join paid_orders t2 on p.customer_id = t2.customer_id and p.order_id >= t2.order_id
    group by 1
    #order by p.order_id # dont need ordering
)

select
    p.*,
    ROW_NUMBER() OVER (ORDER BY p.order_id) as transaction_seq,
    ROW_NUMBER() OVER (PARTITION BY c.customer_id ORDER BY p.order_id) as customer_sales_seq,
    CASE 
        WHEN c.first_order_date = p.order_placed_at
        THEN 'new'
        ELSE 'return' 
    END as nvsr,

    clv.customer_lifetime_value,
    c.first_order_date as fdos
FROM paid_orders p
LEFT JOIN customer_orders c USING (customer_id)
LEFT JOIN clv ON clv.order_id = p.order_id

{% if is_incremental() %}

  -- this filter will only be applied on an incremental run
  -- (uses >= to include records whose timestamp occurred since the last run of this model)
  -- (If event_time is NULL or the table is truncated, the condition will always be true and load all records)
--where order_placed_at >= (select coalesce(max(order_placed_at),'1900-01-01') from {{ this }} )
where order_placed_at >= '2025-01-01' --I simply put this because it was easier

{% endif %}

ORDER BY order_id




