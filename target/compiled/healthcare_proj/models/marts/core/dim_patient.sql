with patients as (
    select * from HEALTHCARE_DB.STAGING_staging.stg_patients
),
churm_metrics as (
    select * from HEALTHCARE_DB.STAGING_intermediate.int_churn_metrics
),
pivots as (
    select
    patient_id,
    max(case when encounter_type='Inpatient' then 1 else 0 end) as is_inpatient,
    max(case when encounter_type='Outpatient' then 1 else 0 end) as is_outpatient,
    max(case when encounter_type='Emergency' then 1 else 0 end) as is_emergency
    from HEALTHCARE_DB.STAGING_staging.stg_encounters
    group by patient_id
)
select
    patients.*,
    churm_metrics.last_encounter_date,
    churm_metrics.last_discharge_date,
    churm_metrics.total_encounters,
    churm_metrics.distinct_encounter_types,
    churm_metrics.distinct_providers,
    churm_metrics.most_recent_encounter_type
    ,churm_metrics.churn_status
    from patients
    left join churm_metrics on patients.patient_id=churm_metrics.patient_id
    left join pivots on patients.patient_id=pivots.patient_id