WITH
  BaseData AS (
    SELECT
      concat_ws('-', year, month) ym,
      ads.child_ssp_id,
      s.name ssp,
      ads.advertiser_id,
      advertiser_name,
      CASE WHEN user_agent_os_family IN ('iOS','Android') THEN 'SP' ELSE 'PC' END os,
      CASE WHEN is_app IS NULL THEN 0 ELSE is_app END is_app,
      CASE WHEN creative_type IN (5,6) THEN 'native' WHEN creative_type IN (10) THEN 'video' ELSE 'display' END creative,
      imp
    FROM dm.domain_ads ads
    INNER JOIN dm.hierarchies hie ON ads.target_id = hie.target_id
    INNER JOIN agency_console.campaign cp ON ads.strategy_id = cp.real_strategy_id
    INNER JOIN agency_console.campaign_agency_margin cam ON cp.campaign_id = cam.campaign_id AND concat_ws('-', year, month, day) between cam.start_date AND cam.end_date
    INNER JOIN agency_console.campaign_smn_margin csm ON cp.campaign_id = csm.campaign_id AND concat_ws('-', year, month, day) between csm.start_date AND csm.end_date
    LEFT JOIN console.ssp s ON ads.child_ssp_id=s.id
    where concat_ws('-', year, month, day) between '{start_at}' AND '{end_at}'
    AND ads.advertiser_id not IN ({exclude_ads_id})
    AND child_ssp_id>0
  ),
  SummedImp AS (
    SELECT
      ym,
      child_ssp_id,
      ssp,
      advertiser_id,
      advertiser_name,
      SUM(imp) AS sum_imp
    FROM
      BaseData
    WHERE
      os = 'PC' AND is_app = 0 AND creative = 'display'
    GROUP BY
      ym,
      child_ssp_id,
      ssp,
      advertiser_id,
      advertiser_name
  )
SELECT
  ym,
  child_ssp_id,
  ssp,
  advertiser_id,
  advertiser_name,
  sum_imp
FROM
  SummedImp;