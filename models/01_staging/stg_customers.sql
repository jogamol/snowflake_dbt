with customer as (
    select * from {{ source('tpch', 'customer') }}
),

final as (
    select
        c_custkey as customer_id,
        c_name as customer_name,
        c_address as address,
        c_nationkey as nation_id,
        c_phone as phone,
        c_acctbal as account_balance,
        c_mktsegment as market_segment,
        c_comment as comment,
        current_timestamp() as valid_from,
        null as valid_to,
        true as is_current,
        '{{ invocation_id }}' as dbt_run_id
    from customer
)

select * from final
