with source as(
    select * from {{ source('raw', 'claims') }}
),
cleaned as (
    select
        claim_id,
        patient_id,
        encounter_id,
        payer_id,
        initcap(trim(claim_type)) as claim_type,
        submitted_date,
        paid_date
        --financial data
        billed_amount,
        paid_amount,
        allowed_amount,
        --claim status
        initcap(trim(claim_status)) as claim_status
        from source
)
select * from cleaned