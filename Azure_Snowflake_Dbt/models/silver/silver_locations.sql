{{
    config(
        materialized = 'incremental',
        unique_key  = 'LOCATION_ID'
    )
}}

SELECT

    CAST(LOCATION_ID AS BIGINT) AS LOCATION_ID,

    -- Location Details
    {{ clean_string('CITY') }} AS CITY,
    {{ clean_string('STATE') }} AS STATE,
    {{ clean_string('COUNTRY') }} AS COUNTRY,

    -- Coordinates
    CAST(LATITUDE  AS NUMERIC(10,6)) AS LATITUDE,
    CAST(LONGITUDE AS NUMERIC(10,6)) AS LONGITUDE,

    -- Derived Attributes
    CASE
        WHEN LATITUDE >= 0 THEN 'NORTHERN'
        ELSE 'SOUTHERN'
    END AS HEMISPHERE,

    CAST(LAST_UPDATED_TIMESTAMP AS TIMESTAMP) AS LAST_UPDATED

FROM
    {{ ref('bronze_locations') }}