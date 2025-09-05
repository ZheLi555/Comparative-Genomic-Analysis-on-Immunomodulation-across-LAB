#!/bin/bash

# ====== 設定（必要に応じて変更） ======
PY_SCRIPT="filter_zero_columns.py"  # Pythonスクリプトのパス
INPUT_CSV="input_matrix.csv"        # 入力マトリックスCSVファイル
OUTPUT_CSV="filtered_matrix.csv"    # 出力CSVファイル

# ====== チェックと実行 ======
if [ ! -f "$PY_SCRIPT" ]; then
  echo "エラー: Pythonスクリプトが見つかりません: $PY_SCRIPT"
  exit 1
fi
if [ ! -f "$INPUT_CSV" ]; then
  echo "エラー: 入力CSVファイルが見つかりません: $INPUT_CSV"
  exit 1
fi

echo "Pythonスクリプトを実行中..."
python3 "$PY_SCRIPT" "$INPUT_CSV" "$OUTPUT_CSV"

if [ $? -eq 0 ]; then
  echo "フィルタ処理が完了しました: $OUTPUT_CSV"
else
  echo "エラーが発生しました。"
fi
