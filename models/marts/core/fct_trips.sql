select
    trip_id,
    trip_start_date,
    origin_city,
    destination_city,
    route_name,
    aircraft_id,
    manufacturer,
    aircraft_model,
    max_seats,
    total_orders,
    unique_customers,
    finished_orders,
    booked_orders,
    cancelled_orders,
    gross_booking_value_eur,
    realized_revenue_eur,
    booked_occupancy_rate
from {{ ref('int_trip_bookings') }}

