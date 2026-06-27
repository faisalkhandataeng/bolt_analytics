with source as (
    select * from {{ source('air_boltic_raw', 'customer') }}
),

renamed as (
    select
        cast(`Customer ID` as bigint) as customer_id,
        trim(`Name`) as customer_name,
        cast(`Customer Group ID` as bigint) as customer_group_id,
        lower(trim(`Email`)) as email,
        trim(`Phone Number`) as phone_number,
        current_timestamp() as transformed_at
    from source
)

select * from renamed

