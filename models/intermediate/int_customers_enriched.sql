with customers as (
    select * from {{ ref('stg_air_boltic__customers') }}
),

groups as (
    select * from {{ ref('stg_air_boltic__customer_groups') }}
),

orders as (
    select * from {{ ref('stg_air_boltic__orders') }}
),

customer_orders as (
    select
        customer_id,
        min(order_id) as first_order_id,
        count(*) as lifetime_orders,
        sum(case when order_status in ('FINISHED', 'BOOKED') then price_eur else 0 end) as lifetime_gbv_eur,
        sum(case when order_status = 'FINISHED' then price_eur else 0 end) as lifetime_realized_revenue_eur
    from orders
    group by customer_id
),

final as (
    select
        c.customer_id,
        c.customer_name,
        c.customer_group_id,
        g.customer_group_type,
        g.customer_group_name,
        c.email,
        c.phone_number,
        case
            when c.customer_group_id is null then 'Individual'
            when g.customer_group_id is null then 'Unknown group'
            else g.customer_group_type
        end as customer_segment,
        coalesce(o.lifetime_orders, 0) as lifetime_orders,
        coalesce(o.lifetime_gbv_eur, 0) as lifetime_gbv_eur,
        coalesce(o.lifetime_realized_revenue_eur, 0) as lifetime_realized_revenue_eur
    from customers c
    left join groups g on c.customer_group_id = g.customer_group_id
    left join customer_orders o on c.customer_id = o.customer_id
)

select * from final

