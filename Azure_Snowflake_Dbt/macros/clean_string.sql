{% macro clean_string(column_name) %}
    upper(trim({{ column_name }}))
{% endmacro %}