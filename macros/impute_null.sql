{% macro impute_nulls_numeric(column, strategy='mean', group_by=None, order_by=None) %}

    {% if strategy == 'mean' %}
        coalesce(
            {{ column }},
            avg({{ column }}) over (
                {{ 'partition by ' ~ group_by if group_by else '' }}
            )
        )

    {% elif strategy == 'median' %}
        {# Snowflake: use PERCENTILE_CONT as a window function directly #}
        coalesce(
            {{ column }},
            median({{ column }}) over (
                {{ 'partition by ' ~ group_by if group_by else '' }}
            )
        )

    {% elif strategy == 'mode' %}
        {{ exceptions.raise_compiler_error(
            "strategy='mode' requires a CTE pattern — use impute_nulls_mode() macro instead"
        ) }}

    {% elif strategy == 'zero' %}
        coalesce({{ column }}, 0)

    {% elif strategy == 'ffill' %}
        {# Forward fill: carry last non-null value forward within partition #}
        {% if not order_by %}
            {{ exceptions.raise_compiler_error("ffill requires order_by to be set") }}
        {% endif %}
        last_value({{ column }} ignore nulls) over (
            {{ 'partition by ' ~ group_by if group_by else '' }}
            order by {{ order_by }}
            rows between unbounded preceding and current row
        )

    {% elif strategy == 'bfill' %}
        {# Backward fill: take next non-null value within partition #}
        {% if not order_by %}
            {{ exceptions.raise_compiler_error("bfill requires order_by to be set") }}
        {% endif %}
        first_value({{ column }} ignore nulls) over (
            {{ 'partition by ' ~ group_by if group_by else '' }}
            order by {{ order_by }}
            rows between current row and unbounded following
        )

    {% else %}
        {# fallback: leave null #}
        {{ column }}

    {% endif %}

{% endmacro %}

{% macro impute_nulls_categorical(column, default='Unknown') %}
    coalesce({{column}}, {{default}})
{% endmacro %}

{% macro impute_nulls_date(column, strategy='min', group_by=None, order_by=None) %}

    {% if strategy == 'min' %}
        {# Earliest date in partition — sensible default for "first seen" dates #}
        coalesce(
            {{ column }},
            min({{ column }}) over (
                {{ 'partition by ' ~ group_by if group_by else '' }}
            )
        )

    {% elif strategy == 'max' %}
        {# Latest date in partition — useful for "last seen" / expiry dates #}
        coalesce(
            {{ column }},
            max({{ column }}) over (
                {{ 'partition by ' ~ group_by if group_by else '' }}
            )
        )

    {% elif strategy == 'median' %}
        {# Middle date in partition — Snowflake supports MEDIAN() as window fn #}
        coalesce(
            {{ column }},
            to_date(
                median(datediff('day', '1970-01-01'::date, {{ column }})) over (
                    {{ 'partition by ' ~ group_by if group_by else '' }}
                ) + '1970-01-01'::date
            )
        )

    {% elif strategy == 'today' %}
        {# Replace nulls with current_date — useful for open-ended intervals #}
        coalesce({{ column }}, current_date)

    {% elif strategy == 'fixed' %}
        {# Sentinel/placeholder date — caller must pass fixed_date param #}
        {{ exceptions.raise_compiler_error(
            "strategy='fixed' requires using impute_nulls_date_fixed() — pass the literal date there"
        ) }}

    {% elif strategy == 'ffill' %}
        {# Carry last known date forward within partition #}
        {% if not order_by %}
            {{ exceptions.raise_compiler_error("ffill requires order_by to be set") }}
        {% endif %}
        last_value({{ column }} ignore nulls) over (
            {{ 'partition by ' ~ group_by if group_by else '' }}
            order by {{ order_by }}
            rows between unbounded preceding and current row
        )

    {% elif strategy == 'bfill' %}
        {# Pull next known date backward within partition #}
        {% if not order_by %}
            {{ exceptions.raise_compiler_error("bfill requires order_by to be set") }}
        {% endif %}
        first_value({{ column }} ignore nulls) over (
            {{ 'partition by ' ~ group_by if group_by else '' }}
            order by {{ order_by }}
            rows between current row and unbounded following
        )

    {% elif strategy == 'interpolate' %}
        {# Linear interpolation between surrounding known dates               #}
        {# Requires order_by. Finds prev + next anchor dates, splits midpoint #}
        {% if not order_by %}
            {{ exceptions.raise_compiler_error("interpolate requires order_by to be set") }}
        {% endif %}
        case
            when {{ column }} is not null then {{ column }}
            else
                dateadd('day',
                    datediff('day',
                        last_value({{ column }} ignore nulls) over (
                            {{ 'partition by ' ~ group_by if group_by else '' }}
                            order by {{ order_by }}
                            rows between unbounded preceding and current row
                        ),
                        first_value({{ column }} ignore nulls) over (
                            {{ 'partition by ' ~ group_by if group_by else '' }}
                            order by {{ order_by }}
                            rows between current row and unbounded following
                        )
                    ) / 2,
                    last_value({{ column }} ignore nulls) over (
                        {{ 'partition by ' ~ group_by if group_by else '' }}
                        order by {{ order_by }}
                        rows between unbounded preceding and current row
                    )
                )
        end

    {% else %}
        {{ column }}

    {% endif %}

{% endmacro %}