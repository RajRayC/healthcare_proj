with source as (
    select * from {{ source('raw', 'encounters') }}
),
cleaned as (
    select 
        --ids
        encounter_id,
        patient_id,
        provider_id,
        facility_id,
        initcap(trim(encounter_type)) as encounter_type,
        --date validations
        encounter_date,
        discharge_date,
        case when discharge_date is not null and discharge_date> encounter_date then true else false end as valid_stay,
        discharge_disposition
    from source
)
select * from cleaned