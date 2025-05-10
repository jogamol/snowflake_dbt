with customer_value as (
    select * from {{ ref('fct_customer_value') }}
    -- Removed the is_current filter since the column doesn't exist
),
customer_dim as (
    select * from {{ ref('dim_customers_scd2') }}
    where is_current = true
),
order_facts as (
    select
        customer_key,
        count(order_key) as order_count,
        sum(total_net_price) as total_spent,
        avg(total_net_price) as avg_order_value,
        max(order_date) as last_order_date
    from {{ ref('fct_orders') }}
    group by 1
),
final as (
    select
        customer_dim.customer_key,
        customer_dim.customer_id,
        customer_dim.customer_name,
        customer_dim.address,
        customer_dim.phone,
        customer_dim.account_balance,
        customer_dim.market_segment,
        customer_dim.nation_name,
        customer_dim.region_name,
        customer_value."total_orders",
        customer_value."lifetime_value",
        customer_value."first_order_date",
        customer_value."most_recent_order_date",
        customer_value."customer_tenure_days",
        customer_value."total_returns",
        customer_value."recency",
        customer_value."frequency",
        customer_value."monetary",
        customer_value."customer_segment",
        customer_value."health_score",
        order_facts.order_count,
        order_facts.total_spent,
        order_facts.avg_order_value,

        -- Return rate calculation with proper null handling
        case
            when coalesce(customer_value."total_returns", 0) = 0 then 0
            else coalesce(customer_value."total_returns", 0)::float / nullif(coalesce(customer_value."total_orders", 0), 0)
        end as return_rate,

        -- Industry vertical mapping
        case
            when customer_dim.market_segment = 'BUILDING' then 'Construction'
            when customer_dim.market_segment = 'AUTOMOBILE' then 'Automotive'
            when customer_dim.market_segment = 'MACHINERY' then 'Industrial'
            when customer_dim.market_segment = 'HOUSEHOLD' then 'Consumer'
            when customer_dim.market_segment = 'FURNITURE' then 'Furniture'
            else customer_dim.market_segment
        end as industry_vertical
    from customer_dim
    left join customer_value on customer_dim.customer_id = customer_value."customer_id"
    left join order_facts on customer_dim.customer_key = order_facts.customer_key
)
select * from final