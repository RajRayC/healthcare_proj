
  create or replace   view HEALTHCARE_DB.STAGING_intermediate.int_churn_metrics
  
  
  
  
  as (
    with encounters as(
    select *
    from HEALTHCARE_DB.STAGING_staging.stg_encounters
),
latest_activity as (
    select
        patient_id,
        max(encounter_date) as last_encounter_date,
        max(discharge_date) as last_discharge_date,
        count(*) as total_encounters,
        count(distinct(encounter_type)) as distinct_encounter_types,
        count(distinct(provider_id)) as distinct_providers,
        max(encounter_type) as most_recent_encounter_type
    from encounters
    group by patient_id
),

--churn metrics
churn_metrics as (
    select
        patient_id,
        last_encounter_date,
        last_discharge_date,
        total_encounters,
        distinct_encounter_types,
        distinct_providers,
        most_recent_encounter_type,
        case
            when last_encounter_date < dateadd(month, -6, current_date()) then 'Churned/Inactive'
            when last_encounter_date >= dateadd(month, -6, current_date()) and last_encounter_date < dateadd(month, -3, current_date()) then 'At Risk'
            else 'Active'
        end as churn_status
        from latest_activity
)
select * from churn_metrics
  );

