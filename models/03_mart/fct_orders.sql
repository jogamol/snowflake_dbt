with order_items as (
    select * from {{ ref('int_order_items') }}
),

customer_dim as (
    select * from {{ ref('dim_customers_scd2') }}
    where is_current = true
),

final as (
    select
        {{ dbt_utils.generate_surrogate_key(['oi.order_id']) }} as order_key,
        oi.order_id,
        c.customer_key,
        oi.order_date,
        oi.order_status,
        count(distinct oi.line_number) as line_item_count,
        sum(oi.quantity) as total_quantity,
        sum(oi.extended_price) as total_extended_price,
        sum(oi.discount * oi.extended_price) as total_discount_amount,
        sum(oi.net_item_price) as total_net_price,
        sum(oi.total_item_price) as total_price_with_tax,
        min(oi.ship_date) as first_ship_date,
        max(oi.ship_date) as last_ship_date,
        min(oi.receipt_date) as first_receipt_date,
        max(oi.receipt_date) as last_receipt_date,
        sum(case when oi.return_flag = 'R' then 1 else 0 end) as return_count
    from order_items oi
    inner join customer_dim c on oi.customer_id = c.customer_id
    group by 1, 2, 3, 4, 5
)

select * from final

