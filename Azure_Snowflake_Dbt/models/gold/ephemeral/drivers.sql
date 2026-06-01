{{
  config(
    materialized = 'ephemeral',
    )
}}

WITH drivers AS 
(
    SELECT DISTINCT
        DRIVER_ID,
        VEHICLE_ID,
        NAME AS DRIVER_NAME,
        CITY AS DRIVER_CITY,
        PHONE AS DRIVER_PHONE,
        DRIVER_RATING,
        RATING_TIER AS DRIVER_RATING_TIER,
        LAST_UPDATED AS DRIVER_LAST_UPDATED 
    FROM
        {{ ref('silver_drivers') }}
)
SELECT * FROM drivers