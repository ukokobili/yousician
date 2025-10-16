with
source as (select * from {{ source('ad_network', 'ae_ad_network_report_2') }}),

renamed as (

    select
        -- dates & ids
        date,
        id as campaign_id,

        -- campaign info
        campaign_name,

        -- geo info
        null as country_code,
        null as state_name,
        null as location_type,

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
