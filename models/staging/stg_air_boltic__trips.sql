with source as (
    select * from {{ source('air_boltic_raw', 'trip') }}
),

renamed as (
    select
        cast(`Trip ID` as bigint) as trip_id,
        trim(`Origin City`) as origin_city,
        trim(`Destination City`) as destination_city,
        concat(trim(`Origin City`), ' -> ', trim(`Destination City`)) as route_name,
        cast(`Airplane ID` as bigint) as aircraft_id,
        cast(`Start Timestamp` as timestamp) as start_at_local,
        cast(`End Timestamp` as timestamp) as end_at_local,
        to_date(cast(`Start Timestamp` as timestamp)) as trip_start_date,
        current_timestamp() as transformed_at
    from source
)

select * from renamed

