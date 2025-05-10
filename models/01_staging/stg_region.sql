with region as (
    select * from {{ source('tpch', 'region') }}
),

final as (
    select
        r_regionkey as region_id,
        r_name as region_name,
        r_comment as comment
    from region
)

select * from final
