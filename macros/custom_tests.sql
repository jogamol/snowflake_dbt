-- macros/custom_tests.sql
{% macro test_minimum_lifetime_value(model, column_name, min_value) %}

with validation as (
    select
        {{ column_name }} as lifetime_value
    from {{ model }}
    where is_current = true
),

validation_errors as (
    select
        lifetime_value
    from validation
    where lifetime_value < {{ min_value }}
)

select count(*)
from validation_errors

{% endmacro %}

{% macro test_order_count_consistency(model) %}

with customer_orders as (
    select
        customer_id,
        total_orders
    from {{ model }}
    where is_current = true
),

orders_fact as (
    select
        o.customer_id,
        count(*) as actual_order_count
    from {{ ref('stg_orders') }} o
    group by 1
),

validation_errors as (
    select
        co.customer_id,
        co.total_orders as reported_order_count,
        of.actual_order_count
    from customer_orders co
    inner join orders_fact of on co.customer_id = of.customer_id
    where co.total_orders != of.actual_order_count
)

select count(*)
from validation_errors

{% endmacro %}
