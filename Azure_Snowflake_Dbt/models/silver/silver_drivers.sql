{{
    config(
        materialized = 'incremental',
        unique_key  = 'DRIVER_ID'
    )
}}

SELECT

    CAST(DRIVER_ID AS BIGINT) AS DRIVER_ID,
    CAST(VEHICLE_ID AS BIGINT) AS VEHICLE_ID,

    -- Driver Details
    UPPER(FIRST_NAME) AS FIRST_NAME,
    UPPER(LAST_NAME) AS LAST_NAME,
    UPPER(CONCAT(FIRST_NAME, ' ', LAST_NAME)) AS NAME,

    -- Location
    {{ clean_string('CITY') }} AS CITY,

    -- Contact
    {{ clean_phone_numbers('PHONE_NUMBER') }} AS PHONE,

    -- Rating Details
    CAST(DRIVER_RATING AS NUMERIC(3,2)) AS DRIVER_RATING,

    CASE
        WHEN DRIVER_RATING >= 4.8 THEN 'PLATINUM'
        WHEN DRIVER_RATING >= 4.5 THEN 'GOLD'
        WHEN DRIVER_RATING >= 4.0 THEN 'SILVER'
        WHEN DRIVER_RATING >= 3.0 THEN 'BRONZE'
        ELSE 'UNRATED'
    END AS RATING_TIER,

    CAST(LAST_UPDATED_TIMESTAMP AS TIMESTAMP) AS LAST_UPDATED

FROM
    {{ ref('bronze_drivers') }}