#!/bin/bash

if [ "$#" -ne 3 ]; then
    echo "使用方法: bash $0 <CDSフォルダ> <UniRef90データベース(.dmnd)> <出力フォルダ>"
    echo "例: bash $0 ./cds_dir ./uniref90.dmnd ./diamond_results"
    exit 1
fi

# === 引数の取得 ===
FFN_DIR="$1"        # 入力ディレクトリ（.fna ファイルが含まれる）
UNIREF90_DB="$2"    # DIAMOND用 UniRef90 データベース (.dmnd)
OUTPUT_DIR="$3"     # 出力ディレクトリ

# 出力ディレクトリが存在しない場合は作成
mkdir -p "$OUTPUT_DIR"

# === 各FFNファイルに対して DIAMOND を実行 ===
for FFN_FILE in "$FNA_DIR"/*.fna; do
    BASENAME=$(basename "$FNA_FILE" .fna)
    OUTPUT_FILE="${OUTPUT_DIR}/${BASENAME}_diamond.out"

    echo "▶ 処理中: $FNA_FILE"

    diamond blastx \
        -d "$UNIREF90_DB" \
        -q "$FFN_FILE" \
        -o "$OUTPUT_FILE" \
        --outfmt 6 qseqid sseqid pident length mismatch gapopen qstart qend sstart send evalue bitscore \
        --max-target-seqs 1 \
        --evalue 1e-5 \
        --threads 8

    echo " 完了: $OUTPUT_FILE"
done

echo " すべてのDIAMOND処理が完了しました。出力: $OUTPUT_DIR"
