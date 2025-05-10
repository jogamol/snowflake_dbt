{{
    config(
        materialized='incremental',
        unique_key=['customer_id', 'valid_from'],
        tags=['mart', 'scd2']
    )
}}

with customer_history as (
    select * from {{ ref('int_customer_geo') }}
    {% if is_incremental() %}
    -- Only get new or changed records
    where valid_from > (select max(valid_from) from {{ this }})
    {% endif %}
),

-- Generate surrogate key for SCD2
final as (
    select
        {{ dbt_utils.generate_surrogate_key(['customer_id', 'valid_from']) }} as customer_key,
        customer_id,
        customer_name,
        address,
        phone,
        account_balance,
        market_segment,
        nation_id,
        nation_name,
        region_id,
        region_name,
        valid_from,
        valid_to,
        is_current,
        dbt_run_id
    from customer_history
)

select * from final
