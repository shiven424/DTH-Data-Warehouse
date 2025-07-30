-- List of Un-Subscribed Customers with Reasons. 
SELECT
    u.unsubscription_date,
    cd.customer_id,
    cd.customer_name,
    cd.customer_email,
    p.plan_name,
    r.reason_category,
    r.reason_description
FROM Unsubscription_fact AS u
INNER JOIN Customer_dimension AS cd
    ON u.customer_id = cd.customer_id
INNER JOIN Reason_dimension AS r
    ON u.reason_id = r.reason_id
INNER JOIN Subscription_fact AS sf
    ON u.customer_id = sf.customer_id
   AND u.unsubscription_date BETWEEN sf.subscription_start_date AND sf.subscription_end_date
INNER JOIN Plan_dimension AS p
    ON sf.plan_id = p.plan_id
ORDER BY
    u.unsubscription_date DESC;





-- Count of Un‑Subscribed Customers by Reason Category
SELECT
    r.reason_category,
    COUNT(DISTINCT u.customer_id) AS num_unsubscribed_customers
FROM Unsubscription_fact AS u
JOIN Reason_dimension  AS r
  ON u.reason_id = r.reason_id
GROUP BY
    r.reason_category
ORDER BY
    num_unsubscribed_customers DESC;





-- List of Active Subscriptions with Plan Details
SELECT
    s.customer_id,
    cd.customer_name,
    p.plan_name,
    p.plan_price,
    p.channel_package,
    p.plan_duration,
    s.subscription_start_date,
    s.subscription_end_date
FROM Subscription_fact AS s
JOIN Plan_dimension     AS p
  ON s.plan_id = p.plan_id
JOIN Customer_dimension AS cd
  ON s.customer_id = cd.customer_id
WHERE s.subscription_status = 'Active'
ORDER BY s.subscription_start_date DESC;





-- Feedback Counts by Channel (Sentiment Proxy)
SELECT
    ch.channel_name,
    COUNT(f.feedback_id) AS feedback_count
FROM feedback_fact f
JOIN channel_dimension ch
    ON f.channel_id = ch.channel_id
GROUP BY
    ch.channel_name
ORDER BY
    feedback_count DESC;





-- Highest Rated Content with Engagement, Genre & Ad‑Exposure
SELECT 
    c.series_name,
    c.rating,
    gd.genre_name,
    ae.ad_type,
    COUNT(ce.engagement_id)            AS total_engagement_records,
    SUM(ce.view_count)                 AS total_views,
    ROUND(AVG(ce.engagement_score),2)  AS avg_engagement_score
FROM content_dimension AS c
JOIN content_genre_bridge AS cgb
  ON c.content_id = cgb.content_id
JOIN genre_dimension AS gd
  ON cgb.genre_id = gd.genre_id
JOIN customer_engagement_fact AS ce
  ON c.content_id = ce.content_id
JOIN ad_exposure_dimension AS ae
  ON ce.ad_exposure_id = ae.ad_exposure_id
GROUP BY 
    c.series_name,
    c.rating,
    gd.genre_name,
    ae.ad_type
HAVING c.rating IS NOT NULL
ORDER BY 
    c.rating DESC,
    avg_engagement_score DESC;





-- Average Subscription Duration by Plan Price, WITH & WITHOUT Promo for Comparison
SELECT
    p.plan_name,
    p.plan_price,
    pd.promo_name,
    ROUND(AVG(DATEDIFF(DAY, s.subscription_start_date, s.subscription_end_date)), 1) AS avg_sub_duration_with_promo,
    ROUND(o.avg_sub_duration_overall, 1) AS avg_sub_duration_overall
FROM plan_dimension      AS p
JOIN subscription_fact   AS s
  ON p.plan_id = s.plan_id
JOIN promotion_dimension AS pd
  ON s.promo_id = pd.promo_id
JOIN (
    SELECT
      plan_id,
      AVG(DATEDIFF(DAY, subscription_start_date, subscription_end_date)) AS avg_sub_duration_overall
    FROM subscription_fact
    WHERE subscription_end_date IS NOT NULL
    GROUP BY plan_id
) AS o
  ON p.plan_id = o.plan_id
WHERE s.subscription_end_date IS NOT NULL
GROUP BY
    p.plan_name,
    p.plan_price,
    pd.promo_name,
    o.avg_sub_duration_overall
ORDER BY
    p.plan_price ASC;





-- Monthly Engagement for Series by Customer Segment (City)
SELECT 
    ds.series_name,
    cd.customer_city,
    dm.month_record,
    SUM(sma.total_view_count) AS total_series_views,
    AVG(sma.avg_engagement_score) AS avg_series_engagement
