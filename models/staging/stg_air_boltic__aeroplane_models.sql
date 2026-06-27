with source as (
    select * from {{ source('air_boltic_raw', 'aeroplane_model') }}
),

renamed as (
    select
        trim(manufacturer) as manufacturer,
        trim(aircraft_model) as aircraft_model,
        concat(trim(manufacturer), '||', trim(aircraft_model)) as aircraft_model_key,
        cast(max_seats as int) as max_seats,
        cast(max_weight as int) as max_weight_kg,
        cast(max_distance as int) as max_distance_km,
        trim(engine_type) as engine_type,
        current_timestamp() as transformed_at
    from source
)

select * from renamed

