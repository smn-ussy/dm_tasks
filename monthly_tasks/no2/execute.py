# 主要ライブラリのimport
import pandas as pd
import numpy as np

# ファイル出力時にパスを指定する際によく使う
import os
import pathlib
from ailab_tools.smn import ImpalaResource
from ailab_tools.utils import GMail, GSheet

# 今回使用するSQLの取得
class GetSomeSalesReqresPerSsp:
    def __init__(self, ircfg, filename):
        self.name = name
        # Impala接続情報 hc5
        self.ircfg = {
            "hosts": ['172.16.60.117'],
            "port": 21050,
            "user": 'vmspool',
            "request_pool": 'adhoc_dm01_pool',
            "httpfs_host": '172.16.60.42',
            "httpfs_port": 14000
        }
        start_at = "2025/03/01"
        end_at = "2025/03/31"

    def get_sql(self, filename):
        with open(os.path.join("./sql", self.filename), "r") as f:
            return f.read().format(start_at=self.start_at, end_at=self.end_at)

    def execute_sql1(self):
        filename = "sql1.sql"
        query = self.get_sql(filename)
        with ImpalaResource(**self.ircfg) as ir:
            data_ssp_d = ir.sql_to_pandas(query)
        return data_ssp_d

    def execute_sql2(self):
        filename = "sql2.sql"
        query = self.get_sql(filename)
        with ImpalaResource(**self.ircfg) as ir:
            data_ssp_d_s = ir.sql_to_pandas(query)
        return data_ssp_d_s

def output(data_ssp_d, data_ssp_d_s):
    # 出力形式を整える
    data_ssp = pd.concat([data_ssp_d,data_ssp_d_s])
    data_ssp = data_ssp.sort_values(["kbn","sum_date","parent_ssp_id","child_ssp_id","nativeflg","videoflg"], ascending=True)

    # path定義
    parent_path = pathlib.Path("__data__").resolve().parent
    file_path = parent_path / "data"/ f"monthly_ssp_{start_at}.csv"

    # 出力
    data_ssp.to_csv(f"{file_path}", index=False, sep=",")

# 実行関数が非同期処理かどうか
def execute():
    gssrp = GetSomeSalesReqresPerSsp
    data_ssp_d = gssrp.execute_sql1()
    data_ssp_d_s = gssrp.execute_sql2()
    output(data_ssp_d, data_ssp_d_s)
    
execute()