# CMAテストにnet_salesが入らないケースがあり、original_winのTop100に変更（2024/03分から）

query = (
f"""
select 
    concat_ws('-', year, month) ym,
    domain_id,
    domain,
    sum(imp) imp,
    sum(click)click,
    sum(ctv1) ctv1,
    sum(ctv2) ctv2,
    sum(original_win_price)/1000000 original_win,
    sum(net_spend)/1000000 net_sales,
    sum(gross_spend)/1000000 gross_sales
from dm.domain_ads ads
    inner join dm.hierarchies hie on ads.target_id = hie.target_id
    inner join agency_console.campaign cp on ads.strategy_id = cp.real_strategy_id
    inner join agency_console.campaign_agency_margin cam on cp.campaign_id = cam.campaign_id and concat_ws('-', year, month, day) between cam.start_date and cam.end_date
    inner join agency_console.campaign_smn_margin csm on cp.campaign_id = csm.campaign_id and concat_ws('-', year, month, day) between csm.start_date and csm.end_date
    left join console.ssp s on ads.child_ssp_id=s.id
where
    concat_ws('-', year, month, day) between '{start_at}' and '{end_at}'
    and child_ssp_id>0 and domain_id>0
group by 1,2,3
order by original_win desc
limit 100
"""
)
with ImpalaResource(**ircfg) as ir:
    data_b_0_1 = ir.sql_to_pandas(query)