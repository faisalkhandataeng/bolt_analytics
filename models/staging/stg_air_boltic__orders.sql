with source as (
    select * from {{ source('air_boltic_raw', 'order') }}
),

renamed as (
    select
        cast(`Order ID` as bigint) as order_id,
        cast(`Customer ID` as bigint) as customer_id,
        cast(`Trip ID` as bigint) as trip_id,
        cast(`Price (EUR)` as decimal(18, 2)) as price_eur,
        upper(trim(`Seat No`)) as seat_no,
        upper(trim(`Status`)) as order_status,
        current_timestamp() as transformed_at
    from source
)

select * from renamed