FROM series_monthly_aggregate_fact sma
JOIN dim_series ds 
    ON sma.series_id = ds.series_id
JOIN customer_dimension cd
    ON sma.customer_id = cd.customer_id
JOIN dim_month dm
    ON sma.month_id = dm.month_id
GROUP BY 
    ds.series_name,
    cd.customer_city,
    dm.month_record
ORDER BY 
    ds.series_name,
    cd.customer_city,
    dm.month_record;





-- Top 5 Most‑Subscribed Plans
SELECT TOP 5
    p.plan_id,
    p.plan_name,
    COUNT(*) AS total_subscriptions
FROM Subscription_fact AS s
JOIN Plan_dimension    AS p
  ON s.plan_id = p.plan_id
GROUP BY
    p.plan_id,
    p.plan_name
ORDER BY
    total_subscriptions DESC;





-- Identify the busiest channel/month combinations by total viewing duration.
SELECT TOP 20
  ch.channel_name,
  dm.month_record,
  SUM(cef.viewing_duration) AS total_viewing_minutes
FROM customer_engagement_fact cef
JOIN Channel_dimension ch ON cef.channel_id = ch.channel_id
JOIN Time_dimension t     ON cef.time_id   = t.time_id
JOIN dim_month dm         ON dm.month_record = t.month_record
GROUP BY ch.channel_name, dm.month_record
ORDER BY total_viewing_minutes DESC;





-- Compute the month‑over‑month change in view count for each series.
SELECT TOP 100
  sma.series_id,
  ds.series_name,
  sma.month_id,
  dm.month_record,
  sma.total_view_count,
  sma.total_view_count 
    - LAG(sma.total_view_count) OVER (
        PARTITION BY sma.series_id 
        ORDER BY sma.month_id
      ) AS mom_growth
FROM series_monthly_aggregate_fact sma
JOIN dim_series ds ON sma.series_id = ds.series_id
JOIN dim_month dm ON sma.month_id = dm.month_id
ORDER BY mom_growth DESC;





-- Identify the customers who have watched the most minutes of content.s
SELECT TOP 10
  cef.customer_id,
  c.customer_name,
  SUM(cef.viewing_duration) AS total_viewing_minutes
FROM customer_engagement_fact cef
JOIN Customer_dimension c ON cef.customer_id = c.customer_id
GROUP BY cef.customer_id, c.customer_name
ORDER BY total_viewing_minutes DESC;





-- Monthly Subscription and Unsubscription Roll-Up:
 ;WITH subs AS (
    SELECT
      t.month_record,
      COUNT(*) AS cnt
    FROM Subscription_fact sf
    JOIN Time_dimension t
      ON sf.time_id = t.time_id
    GROUP BY t.month_record
),
unsubs AS (
    SELECT
      t.month_record,
      COUNT(*) AS cnt
    FROM Unsubscription_fact uf
    JOIN Time_dimension t
      ON uf.time_id = t.time_id
    GROUP BY t.month_record
)
SELECT
  dm.month_id,
  dm.month_record,
  COALESCE(subs.cnt, 0)   AS total_subscriptions,
  COALESCE(unsubs.cnt, 0) AS total_unsubscriptions,
  COALESCE(subs.cnt, 0) - COALESCE(unsubs.cnt, 0) AS net_change
FROM dim_month dm
LEFT JOIN subs   ON subs.month_record   = dm.month_record
LEFT JOIN unsubs ON unsubs.month_record = dm.month_record
ORDER BY dm.month_id;





-- Feedback Rollup Analysis by Customer City & Plan.
SELECT
  COALESCE(c.customer_city,      'All Cities') AS CustomerCity,
  COALESCE(p.plan_name,          'All Plans')  AS PlanName,
  COUNT(*)                          AS TotalFeedback,
  SUM(CASE WHEN f.feedback_comment LIKE '%good%'
              OR f.feedback_comment LIKE '%excellent%'
              OR f.feedback_comment LIKE '%great%'
           THEN 1 ELSE 0 END)       AS PositiveCount,
  SUM(CASE WHEN f.feedback_comment LIKE '%bad%'
              OR f.feedback_comment LIKE '%poor%'
              OR f.feedback_comment LIKE '%complaint%'
           THEN 1 ELSE 0 END)       AS NegativeCount,
  SUM(CASE WHEN f.feedback_comment NOT LIKE '%good%'
              AND f.feedback_comment NOT LIKE '%excellent%'
              AND f.feedback_comment NOT LIKE '%great%'
              AND f.feedback_comment NOT LIKE '%bad%'
              AND f.feedback_comment NOT LIKE '%poor%'
              AND f.feedback_comment NOT LIKE '%complaint%'
           THEN 1 ELSE 0 END)       AS NeutralCount
