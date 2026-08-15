{{
    config(
        materialized='incremental',
        unique_key='encounter_id',
        incremental_strategy='merge',
        tags=['marts','core']
    )
}}

with encounters as(
    select *
    from {{ ref('stg_encounters') }}
),
dx as (
    select *
    from {{ source('raw','diagnoses') }}
),
mds as (
    select *
    from {{ source('raw','medications') }}
),
pivots as
(
    --diagnoses
    select
    encounter_id,
    count(*) as diagnosis_count,
    max(case when icd10_code like 'I%' then 1 else 0 end) as has_cardiovascular_dx,
    max(case when icd10_code like 'J%' then 1 else 0 end) as has_respiratory_dx,
    count(distinct medication_id) as distinct_medication_count
    from dx
    left join mds using(encounter_id)
    group by encounter_id
)
select 
    encounters.*,
    pivots.diagnosis_count,
    pivots.has_cardiovascular_dx,
    pivots.has_respiratory_dx,
    pivots.distinct_medication_count
from encounters
left join pivots using(encounter_id)

{% if is_incremental() %}
  where encounters.encounter_date > (select max(encounter_date) from {{ this }})
{% endif %}

