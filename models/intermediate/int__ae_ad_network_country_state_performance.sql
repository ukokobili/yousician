-- combine state & country ad network into one report
with
detailed_report as (
    select * from {{ ref('stg__ae_ad_network_detailed_report') }}
),

country_report as (select * from {{ ref('stg__ae_ad_network_country_report') }}
),

geo_dictionary as (select * from {{ ref('stg__ae_ad_network_geo_dictionary') }}
),

campaigns as (select * from {{ ref('stg__ae_ad_network_campaign_updates') }}),

-- join geo dictionary to get location type
state_ads as (

    select
        -- dates & ids
        detailed_report.date,
        detailed_report.campaign_id,

        -- campaign info
        campaigns.campaign_name,

        -- geo info
        geo_dictionary.country_code,
        geo_dictionary.location_name as state_name,

        -- metrics
        detailed_report.spend,
        detailed_report.impressions,
        detailed_report.clicks
    from detailed_report
    left join campaigns on detailed_report.campaign_id = campaigns.campaign_id
    left join
        geo_dictionary on detailed_report.state_id = geo_dictionary.location_id
    where geo_dictionary.location_type = 'State'

),

-- get country level ads where there are no state 
-- level ads for that campaign & date
country_ads as (

    select
        -- dates & ids
        country_report.date,
        country_report.campaign_id,

        -- campaign info
        campaigns.campaign_name,

        -- geo info
        geo_dictionary.country_code,
        null as state_name,

        -- metrics
        country_report.spend,
        country_report.impressions,
        country_report.clicks
    from country_report
    left join campaigns on country_report.campaign_id = campaigns.campaign_id
    left join
        geo_dictionary on country_report.country_id = geo_dictionary.location_id
    where geo_dictionary.location_type = 'Country'

),  -- Added missing comma

-- union state & country level ads
country_state_union as (

    select *
    from state_ads

    union all

    select *
    from country_ads
    where
        not exists (  -- only include country ads if no state ads exist 
            select 1
            from state_ads
            where
                country_ads.date = state_ads.date
                and country_ads.campaign_id = state_ads.campaign_id
        )
)

select *
from country_state_union
