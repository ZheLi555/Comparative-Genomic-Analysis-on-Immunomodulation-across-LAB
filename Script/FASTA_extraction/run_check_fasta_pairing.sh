#!/bin/sh
#$ -S /bin/sh
#$ -cwd
#$ -l s_vmem=2G
#$ -l mem_req=2G
#$ -l h_rss=2G

start_time=$(date +%s)

# 设置路径（替换为你实际的路径）
PAIRED_DIR="/home/li/diamond_results/DFAST_results/paired_sequences"

# 运行 Python 脚本
python3 check_fasta_pairing.py "$PAIRED_DIR"

end_time=$(date +%s)
echo "🕒 Time used: $((end_time - start_time)) sec"
