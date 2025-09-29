-- 36. Publisher-level CTR trend last 8 weeks; flag publishers with ≥ 20% CTR drop.
with cur_ctr as (
  select
    i.publisher_id,
    count(c.click_id) as clicks,
    count(i.imp_id) as imps,
    round(count(c.click_id) / count(i.imp_id) * 100, 2) as cur_ctr
  from ad_impressions i
  left join ad_clicks c on i.imp_id = c.imp_id
  where i.served_at >= curdate() - interval 8 week
    and i.served_at < curdate()
  group by i.publisher_id
),
prev_ctr as (
  select
    i.publisher_id,
    count(c.click_id) as clicks,
    count(i.imp_id) as imps,
    round(count(c.click_id) / count(i.imp_id) * 100, 2) as prev_ctr
  from ad_impressions i
  left join ad_clicks c on i.imp_id = c.imp_id
  where i.served_at >= curdate() - interval 16 week
    and i.served_at < curdate() - interval 8 week
  group by i.publisher_id
)
select
  c.publisher_id,
  c.cur_ctr,
  p.prev_ctr,
  round((c.cur_ctr - p.prev_ctr) / nullif(p.prev_ctr,0) * 100, 2) as pct_change,
  case when (c.cur_ctr - p.prev_ctr) / nullif(p.prev_ctr,0) <= -0.20
       then '⚠️ Drop ≥ 20%' else 'OK' end as flag
from cur_ctr c
left join prev_ctr p
  on c.publisher_id = p.publisher_id
order by pct_change;


