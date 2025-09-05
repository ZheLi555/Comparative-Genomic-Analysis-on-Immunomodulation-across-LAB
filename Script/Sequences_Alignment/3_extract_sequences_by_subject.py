import pandas as pd
import os
import sys

# ==== 引数確認 ====
if len(sys.argv) != 4:
    print("Usage: python extract_sequences_by_subject.py [best_hits_csv] [fasta_dir] [output_dir]")
    sys.exit(1)

best_hits_file = sys.argv[1]
fasta_files_dir = sys.argv[2]
output_dir = sys.argv[3]

# ==== 读取 best_hits 文件 ====
best_hits_df = pd.read_csv(best_hits_file)

# ==== 构建 subject → query 列表的映射 ====
subject_to_query = {}
for _, row in best_hits_df.iterrows():
    subject = row['subject']
    query = row['query']
    subject_to_query.setdefault(subject, []).append(query)

# ==== 读取所有 FASTA 文件 ====
def read_fasta(file):
    sequences = {}
    with open(file, 'r') as f:
        current_seq_id = None
        current_seq = []
        for line in f:
            if line.startswith('>'):
                if current_seq_id:
                    sequences[current_seq_id] = ''.join(current_seq)
                current_seq_id = line.strip().split()[0][1:]
                current_seq = []
            else:
                current_seq.append(line.strip())
        if current_seq_id:
            sequences[current_seq_id] = ''.join(current_seq)
    return sequences

all_sequences = {}
for filename in os.listdir(fasta_files_dir):
    if filename.endswith('.fna'):
        file_path = os.path.join(fasta_files_dir, filename)
        all_sequences.update(read_fasta(file_path))

# ==== 保存提取出的序列 ====
os.makedirs(output_dir, exist_ok=True)
for subject, queries in subject_to_query.items():
    output_file = os.path.join(output_dir, f"{subject}.fasta")
    with open(output_file, 'w') as f:
        for query in queries:
            if query in all_sequences:
                f.write(f">{query}\n{all_sequences[query]}\n")
            else:
                print(f"Query {query} not found in FASTA files.")

print(f"Sequences extracted and saved to {output_dir}")
