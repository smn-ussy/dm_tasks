# 閾値は下記の通り
thresholds = [10000, 5000, 3000, 1000]

# 変数の初期値
result = []
total_unique_ssp = 0
target_advertiser_id_list = []
advertiser_dict = {}
is_break = False

for threshold in thresholds:
    # impの合計値が一つでも閾値を超えていたら対象とする
    filtered_threshold_df = df[df['sum(imp)'] > threshold]

    # 1. 対象のSSPのユニーク数
    total_unique_ssp = filtered_threshold_df['ssp'].nunique()

    # 2. 広告主ID、SSPのユニーク数、child_ssp_idでグルーピング
    grouped_df = filtered_threshold_df.groupby('advertiser_id').agg(
        num_unique_ssp=('ssp', 'nunique'),
        child_ssp_ids=('child_ssp_id', lambda x: ','.join(map(str, x)))
    ).reset_index()

    # 3. imp数が設定した閾値の80%を超えている広告主IDを取得
    result_df = grouped_df[grouped_df['num_unique_ssp'] >= int(0.8 * total_unique_ssp)]

    # 広告主IDリストを閾値毎に管理
    result = result_df.to_dict(orient='records')
    target_advertiser_id_list = [row['advertiser_id'] for row in result]
    advertiser_dict[threshold] = target_advertiser_id_list
    
    # 閾値と広告主IDの個数
    print(f"upper {threshold}: {len(target_advertiser_id_list)} advertiser_id_num")
    print(f"threshold: upper {int(0.8 * total_unique_ssp)}\n")

    # 条件を満たしていたら抜ける
    if len(target_advertiser_id_list) >= 20 and target_advertiser_id_list:
        is_break = True
        break


filter_name = ""
if not target_advertiser_id_list:
    print("No pc_native_advertiser_id.")
else:
    # 閾値を超えるものが見つからなかった場合、広告主IDが最も多いリストを対象とする
    if not is_break:
        max_key_value_pair = max(advertiser_dict.items(), key=lambda item: len(item[1]))
        threshold = max_key_value_pair[0]
        target_advertiser_id_list = max_key_value_pair[1]
    # 配列を文字列に変換
    filter_name = ",".join(map(str, target_advertiser_id_list))

# Print the results
print(f"Final threshold value for sum(imp): {threshold}")
print("\nList of filter_name:", filter_name)