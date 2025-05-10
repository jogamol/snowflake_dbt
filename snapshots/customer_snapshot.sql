-- snapshots/customer_snapshot.sql
{% snapshot customer_snapshot %}

{{
    config(
      target_database='analytics',
      target_schema='snapshots',
      unique_key='c_custkey',
      strategy='timestamp',
      updated_at='updated_at',
    )
}}

select
    c_custkey,
    c_name,
    c_address,
    c_nationkey,
    c_phone,
    c_acctbal,
    c_mktsegment,
    c_comment,
    current_timestamp() as updated_at
from {{ source('tpch', 'customer') }}

{% endsnapshot %}
