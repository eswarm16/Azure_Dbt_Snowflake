{{
  config(
    materialized = 'ephemeral',
    )
}}

WITH locations AS 
(
    SELECT DISTINCT
        LOCATION_ID,
        CITY AS LOCATION_CITY,
        STATE AS LOCATION_STATE,
        COUNTRY AS LOCATION_COUNTRY,
        LATITUDE,
        LONGITUDE,
        HEMISPHERE,
        LAST_UPDATED AS LOCATION_LAST_UPDATED 
    FROM
        {{ ref('silver_locations') }}
)
SELECT * FROM locations