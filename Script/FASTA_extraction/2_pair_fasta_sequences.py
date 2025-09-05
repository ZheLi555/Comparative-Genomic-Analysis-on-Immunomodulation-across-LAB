import os
import shutil
import sys

def pair_fasta_sequences(filtered_silent_dir, filtered_active_dir, paired_sequences_dir):
    os.makedirs(paired_sequences_dir, exist_ok=True)

    # 获取 silent 和 active 文件名集合（去掉 .fasta 后缀）
    silent_files = {f.replace('.fasta', '') for f in os.listdir(filtered_silent_dir) if f.endswith('.fasta')}
    active_files = {f.replace('.fasta', '') for f in os.listdir(filtered_active_dir) if f.endswith('.fasta')}

    # 找到配对成功的文件
    paired_files = silent_files.intersection(active_files)

    for file_base in paired_files:
        silent_file_path = os.path.join(filtered_silent_dir, f"{file_base}.fasta")
        active_file_path = os.path.join(filtered_active_dir, f"{file_base}.fasta")

        # 复制并重命名
        shutil.copy(silent_file_path, os.path.join(paired_sequences_dir, f"{file_base}_s.fasta"))
        shutil.copy(active_file_path, os.path.join(paired_sequences_dir, f"{file_base}_a.fasta"))

    print(f"Paired files copied to: {paired_sequences_dir} (Total: {len(paired_files)})")

if __name__ == "__main__":
    if len(sys.argv) != 4:
        print("Usage: python pair_fasta_sequences.py [silent_dir] [active_dir] [output_dir]")
        sys.exit(1)

    silent_dir = sys.argv[1]
    active_dir = sys.argv[2]
    output_dir = sys.argv[3]

    pair_fasta_sequences(silent_dir, active_dir, output_dir)
