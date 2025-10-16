with ad_network_1 as (
    select *
    from {{ ref('int__ae_ad_network_country_state_performance') }}
),

ad_network_2 as (
    select *
    from {{ ref('stg__ae_ad_network_report_2') }}
),

ad_network_geo_performance as (

    select
        -- dates & ids
        date,
        campaign_id,

        -- campaign info
        campaign_name,
        'Ad Network 1' as source,

        -- geo info
        country_code,
        state_name,
        location_type,

        -- metrics
        spend,
        impressions,
        clicks,

        -- extended metrics
        {{ safe_divide('clicks', 'impressions') }} as ctr,
        {{ safe_divide('spend', 'clicks') }} as cpc,
        {{ safe_divide('spend', 'impressions') }} * 1000 as cpm,

        -- metadata columns
        current_timestamp as loaded_at

    from ad_network_1

    union all

    select
        -- dates & ids
        date,
        campaign_id,

        -- campaign info
        campaign_name,
        'Ad Network 2' as source,

        -- geo info
        country_code,
        state_name,
        location_type,

        -- metrics
        spend,
        impressions,
        clicks,

        -- extended metrics
        {{ safe_divide('clicks', 'impressions') }} as ctr,
        {{ safe_divide('spend', 'clicks') }} as cpc,
        {{ safe_divide('spend', 'impressions') }} * 1000 as cpm,

        -- metadata columns
        current_timestamp as loaded_at
    from ad_network_2
)

select *
from ad_network_geo_performance
