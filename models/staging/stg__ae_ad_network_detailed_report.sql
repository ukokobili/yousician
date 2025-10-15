with
source as (

    select * from {{ source('ad_network', 'ae_ad_network_detailed_report') }}

),

renamed as (

    select
        -- dates & ids
        date,
        campaign_id,
        country_id,
        state_id,

        -- metrics
        spend,
        impressions,
        clicks,

        -- metadata columns
        current_timestamp as loaded_at

    from source

)

select *
from renamed
