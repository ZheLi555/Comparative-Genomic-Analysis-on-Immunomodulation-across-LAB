#!/bin/sh
#$ -S /bin/sh
#$ -cwd
#$ -l s_vmem=5G
#$ -l mem_req=5G
#$ -l h_rss=5G

start_time=`date +%s`

# ==== 1. 引数確認 ====
INPUT_DIR=$1
OUTPUT_FILE=$2

if [ -z "$INPUT_DIR" ] || [ -z "$OUTPUT_FILE" ]; then
  echo "Usage: bash run_extract_best_hits.sh [input_directory] [output_file_path]"
  exit 1
fi

# ==== 2. 実行 ====
echo "Extracting best hits from: $INPUT_DIR"
python3 extract_best_hits.py "$INPUT_DIR" "$OUTPUT_FILE"

end_time=`date +%s`
time=$((end_time - start_time))
echo "Done in $time seconds"
