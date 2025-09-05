import csv
import sys

# ======= 引数処理（ファイルパスを外部から受け取る）=======
if len(sys.argv) != 4:
    print("Usage: python add_protein_description.py <uniref90_csv> <diamond_output_csv> <output_csv>")
    sys.exit(1)

uniref90_csv = sys.argv[1]
diamond_output_file = sys.argv[2]
output_with_description_file = sys.argv[3]

# ======= UniRef90 IDとDescriptionを辞書に読み込み =======
uniref90_annotations = {}
with open(uniref90_csv, "r") as csvfile:
    csv_reader = csv.reader(csvfile)
    next(csv_reader)  # ヘッダーをスキップ
    for row in csv_reader:
        uniref_id = row[0]
        protein_description = row[1]
        uniref90_annotations[uniref_id] = protein_description

# ======= DIAMOND出力にDescriptionを追加して書き出し =======
with open(diamond_output_file, "r") as infile, open(output_with_description_file, "w", newline='') as outfile:
    reader = csv.reader(infile, delimiter=',')  # カンマ区切りのCSVを読み込む
    writer = csv.writer(outfile)

    # ヘッダー
    writer.writerow(["Query ID", "UniRef90 ID", "Protein Description"])

    for row in reader:
        query_id = row[0]  # 例: Fxxx_xxxxx
        uniref_id = row[1]  # 例: UniRef90_ID

        # UniRef90 IDに対応するDescriptionを取得
        protein_description = uniref90_annotations.get(uniref_id, "No Description")

        writer.writerow([query_id, uniref_id, protein_description])

print(f"Output with Protein Descriptions has been written to {output_with_description_file}")
