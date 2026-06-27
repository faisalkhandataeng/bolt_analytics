select
    customer_id,
    customer_name,
    customer_group_id,
    customer_group_type,
    customer_group_name,
    customer_segment,
    email,
    phone_number,
    lifetime_orders,
    lifetime_gbv_eur,
    lifetime_realized_revenue_eur
from {{ ref('int_customers_enriched') }}

