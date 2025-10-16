with
source as (

    select * from {{ source('ad_network', 'ae_ad_network_country_report') }}

),

renamed as (

    select
        -- dates & ids
        date as date,
        campaign_id as campaign_id,
        country_id as country_id,

        -- metrics
        spend as spend,
        impressions as impressions,
        clicks as clicks,

        -- metadata columns
        current_timestamp as loaded_at

    from source

)

select *
from renamed
