{{ config(materialized='incremental') }}
 
SELECT * FROM {{ source('public', 'Trips') }}
 
{% if is_incremental() %}
    WHERE LAST_UPDATED_TIMESTAMP > (SELECT COALESCE(MAX(LAST_UPDATED_TIMESTAMP), '1900-01-01') FROM {{ this }})
{% endif %}