FROM feedback_fact AS f
INNER JOIN customer_dimension AS c
  ON f.customer_id = c.customer_id
INNER JOIN plan_dimension     AS p
  ON f.plan_id     = p.plan_id
GROUP BY ROLLUP (c.customer_city, p.plan_name)
ORDER BY
  GROUPING(c.customer_city) DESC,
  GROUPING(p.plan_name)    DESC,
  CustomerCity,
  PlanName;





-- Feedback Sentiment by Channel:
SELECT
  ch.channel_name,
  CASE
    WHEN f.feedback_comment LIKE '%good%' 
      OR f.feedback_comment LIKE '%excellent%' THEN 'Positive'
    WHEN f.feedback_comment LIKE '%poor%' 
      OR f.feedback_comment LIKE '%bad%' THEN 'Negative'
    ELSE 'Neutral'
  END AS sentiment,
  COUNT(*) AS feedback_count
FROM Feedback_fact f
JOIN Channel_dimension ch ON f.channel_id = ch.channel_id
GROUP BY 
  ch.channel_name,
  CASE
    WHEN f.feedback_comment LIKE '%good%' 
      OR f.feedback_comment LIKE '%excellent%' THEN 'Positive'
    WHEN f.feedback_comment LIKE '%poor%' 
      OR f.feedback_comment LIKE '%bad%' THEN 'Negative'
    ELSE 'Neutral'
  END
ORDER BY ch.channel_name, feedback_count DESC;





-- Average Time to Churn by Reason:
SELECT
  r.reason_category,
  r.reason_description,
  ROUND(AVG(DATEDIFF(day, s.subscription_start_date, u.unsubscription_date)), 1) AS avg_days_to_unsub
FROM Unsubscription_fact u
JOIN Subscription_fact s
  ON u.customer_id = s.customer_id
  AND u.unsubscription_date BETWEEN s.subscription_start_date AND s.subscription_end_date
JOIN Reason_dimension r
  ON u.reason_id = r.reason_id
GROUP BY
  r.reason_category,
  r.reason_description
ORDER BY
  avg_days_to_unsub DESC;





--Feedback–Engagement Anomaly Detection
WITH feedback_sentiment AS (
    SELECT
        f.customer_id,
        CASE 
            WHEN f.feedback_comment LIKE '%good%' 
			  OR f.feedback_comment LIKE '%excellent%'
              OR f.feedback_comment LIKE '%great%' THEN 1
            WHEN f.feedback_comment LIKE '%bad%' 
              OR f.feedback_comment LIKE '%poor%' THEN -1
            ELSE 0
        END AS sentiment_score
    FROM Feedback_fact f
),
customer_sentiment AS (
    SELECT 
        customer_id, 
        AVG(sentiment_score) AS avg_sentiment
    FROM feedback_sentiment
    GROUP BY customer_id
),
customer_engagement AS (
    SELECT 
        customer_id, 
        SUM(viewing_duration) AS total_viewing_minutes,
        AVG(engagement_score) AS avg_engagement
    FROM customer_engagement_fact
    GROUP BY customer_id
),
overall_engagement AS (
    SELECT AVG(engagement_score) AS platform_avg_engagement
    FROM customer_engagement_fact
)
SELECT 
    cd.customer_id,
    cd.customer_name,
    COALESCE(eng.total_viewing_minutes, 0) AS total_viewing_minutes,
    COALESCE(eng.avg_engagement,       0) AS avg_engagement,
    COALESCE(cs.avg_sentiment,         0) AS avg_sentiment,
    CASE 
        WHEN cs.avg_sentiment < 0 AND eng.avg_engagement > o.platform_avg_engagement 
             THEN 'High engagement but negative sentiment'
        WHEN cs.avg_sentiment >= 0 AND eng.avg_engagement < o.platform_avg_engagement 
             THEN 'Low engagement but positive sentiment'
        ELSE 'Aligned'
    END AS anomaly_flag
FROM Customer_dimension cd
LEFT JOIN customer_engagement eng 
    ON cd.customer_id = eng.customer_id
LEFT JOIN customer_sentiment cs 
    ON cd.customer_id = cs.customer_id
CROSS JOIN overall_engagement o
ORDER BY anomaly_flag;




