{{ config(materialized='table') }}

with dim_zones as (
    select * from {{ ref('dim_zones') }}
    where borough != 'Unknown'
)
select 
    fhv_tripdata.dispatching_base_num,
    fhv_tripdata.pickup_datetime,
    fhv_tripdata.dropoff_datetime,
    fhv_tripdata.pulocationid,
    fhv_tripdata.dolocationid,
    fhv_tripdata.sr_flag,
    fhv_tripdata.affiliated_base_number,
    'fhv' as service_type,
    pickup_zone.borough as pickup_borough, 
    pickup_zone.zone as pickup_zone, 
    dropoff_zone.borough as dropoff_borough, 
    dropoff_zone.zone as dropoff_zone  
from {{ ref('stg_fhv_tripdata') }} AS fhv_tripdata
inner join dim_zones as pickup_zone
on fhv_tripdata.pulocationid = pickup_zone.locationid
inner join dim_zones as dropoff_zone
on fhv_tripdata.dolocationid = dropoff_zone.locationid