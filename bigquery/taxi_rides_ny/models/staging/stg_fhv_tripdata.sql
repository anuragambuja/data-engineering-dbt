{{ config(materialized='view') }}

select
    dispatching_base_num,
    cast(pickup_datetime as timestamp) as pickup_datetime,
    cast(dropOff_datetime as timestamp) as dropoff_datetime,
    pulocationid,
    dolocationid,
    sr_flag,
    affiliated_base_number
from {{ source('staging','fhv_tripdata') }}
