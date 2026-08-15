

with encounters as(
    select *
    from HEALTHCARE_DB.STAGING_staging.stg_encounters
),
dx as (
    select *
    from HEALTHCARE_DB.RAW.diagnoses
),
mds as (
    select *
    from HEALTHCARE_DB.RAW.medications
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


  where encounters.encounter_date > (select max(encounter_date) from HEALTHCARE_DB.STAGING_marts.fact_encounters)
