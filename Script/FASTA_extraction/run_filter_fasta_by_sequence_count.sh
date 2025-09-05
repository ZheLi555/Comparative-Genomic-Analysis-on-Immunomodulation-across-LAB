#!/bin/sh
#$ -S /bin/sh
#$ -cwd
#$ -l s_vmem=4G
#$ -l mem_req=4G
#$ -l h_rss=4G

start_time=`date +%s`

INPUT_DIR=$1
OUTPUT_DIR=$2

if [ -z "$INPUT_DIR" ] || [ -z "$OUTPUT_DIR" ]; then
  echo "Usage: bash run_filter_fasta_by_sequence_count.sh [input_dir] [output_dir]"
  exit 1
fi

echo "Filtering FASTA files from: $INPUT_DIR"
python3 filter_fasta_by_sequence_count.py "$INPUT_DIR" "$OUTPUT_DIR"

end_time=`date +%s`
time=$((end_time - start_time))
echo "Done in $time seconds"
