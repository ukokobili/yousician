select
  *
from {{ ref('fct__ae_ad_network_geo_performance') }}
where ctr != {{ safe_divide('clicks', 'impressions') }}