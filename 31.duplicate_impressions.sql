-- 31. Count duplicate impressions (same req_id & served_at within 1s). Return dup rates per publisher.
with base as (
  select
    publisher_id,
    req_id,
    served_at,
    count(*) as cnt
  from ad_impressions
  group by publisher_id, req_id, served_at
),
dup as (
  select
    publisher_id,
    req_id,
    served_at,
    cnt,
    case when cnt > 1 then cnt - 1 else 0 end as dup_imps
  from base
),
agg as (
  select
    publisher_id,
    sum(dup_imps) as dup_imps,
    sum(cnt) as total_imps
  from dup
  group by publisher_id
)
select
  publisher_id,
  dup_imps,
  total_imps,
  round(dup_imps / nullif(total_imps,0), 4) as dup_rate
from agg
order by dup_rate desc;

    
    
