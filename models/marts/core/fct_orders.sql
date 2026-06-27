with orders as (
    select * from {{ ref('stg_air_boltic__orders') }}
),

trips as (
    select trip_id, trip_start_date, route_name, aircraft_id from {{ ref('stg_air_boltic__trips') }}
),

final as (
    select
        o.order_id,
        o.customer_id,
        o.trip_id,
        t.trip_start_date as order_service_date,
        t.route_name,
        t.aircraft_id,
        o.price_eur,
        o.seat_no,
        o.order_status,
        case when o.order_status in ('FINISHED', 'BOOKED') then o.price_eur else 0 end as gross_booking_value_eur,
        case when o.order_status = 'FINISHED' then o.price_eur else 0 end as realized_revenue_eur,
        case when o.order_status = 'CANCELLED' then 1 else 0 end as is_cancelled
    from orders o
    left join trips t on o.trip_id = t.trip_id
)

select * from final

