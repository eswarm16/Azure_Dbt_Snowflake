{% macro clean_phone_numbers(column_name) %}

CONCAT(
    '+1 ',
    SUBSTR(
        REGEXP_REPLACE({{ column_name }}, '[^0-9]', ''),
        -10
    )
)

{% endmacro %}