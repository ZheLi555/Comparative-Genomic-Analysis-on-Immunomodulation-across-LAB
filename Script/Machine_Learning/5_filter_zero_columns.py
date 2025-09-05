import csv
import sys
from collections import defaultdict

def filter_zero_columns(input_matrix_csv, output_filtered_csv):
    # === 1. CSVを2次元リストに読み込む ===
    matrix = []
    with open(input_matrix_csv, "r", encoding="utf-8") as f:
        reader = csv.reader(f)
        for row in reader:
            matrix.append(row)

    if not matrix:
        print("入力ファイルが空です。処理を中止します。")
        return

    header = matrix[0]
    data_rows = matrix[1:]

    # === 2. 残す列インデックスを決定（全て0の列を除外）===
    columns_to_keep = [0]  # Fxxxを含む1列目は必ず保持
    for col_idx in range(1, len(header)):
        all_zero = True
        for line_number, row in enumerate(data_rows, start=1):
            if len(row) <= col_idx:
                continue
            if row[col_idx] != "0":
                all_zero = False
                break
        if not all_zero:
            columns_to_keep.append(col_idx)

    # === 3. 新しいマトリックスを作成 ===
    filtered_matrix = []
    filtered_matrix.append([header[i] for i in columns_to_keep])
    for row_index, row in enumerate(data_rows, start=1):
        new_row = []
        for i in columns_to_keep:
            new_row.append(row[i] if i < len(row) else "")
        filtered_matrix.append(new_row)

    # === 4. CSVに出力 ===
    with open(output_filtered_csv, "w", encoding="utf-8", newline="") as out_f:
        writer = csv.writer(out_f)
        writer.writerows(filtered_matrix)

    removed_count = len(header) - len(columns_to_keep)
    print(f"完了: {removed_count} 列を除去しました。出力先: {output_filtered_csv}")

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("使用方法: python filter_zero_columns.py 入力CSV 出力CSV")
        sys.exit(1)

    input_csv = sys.argv[1]
    output_csv = sys.argv[2]
    filter_zero_columns(input_csv, output_csv)
