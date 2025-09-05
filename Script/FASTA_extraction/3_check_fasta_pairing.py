import os
import sys

def check_paired_fasta(paired_sequences_dir):
    # 获取所有 .fasta 文件
    paired_files = [f for f in os.listdir(paired_sequences_dir) if f.endswith('.fasta')]

    # 提取基名
    s_files = {f.replace('_s.fasta', '') for f in paired_files if f.endswith('_s.fasta')}
    a_files = {f.replace('_a.fasta', '') for f in paired_files if f.endswith('_a.fasta')}

    # 匹配和未匹配
    paired = s_files.intersection(a_files)
    unpaired_s = s_files - a_files
    unpaired_a = a_files - s_files

    # 输出结果
    if not unpaired_s and not unpaired_a:
        print(f"All files in {paired_sequences_dir} are properly paired.")
    else:
        if unpaired_s:
            print(f"The following _s files do not have matching _a files: {unpaired_s}")
        if unpaired_a:
            print(f"The following _a files do not have matching _s files: {unpaired_a}")

    print(f"Total number of paired files: {len(paired)}")

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python check_fasta_pairing.py [paired_sequences_dir]")
        sys.exit(1)

    check_paired_fasta(sys.argv[1])
