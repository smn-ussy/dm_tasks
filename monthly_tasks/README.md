# 週次用
DM課の週時作業を行うSQL,Pythonを管理します。

## no2
execute.pyを実行すると自動的にexcelまで出力される
Jupyter上で実行できれば、ひとまずかなりの簡略化になるはず
（jupyter上で実行するのであれば、日付は別で入れられる方がよいか...?）


## no.3とno.4のExcelの優先度をまずは上げていく



## メモ
  - ailab_tools → ailabで作っている各種ツール群
  - impala、GSheet、GMail等の操作が簡単にできる
  - [ドキュメント](https://s3-ap-northeast-1.amazonaws.com/ailab-smn-valis/ailab-tools/docs/html/index.html)を参照

## 案
1. 各月次タスクのSQLを全部ファイルに記述する
2. pythonからはファイルを実行するのみに留める
3. 月次を自動化するならpythonを実行する時にファイル処理を待って次に繋げるようにする

### 懸念点
・現在Excelで処理している内容はSQLに記述するかpythonで処理するか
・変数を渡せる形でPythonを書くならテンプレートエンジンを使うのがよい？（自動化部分の話）
  - まずはJupyter形式で全て実行できるようにする
・最終的にはAWSのEventBridgeとか使って自動化するのが楽そう(ただし技術的な話も入るため、ここは理想論)