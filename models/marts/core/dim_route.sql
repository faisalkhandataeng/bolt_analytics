with routes as (
    select
        origin_city,
        destination_city,
        route_name,
        count(*) as trip_count,
        min(trip_start_date) as first_trip_date,
        max(trip_start_date) as latest_trip_date
    from {{ ref('stg_air_boltic__trips') }}
    group by 1, 2, 3
)

select
    md5(route_name) as route_id,
    origin_city,
    destination_city,
    route_name,
    trip_count,
    first_trip_date,
    latest_trip_date
from routes

