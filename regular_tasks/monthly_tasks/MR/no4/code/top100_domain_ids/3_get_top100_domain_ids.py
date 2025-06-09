# ソートされたデータフレームから'domain_id'列をリストとして抽出する
domain_ids_by_sorted_original_win = data_b_0_1_sorted['domain_id'].tolist()

# 取得したドメインidリストをカンマ区切りの文字列に変換
top100_domain_id = ",".join(map(str, domain_ids_by_sorted_original_win))

# 確認用
top100_domain_id