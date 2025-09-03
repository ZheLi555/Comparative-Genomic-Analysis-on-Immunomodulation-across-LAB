# Comparative-Genomic-Analysis-on-Immunomodulation-across-LAB
乳酸菌プロジェクト
乳酸菌プロジェクトのデータ一覧表

# 解析手順
1.Sequences Alignment

2.FASTA Extraction

3.Comparative Genome Analysis
2.機械学習


# ファイル一覧
1. Raw files
| Data           | Path                    | Description                     |
| LAB_genomes    | `./Data/genomes/`       | 193株乳酸菌の全ゲノム配列（.fna） |
| IL_12_values   | `./Data/metadata.csv`   | IL-12誘導能（ELISA測定データ）    |
| UniRef90_database | `./Data/UniRef90/uniref90.dmnd` | DIAMOND用 UniRef90 データベース（ローカル）|

> **Note**: The UniRef90 database (`uniref90.dmnd`) was downloaded from [UniProt FTP](https://ftp.uniprot.org/pub/databases/uniprot/uniref/) on 2024-10-16.
