with
source as (

    select * from {{ source('ad_network', 'ae_ad_network_campaign_updates') }}

),

renamed as (

    select
        -- ids & dates
        campaign_id,
        update_date as updated_date,

        -- campaign info            
        name as campaign_name,

        -- metadata columns
        current_timestamp as loaded_at

    from source
    -- get the latest update per campaign
    qualify
        row_number()
            over (partition by campaign_id, name order by update_date desc)
        = 1

)

select *
from renamed
