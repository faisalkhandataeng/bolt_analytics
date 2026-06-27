with source as (
    select * from {{ source('air_boltic_raw', 'aeroplane') }}
),

renamed as (
    select
        cast(`Airplane ID` as bigint) as aircraft_id,
        trim(`Manufacturer`) as manufacturer,
        trim(`Airplane Model`) as aircraft_model,
        concat(trim(`Manufacturer`), '||', trim(`Airplane Model`)) as aircraft_model_key,
        current_timestamp() as transformed_at
    from source
)

select * from renamed

