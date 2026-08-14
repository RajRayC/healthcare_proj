-- Staging model: patients
-- Cleans and casts raw patient source data

with source as (
    select * from {{ source('raw', 'patients') }}
),

renamed as (
    select
        patient_id::varchar        as patient_id,
        first_name::varchar        as first_name,
        last_name::varchar         as last_name,
        date_of_birth::date        as date_of_birth,
        gender::varchar            as gender,
        zip_code::varchar          as zip_code,
        created_at::timestamp_ntz  as created_at
    from source
)

select * from renamed
