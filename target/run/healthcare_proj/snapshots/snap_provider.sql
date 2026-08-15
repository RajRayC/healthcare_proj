
      
  
    

create or replace transient table HEALTHCARE_DB.snapshots.snap_provider
    
    
    
    as (
    

    select *,
        md5(coalesce(cast(PROVIDER_ID as varchar ), '')
         || '|' || coalesce(cast(to_timestamp_ntz(convert_timezone('UTC', current_timestamp())) as varchar ), '')
        ) as dbt_scd_id,
        to_timestamp_ntz(convert_timezone('UTC', current_timestamp())) as dbt_updated_at,
        to_timestamp_ntz(convert_timezone('UTC', current_timestamp())) as dbt_valid_from,
        
  
  coalesce(nullif(to_timestamp_ntz(convert_timezone('UTC', current_timestamp())), to_timestamp_ntz(convert_timezone('UTC', current_timestamp()))), null)
  as dbt_valid_to
from (
        



select
    PROVIDER_ID,
    FIRST_NAME || LAST_NAME as PROVIDER_NAME,
    SPECIALTY as PROVIDER_SPECIALTY,
from HEALTHCARE_DB.RAW.providers

    ) sbq



    )
;


  
  