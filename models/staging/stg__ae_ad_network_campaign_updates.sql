with source as (
    select *
    from {{ source('ad_network', 'ae_ad_network_campaign_updates') }}
),

-- duplicate to get the latest update per campaign
deduplicated as (
    {{ dbt_utils.deduplicate(
        relation='source',
        partition_by='campaign_id, name',
        order_by='update_date desc'
    ) }}
),

renamed as (
    select
        -- ids & dates
        campaign_id as campaign_id,
        update_date as updated_date,

        -- campaign info
        name as campaign_name,

        -- metadata columns
        current_timestamp as loaded_at
    from deduplicated
)

select *
from renamed
