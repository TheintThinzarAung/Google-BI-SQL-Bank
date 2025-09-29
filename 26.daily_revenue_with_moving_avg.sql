-- 26. Daily revenue and 7-day moving average per publisher.
WITH daily_revenue AS (
  SELECT
    publisher_id,
    date,    
    SUM(revenue_usd) AS revenue
  FROM revenue_daily
  GROUP BY publisher_id, date
),
avg_revenue AS (
  SELECT
    publisher_id,
    date,
    revenue AS daily_revenue,
    ROUND(
      AVG(revenue) OVER (
        PARTITION BY publisher_id
        ORDER BY date
        ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
      )
    , 2) AS avg_revenue,
    COUNT(*) OVER (
      PARTITION BY publisher_id
      ORDER BY date
      ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
    ) AS win_rows
  FROM daily_revenue
)
SELECT
  publisher_id,
  date,
  daily_revenue,
  avg_revenue
FROM avg_revenue
WHERE win_rows = 7
ORDER BY publisher_id, date;
