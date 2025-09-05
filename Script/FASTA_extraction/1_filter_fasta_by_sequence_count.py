import os
import sys

if len(sys.argv) != 3:
    print("Usage: python filter_fasta_by_sequence_count.py [input_dir] [output_dir]")
    sys.exit(1)

extracted_dir = sys.argv[1]
filtered_dir = sys.argv[2]

os.makedirs(filtered_dir, exist_ok=True)

def filter_fasta_files(in_dir, out_dir):
    for filename in os.listdir(in_dir):
        if filename.endswith('.fasta'):
            file_path = os.path.join(in_dir, filename)

            with open(file_path, 'r') as f:
                lines = f.readlines()

            header_lines = [line for line in lines if line.startswith('>')]

            if len(header_lines) > 1:
                out_path = os.path.join(out_dir, filename)
                with open(out_path, 'w') as f:
                    f.writelines(lines)
                print(f" {filename} copied ({len(header_lines)} sequences)")
            else:
                print(f" {filename} excluded (only one sequence)")

filter_fasta_files(extracted_dir, filtered_dir)
print(f"\nFiltered files saved to: {filtered_dir}")
