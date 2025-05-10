with nations as (
    select * from {{ ref('stg_nation') }}
),

regions as (
    select * from {{ ref('stg_region') }}
),

final as (
    select
        {{ dbt_utils.generate_surrogate_key(['n.nation_id']) }} as geo_key,
        n.nation_id,
        n.nation_name,
        r.region_id,
        r.region_name
    from nations n
    inner join regions r on n.region_id = r.region_id
)

select * from final
