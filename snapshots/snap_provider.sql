{% snapshot snap_provider %}

{{
    config(
        target_schema='snapshots',
        unique_key='PROVIDER_ID',
        strategy='check',
        check_cols='all'
    )
}}

select
    PROVIDER_ID,
    FIRST_NAME || LAST_NAME as PROVIDER_NAME,
    SPECIALTY as PROVIDER_SPECIALTY,
from {{ source('raw', 'providers') }}

{% endsnapshot %}