import csv
import re
import sys

def parse_query_id(qid: str):
    """
    'F001_00020' → (1, 20) のように変換して数値ソート可能にする。
    フォーマットに一致しない場合は (999999, 999999) を返す。
    """
    match = re.match(r'^F(\d+)_(\d+)$', qid.strip())
    if match:
        return (int(match.group(1)), int(match.group(2)))
    else:
        return (999999, 999999)

def main():
    if len(sys.argv) < 3:
        print("❌ 使用方法: python merge_and_sort_csv.py <csv1> <csv2> ... <output_file>")
        sys.exit(1)

    input_files = sys.argv[1:-1]
    output_file = sys.argv[-1]

    all_rows = []
    header = None

    for i, file_path in enumerate(input_files):
        with open(file_path, "r", newline="", encoding="utf-8") as f:
            reader = csv.reader(f)
            file_header = next(reader, None)
            if i == 0:
                header = file_header
            for row in reader:
                if not row or len(row) < 3:
                    continue
                if row[0].lower() == "query":
                    continue
                all_rows.append(row)

    all_rows.sort(key=lambda r: parse_query_id(r[0]))

    with open(output_file, "w", newline="", encoding="utf-8") as out:
        writer = csv.writer(out)
        if header:
            writer.writerow(header)
        writer.writerows(all_rows)

    print(f"✅ {len(input_files)} 件のCSVをマージして昇順で保存しました：{output_file}")

if __name__ == "__main__":
    main()
