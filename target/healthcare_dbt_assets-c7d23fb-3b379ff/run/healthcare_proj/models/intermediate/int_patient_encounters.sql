
  create or replace   view HEALTHCARE_DB.STAGING_intermediate.int_patient_encounters
  
  
  
  
  as (
    with patients as (
    select * from HEALTHCARE_DB.STAGING_staging.stg_patients
),
encounters as (
    select * from HEALTHCARE_DB.STAGING_staging.stg_encounters
),
diagnoses as (
    select * from HEALTHCARE_DB.RAW.diagnoses
),
providers as (
    select * from HEALTHCARE_DB.RAW.providers
),
joined as (
    select
        e.encounter_id,
        e.patient_id,
        e.provider_id,
        e.facility_id,
        e.encounter_type,
        e.encounter_date,
        e.discharge_date,
        e.discharge_disposition,

        --patient data
        full_name,
        gender,
        race,
        state,
        insurance_type

        --provider info
        provider_name,
        specialty,
        npi

    from encounters e
    left join patients p on e.patient_id=p.patient_id
    left join providers prov on p.pcp_provider_id=prov.provider_id

)

select * from joined
  );

