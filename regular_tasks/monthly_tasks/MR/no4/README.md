## 実行手順
todo

## ファイルの格納場所
- [G:\共有ドライブ\DM課\DMイントラ\引継ぎ・代理対応\shasegawa_2409\notebook\作業エクセル
20240808_SSP比較_共通広告主に限定.xlsx](https://drive.google.com/drive/folders/14EzJzwE9ziMC2uITcVlKI6U4S9XzoKhK)

## 仕様
### 共通案件の抽出
求めたいのは、下記の条件を満たした広告主IDをリストで出すこと
#### 条件
- 除外リストを除くこと
- デバイスとcreative(display,native,video)を組み合わせた種類別で集計すること（group by）
- 広告主のSSPごとのimpを出すこと
- imp閾値を設定すること(10000, 5000, 3000)
- imp閾値を超えるimpを持つSSPの種類をカウントすること
- SSP閾値を設定すること(対象のSSP全体の8割)
- カウントしたSSPの数がSSP閾値を超えていれば、その広告主IDをリストに追加すること
- 全てのデバイスとcreativeの組み合わせについてリストを出力すること

#### 1 中間テーブル作成
os、is_app、creative、広告主ID、SSP、impの中間テーブルを作成する。

#### 2,3,4 PC、displayの対象の広告主を対象にして集計
- PC、displayの対象の広告主を求める
- chatGPT先生に聞いて実装
- 3の少し内部を見てみる

#### 99 作成した中間テーブルをドロップする

## 結果

## 課題
- 自動化をするのであれば、excuse.pyのような大元の関数を一つ作ってあげて、処理を別関数で記述して実行する形式で可能だと思われる。
- インフラ構成や方法などは別途考える必要あり。

## メモ
  - ailab_tools → ailabで作っている各種ツール群
  - impala、GSheet、GMail等の操作が簡単にできる
  - [ドキュメント](https://s3-ap-northeast-1.amazonaws.com/ailab-smn-valis/ailab-tools/docs/html/index.html)を参照