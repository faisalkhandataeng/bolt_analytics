{{ config(
    materialized='incremental',
    unique_key='metric_date',
    incremental_strategy='merge'
) }}

with orders as (
    select * from {{ ref('fct_orders') }}
    {% if is_incremental() %}
        where order_service_date >= date_sub(current_date(), 7)
    {% endif %}
),

trips as (
    select * from {{ ref('fct_trips') }}
    {% if is_incremental() %}
        where trip_start_date >= date_sub(current_date(), 7)
    {% endif %}
),

daily_orders as (
    select
        order_service_date as metric_date,
        count(distinct customer_id) as active_customers,
        count(*) as orders,
        sum(case when order_status = 'FINISHED' then 1 else 0 end) as finished_orders,
        sum(case when order_status = 'BOOKED' then 1 else 0 end) as booked_orders,
        sum(is_cancelled) as cancelled_orders,
        sum(gross_booking_value_eur) as gross_booking_value_eur,
        sum(realized_revenue_eur) as realized_revenue_eur
    from orders
    group by 1
),

daily_trips as (
    select
        trip_start_date as metric_date,
        count(*) as trips,
        count(distinct route_name) as active_routes,
        count(distinct aircraft_id) as active_aircraft,
        avg(booked_occupancy_rate) as avg_booked_occupancy_rate
    from trips
    group by 1
),

final as (
    select
        coalesce(o.metric_date, t.metric_date) as metric_date,
        coalesce(o.active_customers, 0) as dau,
        coalesce(o.orders, 0) as orders,
        coalesce(o.finished_orders, 0) as finished_orders,
        coalesce(o.booked_orders, 0) as booked_orders,
        coalesce(o.cancelled_orders, 0) as cancelled_orders,
        coalesce(o.gross_booking_value_eur, 0) as gross_booking_value_eur,
        coalesce(o.realized_revenue_eur, 0) as realized_revenue_eur,
        coalesce(t.trips, 0) as completed_or_scheduled_trips,
        coalesce(t.active_routes, 0) as active_routes,
        coalesce(t.active_aircraft, 0) as active_aircraft,
        t.avg_booked_occupancy_rate,
        case
            when o.orders > 0 then o.cancelled_orders / o.orders
            else 0
        end as cancellation_rate
    from daily_orders o
    full outer join daily_trips t on o.metric_date = t.metric_date
)

select * from final

