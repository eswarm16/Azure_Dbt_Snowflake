{{
    config(
        materialized = 'incremental',
        unique_key  = 'CUSTOMER_ID'
    )
}}

SELECT

    CAST(CUSTOMER_ID AS BIGINT) AS CUSTOMER_ID,

    -- Customer Details
    UPPER(FIRST_NAME) AS FIRST_NAME,
    UPPER(LAST_NAME) AS LAST_NAME,
    UPPER(CONCAT(FIRST_NAME, ' ', LAST_NAME)) AS NAME,

    -- Contact Details
    {{ clean_phone_numbers('PHONE_NUMBER') }} AS PHONE,
    {{ clean_string('EMAIL') }} AS EMAIL,

    CASE
        WHEN EMAIL IS NOT NULL
         AND EMAIL ILIKE '%@%.%'
        THEN 'TRUE'
        ELSE 'FALSE'
    END AS EMAIL_VALID,

    -- Location
    {{ clean_string('CITY') }} AS CITY,

    -- Dates
    CAST(SIGNUP_DATE AS DATE) AS SIGNUP_DATE,

    EXTRACT(YEAR  FROM SIGNUP_DATE) AS SIGNUP_YEAR,
    EXTRACT(MONTH FROM SIGNUP_DATE) AS SIGNUP_MONTH,

    CAST(LAST_UPDATED_TIMESTAMP AS TIMESTAMP) AS LAST_UPDATED

FROM
    {{ ref('bronze_customers') }}