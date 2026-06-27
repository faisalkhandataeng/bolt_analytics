with trips as (
    select * from {{ ref('stg_air_boltic__trips') }}
),

orders as (
    select * from {{ ref('stg_air_boltic__orders') }}
),

aircraft as (
    select
        a.aircraft_id,
        a.manufacturer,
        a.aircraft_model,
        m.max_seats
    from {{ ref('stg_air_boltic__aeroplanes') }} a
    left join {{ ref('stg_air_boltic__aeroplane_models') }} m
        on a.aircraft_model_key = m.aircraft_model_key
),

orders_aggregated as (
    select
        trip_id,
        count(*) as total_orders,
        count(distinct customer_id) as unique_customers,
        sum(case when order_status = 'FINISHED' then 1 else 0 end) as finished_orders,
        sum(case when order_status = 'BOOKED' then 1 else 0 end) as booked_orders,
        sum(case when order_status = 'CANCELLED' then 1 else 0 end) as cancelled_orders,
        sum(case when order_status in ('FINISHED', 'BOOKED') then price_eur else 0 end) as gross_booking_value_eur,
        sum(case when order_status = 'FINISHED' then price_eur else 0 end) as realized_revenue_eur
    from orders
    group by trip_id
),

final as (
    select
        t.trip_id,
        t.trip_start_date,
        t.origin_city,
        t.destination_city,
        t.route_name,
        t.aircraft_id,
        a.manufacturer,
        a.aircraft_model,
        a.max_seats,
        coalesce(o.total_orders, 0) as total_orders,
        coalesce(o.unique_customers, 0) as unique_customers,
        coalesce(o.finished_orders, 0) as finished_orders,
        coalesce(o.booked_orders, 0) as booked_orders,
        coalesce(o.cancelled_orders, 0) as cancelled_orders,
        coalesce(o.gross_booking_value_eur, 0) as gross_booking_value_eur,
        coalesce(o.realized_revenue_eur, 0) as realized_revenue_eur,
        case
            when a.max_seats > 0
                then coalesce(o.finished_orders + o.booked_orders, 0) / a.max_seats
        end as booked_occupancy_rate
    from trips t
    left join orders_aggregated o on t.trip_id = o.trip_id
    left join aircraft a on t.aircraft_id = a.aircraft_id
)

select * from final
