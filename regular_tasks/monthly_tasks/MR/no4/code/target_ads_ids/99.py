# 中間テーブルのドロップ
query = (
f"""
drop table {created_table_name}
"""
)
with ImpalaResource(**ircfg) as ir:
    table = ir.sql_to_pandas(query)

table