--Customer Loyalty & Revenue Potential Score
WITH subscription_metrics AS (
    SELECT
        sf.customer_id,
        AVG(DATEDIFF(day, sf.subscription_start_date, 
             COALESCE(sf.subscription_end_date, GETDATE()))) AS avg_subscription_duration,
        COUNT(*) AS total_subscriptions,
        AVG(p.plan_price) AS avg_plan_price
    FROM Subscription_fact sf
    JOIN Plan_dimension p 
      ON sf.plan_id = p.plan_id
    GROUP BY sf.customer_id
),
engagement_metrics AS (
    SELECT
        customer_id,
        AVG(engagement_score) AS avg_engagement_score,
        SUM(viewing_duration) AS total_view_duration
    FROM customer_engagement_fact
    GROUP BY customer_id
),
max_plan_price AS (
    SELECT MAX(plan_price) AS max_price FROM Plan_dimension
)
SELECT
    cd.customer_id,
    cd.customer_name,
    sub.avg_subscription_duration,
    sub.total_subscriptions,
    sub.avg_plan_price,
    eng.avg_engagement_score,
    eng.total_view_duration,
    ROUND(
      0.4 * LOG(sub.avg_subscription_duration + 1)
      + 0.3 * eng.avg_engagement_score
      + 0.3 * (sub.avg_plan_price / maxp.max_price),
    2) AS loyalty_index,
    CASE 
       WHEN ROUND(
          0.4 * LOG(sub.avg_subscription_duration + 1)
          + 0.3 * eng.avg_engagement_score
          + 0.3 * (sub.avg_plan_price / maxp.max_price),
       2) >= 2.7 THEN 'High Loyalty'
       WHEN ROUND(
          0.4 * LOG(sub.avg_subscription_duration + 1)
          + 0.3 * eng.avg_engagement_score
          + 0.3 * (sub.avg_plan_price / maxp.max_price),
       2) >= 2.6 THEN 'Medium Loyalty'
       ELSE 'Low Loyalty'
    END AS loyalty_segment
FROM Customer_dimension cd
JOIN subscription_metrics sub 
    ON cd.customer_id = sub.customer_id
JOIN engagement_metrics eng 
    ON cd.customer_id = eng.customer_id
CROSS JOIN max_plan_price maxp
ORDER BY loyalty_index DESC;





--Churn‑Risk Composite Score
;WITH tenure AS (
    SELECT
        sf.customer_id,
        AVG(DATEDIFF(
            day,
            sf.subscription_start_date,
            COALESCE(sf.subscription_end_date, GETDATE())
        )) AS avg_tenure_days
    FROM Subscription_fact sf
    GROUP BY sf.customer_id
),
unsubs AS (
    SELECT
        customer_id,
        COUNT(*) AS total_unsubs
    FROM unsubscription_fact
    GROUP BY customer_id
),
neg_reason_unsubs AS (
    SELECT
        u.customer_id,
        COUNT(*) AS neg_unsubs_count
    FROM unsubscription_fact u
    JOIN Reason_dimension r
      ON u.reason_id = r.reason_id
    WHERE r.reason_category IN (
      'Price','Service','Billing Issues','Technical Issues',
      'Signal Quality','Hidden Charges','Unreliable Service',
      'Contract Disputes','Installation Problems','Poor Picture Quality',
      'Network Issues','Maintenance Downtime','Disruptive Ads',
      'Quality of Channels'
    )
    GROUP BY u.customer_id
),
neg_feedback AS (
    SELECT
        f.customer_id,
        COUNT(*) AS neg_feedback_count
    FROM Feedback_fact f
    WHERE f.feedback_comment LIKE '%bad%'
       OR f.feedback_comment LIKE '%poor%'
       OR f.feedback_comment LIKE '%complaint%'
    GROUP BY f.customer_id
),
max_vals AS (
    SELECT
        MAX(avg_tenure_days)    AS max_tenure,
        MAX(total_unsubs)       AS max_unsubs,
        MAX(neg_unsubs_count)   AS max_neg_unsubs,
        MAX(neg_feedback_count) AS max_neg_fb
    FROM tenure t
    FULL JOIN unsubs u            ON 1=1
    FULL JOIN neg_reason_unsubs nr ON 1=1
    FULL JOIN neg_feedback nf     ON 1=1
),
base_scores AS (
    SELECT
        cd.customer_id,
        cd.customer_name,
        t.avg_tenure_days,
        u.total_unsubs,
        ISNULL(nr.neg_unsubs_count,0)   AS neg_unsubs_count,
        ISNULL(nf.neg_feedback_count,0) AS neg_feedback_count,
        ROUND(
          0.35 * (1 - t.avg_tenure_days   / NULLIF(m.max_tenure,0))
        + 0.25 * (u.total_unsubs         / NULLIF(m.max_unsubs,0))
        + 0.20 * (nr.neg_unsubs_count    / NULLIF(m.max_neg_unsubs,0))
        + 0.20 * (nf.neg_feedback_count  / NULLIF(m.max_neg_fb,0)),
        3) AS churn_risk_score
    FROM tenure t
    LEFT JOIN unsubs u               ON t.customer_id = u.customer_id
    LEFT JOIN neg_reason_unsubs nr   ON t.customer_id = nr.customer_id
    LEFT JOIN neg_feedback nf        ON t.customer_id = nf.customer_id
    CROSS JOIN max_vals m
    JOIN Customer_dimension cd   ON t.customer_id = cd.customer_id
)
SELECT
    customer_id,
    customer_name,
    avg_tenure_days,
    total_unsubs,
    neg_unsubs_count,
    neg_feedback_count,
    churn_risk_score,
    CASE
      WHEN churn_risk_score >= 0.6 THEN 'High Risk'
      WHEN churn_risk_score >= 0.3 THEN 'Medium Risk'
      ELSE 'Low Risk'
    END AS risk_segment
