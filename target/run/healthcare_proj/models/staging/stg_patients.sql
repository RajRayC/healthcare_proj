
  create or replace   view HEALTHCARE_DB.STAGING_staging.stg_patients
  
  
  
  
  as (
    with source as (
    select * from HEALTHCARE_DB.RAW.patients
)
,
cleaned as (
    select 
        patient_id,
        --name cleaning
        initcap(trim(first_name)) as first_name,
        initcap(trim(last_name)) as last_name,
        initcap(trim(first_name)) || ' ' || initcap(trim(last_name)) as full_name,
        dob as dateofbirth,
        floor(datediff(day, dob, current_date()) / 365.25) as current_age,
        case
        when floor(datediff(day, dob, current_date()) / 365.25) < 18 then 'Child'
        when floor(datediff(day, dob, current_date()) / 365.25) between 18 and 64 then 'Adult'
        else 'Senior'
        end as age_group,
        upper(trim(gender)) as gender,
        trim(race) as race,
        trim(ethnicity) as ethnicity,
        zip_code,
        upper(state) as state,
        insurance_type,
        insurance_id,
        pcp_provider_id
    from source
)

select * from cleaned
  );

