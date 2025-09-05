#!/bin/bash

# ====== ユーザー設定 START ======

# Pythonスクリプトのパス
PY_SCRIPT="/home/li/diamond_results/DFAST_results/scripts/generate_presence_matrix.py"

# 入力CSVファイル（3列構成: Query ID, UniRef90 ID, Protein Description）
INPUT_CSV="/home/li/diamond_results/DFAST_results/0513/0513_all_diamond_output_with_description.csv"

# 出力ファイル（0/1行列）
OUTPUT_MATRIX="/home/li/diamond_results/DFAST_results/0513/0513_all_matrix_output.csv"

# ====== ユーザー設定 END ======

# スクリプト存在確認
if [ ! -f "$PY_SCRIPT" ]; then
  echo "エラー：Pythonスクリプトが見つかりません：$PY_SCRIPT"
  exit 1
fi

# 入力ファイル確認
if [ ! -f "$INPUT_CSV" ]; then
  echo "エラー：入力CSVが見つかりません：$INPUT_CSV"
  exit 1
fi

# スクリプトを実行
echo "0/1マトリクスを作成中..."
python3 "$PY_SCRIPT" "$INPUT_CSV" "$OUTPUT_MATRIX"

# 結果確認
if [ $? -eq 0 ]; then
  echo "完了：マトリクス出力 → $OUTPUT_MATRIX"
else
  echo "実行中にエラーが発生しました。"
fi
