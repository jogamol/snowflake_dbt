with customer_geo as (
    select * from {{ ref('int_customer_geo') }}
),

order_items as (
    select * from {{ ref('int_order_items') }}
),

final as (
    select
        c.customer_id,
        c.customer_name,
        c.market_segment,
        c.nation_name,
        c.region_name,
        c.valid_from,
        c.valid_to,
        c.is_current,
        c.dbt_run_id,
        count(distinct o.order_id) as total_orders,
        sum(o.order_total_price) as lifetime_value,
        min(o.order_date) as first_order_date,
        max(o.order_date) as most_recent_order_date,
        datediff('day', min(o.order_date), max(o.order_date)) as customer_tenure_days,
        sum(case when o.return_flag = 'R' then 1 else 0 end) as total_returns

    from customer_geo c
    left join order_items o
        on c.customer_id = o.customer_id
    group by 1, 2, 3, 4, 5, 6, 7, 8, 9
)

select * from final