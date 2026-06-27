with aircraft as (
    select * from {{ ref('stg_air_boltic__aeroplanes') }}
),

models as (
    select * from {{ ref('stg_air_boltic__aeroplane_models') }}
),

final as (
    select
        a.aircraft_id,
        a.manufacturer,
        a.aircraft_model,
        a.aircraft_model_key,
        m.max_seats,
        m.max_weight_kg,
        m.max_distance_km,
        m.engine_type,
        case
            when m.max_seats <= 20 then 'Private jet'
            when m.max_seats <= 100 then 'Regional'
            when m.max_seats <= 220 then 'Narrow-body'
            else 'Wide-body'
        end as aircraft_size_segment
    from aircraft a
    left join models m on a.aircraft_model_key = m.aircraft_model_key
)

select * from final

