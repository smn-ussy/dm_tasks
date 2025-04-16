WITH
  BaseData AS (
    SELECT
      concat_ws('-', year, month) ym,
      ads.child_ssp_id,
      s.name ssp,
      ads.advertiser_id,
      advertiser_name,
      case when user_agent_os_family in('iOS','Android') then 'SP' else 'PC' end os,
      case when is_app is null then 0 else is_app end is_app,
      case when creative_type in(5,6) then 'native' when creative_type in(10) then 'video' else 'display' end creative,
      imp
    from dm.domain_ads ads
    inner join dm.hierarchies hie on ads.target_id = hie.target_id
    inner join agency_console.campaign cp on ads.strategy_id = cp.real_strategy_id
    inner join agency_console.campaign_agency_margin cam on cp.campaign_id = cam.campaign_id and concat_ws('-', year, month, day) between cam.start_date and cam.end_date
    inner join agency_console.campaign_smn_margin csm on cp.campaign_id = csm.campaign_id and concat_ws('-', year, month, day) between csm.start_date and csm.end_date
    left join console.ssp s on ads.child_ssp_id=s.id
    where concat_ws('-', year, month, day) between '{start_at}' and '{end_at}'
    and ads.advertiser_id not in({exclude_ads_id})
    and child_ssp_id>0
  ),
  SummedImp AS (
    SELECT
      ym,
      child_ssp_id,
      ssp,
      advertiser_id,
      advertiser_name,
      SUM(CASE WHEN os = 'PC' AND is_app = 0 AND creative = 'display' THEN imp ELSE 0 END) AS sum_imp
    FROM
      BaseData
    GROUP BY
      ym,
      child_ssp_id,
      ssp,
      advertiser_id,
      advertiser_name
  ),
  FilteredSummedImp AS (
    SELECT
      si.advertiser_id,
      si.ssp,
      si.sum_imp,
      COUNT(*) OVER (PARTITION BY si.ssp) AS ssp_record_count
    FROM
      SummedImp si
  ),
  SignificantSSP AS (
    SELECT DISTINCT
      ssp
    FROM
      FilteredSummedImp
    WHERE
      ssp_record_count > 5
  ),
  AdvertiserThresholdSSPCounts AS (
    SELECT
      si.advertiser_id,
      COUNT(DISTINCT CASE WHEN si.sum_imp >= 10000 THEN si.ssp END) AS high_threshold_ssp_count,
      COUNT(DISTINCT CASE WHEN si.sum_imp >= 5000 THEN si.ssp END) AS medium_threshold_ssp_count,
      COUNT(DISTINCT CASE WHEN si.sum_imp >= 1000 THEN si.ssp END) AS low_threshold_ssp_count,
      COUNT(DISTINCT s.ssp) AS total_significant_ssp_count,
      COUNT(DISTINCT CASE WHEN si.sum_imp >= 10000 THEN si.ssp END) AS distinct_ssp_above_10000,
      COUNT(DISTINCT CASE WHEN si.sum_imp >= 5000 THEN si.ssp END) AS distinct_ssp_above_5000,
      COUNT(DISTINCT CASE WHEN si.sum_imp >= 1000 THEN si.ssp END) AS distinct_ssp_above_1000
    FROM
      SummedImp si
      INNER JOIN SignificantSSP s ON si.ssp = s.ssp
    GROUP BY
      si.advertiser_id
  ),
  FinalAdvertisers AS (
    SELECT
      astc.advertiser_id
    FROM
      AdvertiserThresholdSSPCounts astc
    WHERE
      (astc.total_significant_ssp_count > 0 AND
       (
         (astc.high_threshold_ssp_count >= 0.8 * astc.total_significant_ssp_count AND astc.distinct_ssp_above_10000 < 20) OR
         (astc.medium_threshold_ssp_count >= 0.8 * astc.total_significant_ssp_count AND astc.distinct_ssp_above_5000 < 20 AND astc.distinct_ssp_above_10000 >= 20) OR
         (astc.low_threshold_ssp_count >= 0.8 * astc.total_significant_ssp_count AND astc.distinct_ssp_above_1000 < 20 AND astc.distinct_ssp_above_5000 >= 20)
       )
      )
  )
SELECT DISTINCT
  -- si.child_ssp_id,
  -- si.ssp,
  -- si.advertiser_name,
  -- si.sum_imp,
  si.advertiser_id
FROM
  SummedImp si
WHERE
  si.advertiser_id IN (SELECT advertiser_id FROM FinalAdvertisers);