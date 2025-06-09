# 対象
os = 'PC'
is_app = '0'
creative = 'display'

query = (
f"""
select
    tmp.advertiser_id,
    tmp.advertiser_name,
    tmp.child_ssp_id,
    tmp.ssp,
    SUM(imp)
from
    {created_table_name} tmp
WHERE
    tmp.os IN ('{os}')
    AND tmp.is_app IN ({is_app})
    AND tmp.creative IN ('{creative}')
GROUP BY
    1,2,3,4
ORDER BY
    1,2,3,4
;
"""
)
with ImpalaResource(**ircfg) as ir:
    df = ir.sql_to_pandas(query)
    
df