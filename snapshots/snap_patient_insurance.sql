{% snapshot snap_patient_insurance %}

{{
   config(
       target_schema='snapshots',
       materialized='snapshot',
       unique_key='patient_id',
       strategy='check',
       check_cols=['insurance_id'],
       tags=['snapshots','core']
   )
}}
select 
patient_id,
insurance_id,
insurance_type
from
{{ source('raw', 'patients') }}
{% endsnapshot %}