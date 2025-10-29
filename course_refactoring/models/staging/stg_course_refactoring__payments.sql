with 

payments as (
    select 
        p.id as payment_id,
        p.status as payment_status,
        p.orderid as order_id, 
        p.created as payment_date, 
        p.amount as amount
    from {{source('raw_data','payments')}} p
)

select * from payments