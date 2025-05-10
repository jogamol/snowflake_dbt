with customers as (
    select * from {{ ref('stg_customers') }}
),

nations as (
    select * from {{ ref('stg_nation') }}
),

regions as (
    select * from {{ ref('stg_region') }}
),

final as (
    select
        c.customer_id,
        c.customer_name,
        c.address,
        c.phone,
        c.account_balance,
        c.market_segment,
        n.nation_id,
        n.nation_name,
        r.region_id,
        r.region_name,
        c.valid_from,
        c.valid_to,
        c.is_current,
        c.dbt_run_id
    from customers c
    left join nations n on c.nation_id = n.nation_id
    left join regions r on n.region_id = r.region_id
)

select * from final
