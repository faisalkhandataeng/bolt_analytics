with source as (
    select * from {{ source('air_boltic_raw', 'customer_group') }}
),

renamed as (
    select
        cast(`ID` as bigint) as customer_group_id,
        trim(`Type`) as customer_group_type,
        trim(`Name`) as customer_group_name,
        trim(`Registry number`) as registry_number,
        current_timestamp() as transformed_at
    from source
)

select * from renamed

