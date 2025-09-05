import csv
import sys
from collections import defaultdict

def main():
    if len(sys.argv) != 3:
        print("❌ 使用方法: python generate_presence_matrix.py <输入CSV> <输出矩阵CSV>")
        sys.exit(1)

    input_csv = sys.argv[1]
    output_matrix_csv = sys.argv[2]

    matrix_dict = defaultdict(dict)
    all_query_prefixes = set()
    all_uniref_ids = set()

    with open(input_csv, "r", encoding="utf-8") as f:
        reader = csv.reader(f)
        header = next(reader, None)

        for row in reader:
            if len(row) < 3:
                continue

            query_id = row[0]
            uniref_id = row[1]
            description = row[2]

            query_prefix = query_id.split("_", 1)[0]
            val = 0 if description.strip() == "Uncharacterized protein" else 1
            current_val = matrix_dict[query_prefix].get(uniref_id, 0)
            matrix_dict[query_prefix][uniref_id] = max(current_val, val)

            all_query_prefixes.add(query_prefix)
            all_uniref_ids.add(uniref_id)

    sorted_query_prefixes = sorted(all_query_prefixes)
    sorted_uniref_ids = sorted(all_uniref_ids)

    with open(output_matrix_csv, "w", encoding="utf-8", newline="") as f_out:
        writer = csv.writer(f_out)
        writer.writerow([""] + sorted_uniref_ids)

        for qp in sorted_query_prefixes:
            row = [qp]
            for uid in sorted_uniref_ids:
                row.append(matrix_dict[qp].get(uid, 0))
            writer.writerow(row)

    print(f"✅ 矩阵生成成功：{output_matrix_csv}")

if __name__ == "__main__":
    main()
