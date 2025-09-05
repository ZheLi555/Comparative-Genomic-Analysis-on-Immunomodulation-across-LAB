#!/bin/sh
#$ -S /bin/sh
#$ -cwd
#$ -l s_vmem=5G
#$ -l mem_req=5G
#$ -l h_rss=5G

start_time=`date +%s`

# ==== 引数取得 ====
BEST_HITS_CSV=$1
FASTA_DIR=$2
OUTPUT_DIR=$3

if [ -z "$BEST_HITS_CSV" ] || [ -z "$FASTA_DIR" ] || [ -z "$OUTPUT_DIR" ]; then
  echo "Usage: bash run_extract_sequences_by_subject.sh [best_hits_csv] [fasta_dir] [output_dir]"
  exit 1
fi

# ==== 実行 ====
echo "Extracting sequences from: $FASTA_DIR based on $BEST_HITS_CSV"
python3 extract_sequences_by_subject.py "$BEST_HITS_CSV" "$FASTA_DIR" "$OUTPUT_DIR"

end_time=`date +%s`
time=$((end_time - start_time))
echo "Done in $time seconds"
