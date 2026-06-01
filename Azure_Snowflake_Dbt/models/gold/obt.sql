{% set congig = [
    {
        "ref": "silver_trips",
        "columns" : "trips.TRIP_ID, trips.LOCATION AS TRIP_LOCATION, trips.TRIP_START_TIME, trips.TRIP_END_TIME, trips.DISTANCE AS TRIP_DISTANCE, trips.DISTANCE_CATEGORY AS TRIP_DISTANCE_CATEGORY, trips.DURATION_MINUTES AS TRIP_DURATION_MINUTES, trips.AMOUNT AS TRIP_AMOUNT, trips.FARE_TIER AS TRIP_FARE_TIER, trips.PAYMENT_METHOD AS TRIP_PAYMENT_METHOD, trips.TRIP_STATUS, trips.LAST_UPDATED AS TRIP_LAST_UPDATED ",
        "alias": "trips"
    },

    {
        "ref": "silver_customers",
        "columns" : "customers.CUSTOMER_ID, customers.NAME AS CUSTOMER_NAME, customers.PHONE AS CUSTOMER_PHONE, customers.EMAIL AS CUSTOMER_EMAIL, customers.EMAIL_VALID AS CUSTOMER_EMAIL_VALID, customers.CITY AS CUSTOMER_CITY, customers.SIGNUP_DATE AS CUSTOMER_SIGNUP_DATE,customers.SIGNUP_YEAR AS CUSTOMER_SIGNUP_YEAR,customers.SIGNUP_MONTH AS CUSTOMER_SIGNUP_MONTH ,customers.LAST_UPDATED AS CUSTOMER_LAST_UPDATED ",
        "alias": "customers",
        "join_condition" : "trips.CUSTOMER_ID = customers.CUSTOMER_ID"
    },

    {
        "ref": "silver_drivers",
        "columns" : "drivers.DRIVER_ID, drivers.VEHICLE_ID, drivers.NAME AS DRIVER_NAME, drivers.CITY AS DRIVER_CITY, drivers.PHONE AS DRIVER_PHONE,drivers.DRIVER_RATING, drivers.RATING_TIER, drivers.LAST_UPDATED AS DRIVER_LAST_UPDATED ",
        "alias": "drivers",
        "join_condition": "trips.DRIVER_ID = drivers.DRIVER_ID"
    },

    {
        "ref": "silver_locations",
        "columns" : "locations.LOCATION_ID,locations.CITY AS LOCATION_CITY,locations.STATE AS LOCATION_STATE, locations.COUNTRY AS LOCATION_COUNTRY, locations.LATITUDE, locations.LONGITUDE, locations.HEMISPHERE, locations.LAST_UPDATED AS LOCATION_LAST_UPDATED ",
        "alias": "locations",
        "join_condition": "locations.CITY = trips.LOCATION"

    }
] %} 
WITH base AS (
select
    {% for config in congig %}
        {{ config['columns'] }}{% if not loop.last %}, {% endif %}
    {% endfor %}

from
    {% for config in congig %}
        {% if loop.first %}
            {{ ref(config['ref']) }} as {{ config['alias'] }}
        {% else %}
            left join {{ ref(config['ref']) }} as {{ config['alias'] }}
            on {{ config['join_condition'] }}
        {% endif %}
    {% endfor %}
)
SELECT
    TRIP_ID,
    LOCATION_ID,
    CUSTOMER_ID,
    DRIVER_ID,
    VEHICLE_ID,
    CUSTOMER_NAME,
    CUSTOMER_PHONE,
    CUSTOMER_EMAIL,
    CUSTOMER_EMAIL_VALID,
    CUSTOMER_CITY,
    CUSTOMER_SIGNUP_DATE,
    CUSTOMER_SIGNUP_YEAR,
    CUSTOMER_SIGNUP_MONTH,
    DRIVER_NAME,
    DRIVER_CITY,
    DRIVER_PHONE,
    DRIVER_RATING,
    RATING_TIER,
    LOCATION_STATE,
    LOCATION_COUNTRY,
    LATITUDE,
    LONGITUDE,
    HEMISPHERE,
    TRIP_LOCATION,
    TRIP_START_TIME,
    TRIP_END_TIME,
    TRIP_DISTANCE,
    TRIP_DISTANCE_CATEGORY,
    TRIP_DURATION_MINUTES,
    TRIP_AMOUNT,
    TRIP_FARE_TIER,
    TRIP_PAYMENT_METHOD,
    TRIP_STATUS,
    CUSTOMER_LAST_UPDATED,
    DRIVER_LAST_UPDATED,
    LOCATION_LAST_UPDATED,
    TRIP_LAST_UPDATED

FROM base