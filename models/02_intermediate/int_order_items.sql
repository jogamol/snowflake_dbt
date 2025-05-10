with orders as (
    select * from {{ ref('stg_orders') }}
),

line_items as (
    select * from {{ ref('stg_lineitems') }}
),

final as (
    select
        o.order_id,
        o.customer_id,
        o.order_date,
        o.order_status,
        o.total_price as order_total_price,
        li.line_number,
        li.part_id,
        li.quantity,
        li.extended_price,
        li.discount,
        li.net_item_price,
        li.total_item_price,
        li.ship_date,
        li.receipt_date,
        li.return_flag
    from orders o
    inner join line_items li on o.order_id = li.order_id
)

select * from final
