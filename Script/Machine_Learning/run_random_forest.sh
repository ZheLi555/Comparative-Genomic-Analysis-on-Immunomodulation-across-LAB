#!/bin/bash

# ===== ユーザー設定 START =====
INPUT_CSV="path/to/new_matrix_with_label.csv"
OUT_ROC="path/to/output/ROC_curve_avg100.pdf"
OUT_IMPORTANCE_CSV="path/to/output/feature_importance.csv"
OUT_TOP20_PDF="path/to/output/top20_features_barplot.pdf"
PY_SCRIPT="path/to/random_forest_analysis.py"
# ===== ユーザー設定 END =====

# チェック
if [ ! -f "$PY_SCRIPT" ]; then
  echo "Pythonスクリプトが見つかりません: $PY_SCRIPT"
  exit 1
fi

if [ ! -f "$INPUT_CSV" ]; then
  echo "入力CSVが見つかりません: $INPUT_CSV"
  exit 1
fi

# 実行
echo "ランダムフォレスト分析を実行中..."
python3 "$PY_SCRIPT" "$INPUT_CSV" "$OUT_ROC" "$OUT_IMPORTANCE_CSV" "$OUT_TOP20_PDF"

# 成功確認
if [ $? -eq 0 ]; then
  echo "処理が完了しました。"
else
  echo "エラーが発生しました。"
fi
