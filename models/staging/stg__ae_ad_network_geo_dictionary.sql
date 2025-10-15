with
source as (

    select * from {{ source('ad_network', 'ae_ad_network_geo_dictionary') }}

),

renamed as (

    select
        -- ids & geo info
        id as location_id,
        country_code,
        name as location_name,
        location_type,

        -- metadata columns
        current_timestamp as loaded_at

    from source

)

select *
from renamed
