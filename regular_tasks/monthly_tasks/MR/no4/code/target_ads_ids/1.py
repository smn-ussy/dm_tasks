created_table_name = "dm_tmp.monthly_scheduled_batch_3"

# 中間テーブル作成
query = (
f"""
create table {created_table_name} as 
select 
    ads.child_ssp_id,
    s.name ssp,
    ads.advertiser_id,
    advertiser_name,
    case
        when user_agent_os_family in('iOS','Android') then 'SP'
        else 'PC'
    end os,
    case
        when is_app is null then 0
        else is_app
    end is_app,
    case
        when creative_type in(5,6) then 'native'
        when creative_type in(10) then 'video'
        else 'display'
    end creative,
    sum(imp) imp
from dm.domain_ads ads
    inner join dm.hierarchies hie on ads.target_id = hie.target_id
    inner join agency_console.campaign cp on ads.strategy_id = cp.real_strategy_id
    inner join agency_console.campaign_agency_margin cam on cp.campaign_id = cam.campaign_id and concat_ws('-', year, month, day) between cam.start_date and cam.end_date
    inner join agency_console.campaign_smn_margin csm on cp.campaign_id = csm.campaign_id and concat_ws('-', year, month, day) between csm.start_date and csm.end_date
    left join console.ssp s on ads.child_ssp_id=s.id
where
    concat_ws('-', year, month, day) between '{start_at}' and '{end_at}'
    and ads.advertiser_id not in({exclude_ads_id})
    and child_ssp_id>0
group by 1,2,3,4,5,6,7
"""
)
with ImpalaResource(**ircfg) as ir:
    df = ir.sql_to_pandas(query)
    
df