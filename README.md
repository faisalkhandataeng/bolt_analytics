# Air Boltic Analytics Model

This repository contains a compact analytics engineering submission for Bolt's hypothetical Air Boltic marketplace.

## Goal

Design a reliable, scalable and self-service-friendly data model for monitoring:

- growth by customer, route, aircraft and region-like dimensions
- daily/weekly/monthly active users
- revenue and gross booking value
- aircraft supply and occupancy
- cancellation and booking quality

## Source Data

The assignment provides five source tables and one JSON file:

| Source | Grain | Notes |
|---|---:|---|
| `customer` | one row per customer | Some customers have no group, email or phone |
| `customer_group` | one row per group | Current sample is incomplete for some customer references |
| `aeroplane` | one row per aircraft | Links aircraft to manufacturer/model |
| `aeroplane_model.json` | one row per manufacturer/model after flattening | Provides max seats, max distance, weight and engine |
| `trip` | one row per flight/trip | Local timestamps need timezone handling |
| `order` | one row per seat order | Status values: Finished, Booked, Cancelled |

## Model Layers

| Layer | Purpose | Example Models |
|---|---|---|
| Staging | Rename, type cast and standardise raw columns | `stg_air_boltic__orders`, `stg_air_boltic__trips` |
| Intermediate | Join/aggregate reusable business logic | `int_trip_bookings`, `int_customers_enriched` |
| Marts | Self-service facts, dimensions and metrics | `fct_orders`, `fct_trips`, `dim_customer`, `dim_aircraft`, `mart_air_boltic_growth_metrics` |

## Key Metrics

| Metric | Definition |
|---|---|
| DAU | Distinct customers with at least one order on the trip service date |
| Gross booking value | Sum of `Booked` and `Finished` order price; cancelled orders excluded |
| Realized revenue | Sum of `Finished` order price |
| Occupancy rate | Booked plus finished seats divided by aircraft max seats |
| Cancellation rate | Cancelled orders divided by total orders |

## How I Would Run This

1. Land raw extracts in immutable S3 paths by source and ingestion date.
2. Expose raw Delta tables in Databricks.
3. Run dbt staging, intermediate and mart models.
4. Publish marts to Looker with governed metric definitions.
5. Monitor freshness, volume, schema changes, nulls, relationships and metric anomalies.

## Local Notes

This repository is intentionally not a full deployment. It focuses on the modeling, dbt structure, tests and engineering decisions that are most relevant for the assignment review.

