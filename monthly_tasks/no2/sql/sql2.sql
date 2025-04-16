with imp as(
    select
        concat_ws('/', year, month, day) sum_date,
        ssp_id parent_ssp_id, 
        ads.child_ssp_id,
        case when creative_type in(5,6) then 1 else 0 end nativeflg,
        case when creative_type in(10) then 1 else 0 end videoflg,
        sum(case when oem_id in(100,200) then net_spend else 0 end)/1000000 sales, 
        sum(case when oem_id in(100,200) then imp else 0 end) imp, 
        sum(case when ad_type in(0,4) and oem_id in(100,200) then imp else 0 end) rta_imp,
        sum((case when (ad_type in(0,4) and oem_id in(100,200)) then net_spend else 0 end))/1000000 rta_sales,
        sum(case when oem_id in(100,200) then ctv1 else 0 end) ctv1,
        sum(case when oem_id in(100,200) then ctv2 else 0 end) ctv2, 
        sum(case when ad_type in(0,4) and oem_id in(100,200) then ctv1 else 0 end) rta_ctv1,  
        sum(case when ad_type in(0,4) and oem_id in(100,200) then ctv2 else 0 end) rta_ctv2, 
        sum(case when oem_id in(300)then imp else 0 end) cpx_imp,
        sum((case when oem_id in(300) then net_spend else 0 end))/1000000 cpx_sales,
        sum(case when oem_id in(300)then ctv1 else 0 end) cpx_ctv1,
        sum(case when oem_id in(300)then ctv2 else 0 end) cpx_ctv2
    from dm.domain_ads ads 
    inner join dm.hierarchies hie using(target_id) 
    inner join agency_console.campaign cp on ads.strategy_id = cp.real_strategy_id 
    inner join agency_console.campaign_agency_margin cam on cp.campaign_id = cam.campaign_id and concat_ws('-', year, month, day) between cam.start_date and cam.end_date
    inner join agency_console.campaign_smn_margin csm on cp.campaign_id = csm.campaign_id and concat_ws('-', year, month, day) between csm.start_date and csm.end_date 
    where concat_ws('/', year, month ,day) between '{start_at}' and '{end_at}' 
    group by 1,2,3,4,5
    having sum(imp) > 0
),
res as(
    select 
        concat_ws('/', year, month, day) sum_date,
        ssp_id parent_ssp_id, 
        child_ssp_id,
        cast(native_request as int) nativeflg, 
        cast(video_request as int) videoflg,
        sum(case when res.tactics_id > 0 and oem_id in(100,200) then res else 0 end) res, 
        sum(case when ad_type = 0 and res.tactics_id > 0 and oem_id in(100,200) then res else 0 end) rta_res, 
        sum(case when res.tactics_id > 0 and oem_id=300 then res else 0 end) cpx_res 
    from dm.domain_res res 
    left join dm.hierarchies b using (target_id) 
    where concat_ws('/', res.year, res.month ,res.day) between '{start_at}' and '{end_at}' 
        and res.ssp_id > 0 
        and res.tactics_id > 0 
    group by 1,2,3,4,5
)
select
    '全体' kbn,
    concat_ws('/', year, month, day) sum_date,
    ssp_id parent_ssp_id, 
    ads.child_ssp_id,
    ads.child_ssp_id display_child_ssp_id,
    cast(native_request as int) nativeflg, 
    cast(video_request as int) videoflg,
    sum(logicad_request_id_1_sum_native_plcmtcnt) req,  
    sales, 
    res,
    imp, 
    rta_res,
    rta_imp,
    rta_sales,
    ctv1,
    ctv2, 
    rta_ctv1,  
    rta_ctv2, 
    cpx_res,
    cpx_imp,
    cpx_sales,
    cpx_ctv1,
    cpx_ctv2
from dm.domain_req ads 
left join res on 
    concat_ws('/', ads.year, ads.month, ads.day)=res.sum_date
    and ads.ssp_id=res.parent_ssp_id
    and ads.child_ssp_id=res.child_ssp_id
    and cast(native_request as int)=res.nativeflg
    and cast(video_request as int)=res.videoflg
left join imp on 
    concat_ws('/', ads.year, ads.month, ads.day)=imp.sum_date
    and ads.ssp_id=imp.parent_ssp_id
    and ads.child_ssp_id=imp.child_ssp_id
    and cast(native_request as int)=imp.nativeflg
    and cast(video_request as int)=imp.videoflg
where concat_ws('/', year, month ,day) between '{start_at}' and '{end_at}' 
    and ads.ssp_id>0
group by 1,2,3,4,5,6,7,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23