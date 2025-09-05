#!/bin/bash

# ====== ユーザー設定部分 START ======

# Pythonスクリプトのパス
PY_SCRIPT="/home/li/diamond_results/DFAST_results/scripts/merge_and_sort_csv.py"

# マージするCSVファイル（スペースで区切る）
INPUT_CSV_1="/home/li/diamond_results/DFAST_results/0513/active_results/a_0513_diamond_output_filtered.csv"
INPUT_CSV_2="/home/li/diamond_results/DFAST_results/0513/silent_results/s_0513_diamond_output_filtered.csv"

# 出力先ファイル名
OUTPUT_CSV="/home/li/diamond_results/DFAST_results/0513/0513_all_diamond_output_with_description.csv"

# ====== ユーザー設定部分 END ======

# Pythonスクリプト存在チェック
if [ ! -f "$PY_SCRIPT" ]; then
  echo "エラー：スクリプトが見つかりません: $PY_SCRIPT"
  exit 1
fi

# 入力ファイル存在チェック
for csv_file in "$INPUT_CSV_1" "$INPUT_CSV_2"; do
  if [ ! -f "$csv_file" ]; then
    echo "エラー：入力CSVファイルが見つかりません: $csv_file"
    exit 1
  fi
done

# スクリプト実行
echo "CSVファイルをマージしています..."
python3 "$PY_SCRIPT" "$INPUT_CSV_1" "$INPUT_CSV_2" "$OUTPUT_CSV"

if [ $? -eq 0 ]; then
  echo "マージ完了: $OUTPUT_CSV"
else
  echo "エラー：マージ処理中に問題が発生しました。"
fi
