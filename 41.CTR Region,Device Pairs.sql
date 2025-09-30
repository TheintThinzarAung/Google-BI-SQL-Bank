-- 41. CTR by device within each region; return combinations below 1%.
WITH engagement AS (
  SELECT
    i.region,
    i.device,
    COUNT(c.click_id) AS clicks,
    COUNT(DISTINCT i.imp_id) AS impressions   
  FROM ad_impressions i
  LEFT JOIN ad_clicks c
    ON c.imp_id = i.imp_id
  GROUP BY i.region, i.device
)
SELECT
  region,
  device,
  ROUND((clicks * 1.0) / NULLIF(impressions,0) * 100, 2) AS ctr_pct
FROM engagement
WHERE (clicks * 1.0) / NULLIF(impressions,0) < 0.01
ORDER BY region, device;

