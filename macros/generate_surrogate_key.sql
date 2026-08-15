{% macro generate_surrogate_key(field_list) %}

    {# Guard: must pass a list, not a single string #}
    {% if field_list is string %}
        {{ exceptions.raise_compiler_error(
            "generate_surrogate_key expects a list, got a string: " ~ field_list ~
            ". Pass ['" ~ field_list ~ "'] instead."
        ) }}
    {% endif %}

    {# Guard: empty list #}
    {% if field_list | length == 0 %}
        {{ exceptions.raise_compiler_error(
            "generate_surrogate_key requires at least one field."
        ) }}
    {% endif %}

    md5(
        concat_ws(
            '||',
            {% for field in field_list %}
                coalesce(
                    trim(cast({{ field }} as varchar)),
                    '^^null^^'          {# distinct sentinel — won't collide with real values #}
                )
                {%- if not loop.last %}, {% endif %}
            {% endfor %}
        )
    )

{% endmacro %}