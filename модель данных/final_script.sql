-- Загружаем Facebook Ads
CREATE TABLE fb_ads AS
SELECT *
FROM read_csv('fb_ads.csv', header=true);

-- Загружаем Google Ads
CREATE TABLE google_ads AS
SELECT *
FROM read_csv('google_ads.csv', header=true);

-- Загружаем MMP данные
CREATE TABLE mmp_data AS
SELECT *
FROM read_csv('mmp_data.csv', header=true);

-- Объединяем FB и Google в единый канал ads_data

CREATE TABLE ads_data AS
SELECT * FROM fb_ads
UNION ALL
SELECT * FROM google_ads;

-- Джоин рекламных данных + MMP

CREATE TABLE joined AS
SELECT
    a.date,
    a.campaign_id,
    a.campaign_name,
    a.source,
    a.impressions,
    a.clicks,
    a.spend,
    a.ad_installs,
    m.mmp_installs,
    m.d1_revenue,
    m.d7_revenue
FROM ads_data a
LEFT JOIN mmp_data m
    ON a.date = m.date
    AND a.campaign_id = m.campaign_id;

-- Финальная таблица с метриками

CREATE TABLE final_metrics AS
SELECT
    date,
    campaign_id,
    campaign_name,
    source,
    impressions,
    clicks,
    spend,
    ad_installs,
    mmp_installs,

    -- Метрики
    CASE WHEN impressions > 0 THEN clicks * 1.0 / impressions ELSE 0 END AS ctr,
    CASE WHEN ad_installs > 0 THEN spend / ad_installs ELSE 0 END AS cpi,
    CASE WHEN spend > 0 THEN d1_revenue / spend ELSE 0 END AS roas_d1,
    CASE WHEN spend > 0 THEN d7_revenue / spend ELSE 0 END AS roas_d7,

    d1_revenue,
    d7_revenue
FROM joined;