FROM base_scores
ORDER BY churn_risk_score DESC;






-- Ad‑Effectiveness vs. Engagement Lift
WITH ad_engagement AS (
  SELECT
    cef.customer_id,
    ae.ad_type,
    SUM(cef.view_count)       AS tot_views,
    AVG(cef.engagement_score) AS avg_score
  FROM customer_engagement_fact AS cef
  JOIN ad_exposure_dimension AS ae
    ON cef.ad_exposure_id = ae.ad_exposure_id
  GROUP BY cef.customer_id, ae.ad_type
),
no_ad_engagement AS (
  SELECT
    cef.customer_id,
    SUM(cef.view_count)       AS base_views,
    AVG(cef.engagement_score) AS base_score
  FROM customer_engagement_fact AS cef
  LEFT JOIN ad_exposure_dimension AS ae
    ON cef.ad_exposure_id = ae.ad_exposure_id
  WHERE ae.ad_exposure_id IS NULL
  GROUP BY cef.customer_id
)
SELECT
  ae.ad_type,
  ROUND(AVG(ae.avg_score - ISNULL(na.base_score,0)), 2)     AS avg_engagement_lift,
  ROUND(AVG(ae.tot_views  - ISNULL(na.base_views, 0)), 0)    AS avg_view_delta,
  COUNT(DISTINCT ae.customer_id)                            AS customers_exposed
FROM ad_engagement AS ae
LEFT JOIN no_ad_engagement AS na
  ON ae.customer_id = na.customer_id
GROUP BY ae.ad_type
ORDER BY avg_engagement_lift DESC;






-- Promo × Event 3‑Month Retention
;WITH promo_cohort AS (
  SELECT
    s.customer_id,
    pd.promo_type,
    ed.season_name,
    MIN(s.time_id)            AS cohort_time
  FROM subscription_fact AS s
  JOIN promotion_dimension AS pd
    ON s.promo_id = pd.promo_id
  JOIN event_dimension AS ed
    ON s.event_id = ed.event_id
  WHERE s.subscription_status = 'Active'
  GROUP BY s.customer_id, pd.promo_type, ed.season_name
),
retention AS (
  SELECT
    pc.promo_type,
    pc.season_name,
    pc.cohort_time,
    s2.time_id,
    COUNT(DISTINCT s2.customer_id) AS retained_count
  FROM promo_cohort AS pc
  JOIN subscription_fact AS s2
    ON pc.customer_id = s2.customer_id
   AND s2.time_id 
       BETWEEN pc.cohort_time 
           AND DATEADD(MONTH, 3, pc.cohort_time)
  GROUP BY pc.promo_type, pc.season_name, pc.cohort_time, s2.time_id
)
SELECT
  r.promo_type,
  r.season_name,
  dm_cohort.month_record   AS cohort_month,
  dm_act.month_record      AS activity_month,
  r.retained_count,
  ROUND(
    r.retained_count * 100.0
    / NULLIF(
        SUM(r.retained_count)
          OVER (
            PARTITION BY 
              r.promo_type,
              r.season_name,
              dm_cohort.month_id
          ), 0
      )
  , 1) AS pct_retained
FROM retention AS r
  JOIN dim_month       AS dm_cohort
    ON r.cohort_time = dm_cohort.month_id
  JOIN Time_dimension  AS td2
    ON r.time_id = td2.time_id
  JOIN dim_month       AS dm_act
    ON td2.month_record = dm_act.month_record
ORDER BY 
  r.promo_type,
  r.season_name,
  dm_cohort.month_id,
  dm_act.month_id;