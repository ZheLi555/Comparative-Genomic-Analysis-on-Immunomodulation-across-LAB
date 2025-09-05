import pandas as pd
import os
import sys

# ==== 引数からパス取得 ====
if len(sys.argv) != 3:
    print("Usage: python extract_best_hits.py [input_directory] [output_file]")
    sys.exit(1)

input_dir = sys.argv[1]
output_file = sys.argv[2]

def parse_diamond_output(file):
    if os.stat(file).st_size == 0:
        return pd.DataFrame()
    df = pd.read_csv(file, sep='\t', header=None)
    df.columns = [
        'query', 'subject', 'identity', 'alignment_length', 'mismatches', 
        'gap_openings', 'q_start', 'q_end', 's_start', 's_end', 'evalue', 'bit_score'
    ]
    return df

def extract_best_hits(directory, filenames):
    all_hits = []
    for filename in filenames:
        file_path = os.path.join(directory, filename)
        df = parse_diamond_output(file_path)
        if not df.empty:
            best_hits = df.loc[df.groupby('query')['bit_score'].idxmax()]
            all_hits.append(best_hits)
    return pd.concat(all_hits) if all_hits else pd.DataFrame()

# 获取文件列表
result_files = os.listdir(input_dir)

# 提取并保存最佳比对结果
best_hits_df = extract_best_hits(input_dir, result_files)
best_hits_df.to_csv(output_file, index=False)
print(f"Best hits extracted and saved to: {output_file}")
