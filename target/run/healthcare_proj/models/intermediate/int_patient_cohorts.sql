
  create or replace   view HEALTHCARE_DB.STAGING_intermediate.int_patient_cohorts
  
  
  
  
  as (
    with encounters as (
    select *
    from HEALTHCARE_DB.STAGING_intermediate.int_patient_encounters
),

--first encounter for each patient
first_encounters as (
    select
        patient_id,
        encounter_id,
        encounter_date,
        encounter_type,
        provider_id,
        provider_name,
        specialty
        from encounters
        qualify row_number() over(partition by patient_id order by encounter_date asc)=1
),
--Month activity windows
month_activity as (
    select
    patient_id,
    date_trunc('month', encounter_date) as month_start,
    max(encounter_date) as month_end,
    count(*) as encounter_count,
    count(distinct provider_id) as distinct_provider_count,
    max(encounter_type) as most_recent_encounter_type
    from encounters
    group by patient_id, date_trunc('month', encounter_date)
),

--Cohort summary
cohort_summary as (
    select
        patient_id,
        min(encounter_date) as first_encounter_date,
        max(encounter_date) as last_encounter_date,
        count(*) as total_encounters,
        count(distinct provider_id) as total_distinct_providers,
        max(encounter_type) as most_common_encounter_type
    from encounters
    group by patient_id
)
 select * from cohort_summary
  );

