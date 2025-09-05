乳酸菌プロジェクトの解析scriptの一覧表

# 解析手順
1.配列アラインメント
2.FASTA配列の抽出と整形
3.比較ゲノム解析
2.機械学習

配列アラインメント
1. CDS配列の機能アノテーション
2. DIAMOND出力からのBest hit抽出	
2. 注釈結果に基づくCDS配列の抽出	


FASTA配列の抽出と整形
1. 配列数に基づくFASTAファイルのフィルタリング	
2. Active/Silent 群のFASTA配列のペアリングと整理	
3. FASTAペアファイルの整合性チェック	

比較ゲノム解析
1. 遺伝子間距離マトリクスの算出
2. クラスタ評価指標の算出
3. PG指数の設計と補正
4. K-meansによるPG指標の評価

機械学習による免疫関連遺伝子の予測
1. DIAMOND出力への機能記述（Description）付与	
2. Active/Silentラベル付きアノテーションの整理
3. 二値特徴行列の構築とゼロ列の除去
4. ランダムフォレストによる性能評価と特徴量重要度の抽出		


# ファイル一覧
1. Raw files
| Data           | Path                    | Description                     |
|----------------|-------------------------|---------------------------------|
| LAB_genomes    | `./Data/genomes/`       | 193株乳酸菌の全ゲノム配列（.fna） |
| IL_12_values   | `./Data/metadata.csv`   | IL-12誘導能（ELISA測定データ）    |
| UniRef90_database | `./Data/UniRef90/uniref90.dmnd` | DIAMOND用 UniRef90 データベース（ローカル）|

> **Note**: The UniRef90 database (`uniref90.dmnd`) was downloaded from [UniProt FTP](https://ftp.uniprot.org/pub/databases/uniprot/uniref/) on 2024-10-16.

# Script
1. 配列アラインメント
CDS配列に対して、DIAMONDを用いたUniRef90データベースとの照合により機能アノテーションを実施する。また、Best hitの抽出や、注釈に基づくUncharacterized遺伝子の判定も行う。
| 操作内容                                 | Script                                                              |
| ---------------------------------------- | ------------------------------------------------------------------- |
| DIAMONDによる機能アノテーション               | Sequences_Alignment/1_diamond_annotation.sh                         |
| Best hitの抽出およびフィルタリング             | Sequences_Alignment/run_extract_best_hits.sh                        |
| 注釈情報に基づく配列の統合および整列           | Sequences_Alignment/run_extract_sequences_by_subject.sh             |


2. FASTA配列の抽出と整形
免疫能に基づいて分類された菌株群（Active/Silent）から、CDS配列数によるフィルタリングを行い、有効なFASTAファイルのみを抽出する。その後、群別のペアリングおよび整合性チェックを実施する。
| 操作内容                                  | Script                                              |
| ------------------------------------- | -------------------------------------------------- |
| CDS数に基づくFASTAファイルのフィルタリング             | `FASTA_extraction/run_filter_fasta_by_sequence_count.sh`          |
| Active/Silent 群に基づくFASTAファイルの整理・ペアリング | `FASTA_extraction/run_pair_fasta_sequences.sh`    |
| ペアFASTAファイルの整合性チェック                   | `fFASTA_extraction/run_check_fasta_pairing.sh` |


3. 比較ゲノム解析
Active群とSilent群の間で、各機能別FASTA配列の相同性を距離として数値化し、構造的な多様性を定量評価する。CH-indexやPG-indexといった指標により、免疫能の差異と関連する遺伝子をスクリーニングする。
| 操作内容                             | Script                                            |
| -------------------------------- | ------------------------------------------------ |
| アラインメントと距離マトリクスの算出               | `Comparative_Genome_Analysis/run_rscript.sh` |
| クラスタ評価指標（CH-index）の算出            | `Comparative_Genome_Analysis/run_rscript.sh`      |
| PG-index の設計と補正処理                | `Comparative_Genome_Analysis/run_rscript.sh`     |
| PG-index 上位遺伝子に対するK-meansクラスタリング | `Comparative_Genome_Analysis/run_rscript.sh`     |


4. 機械学習による免疫関連遺伝子の予測
比較ゲノム解析で得られた配列と機能アノテーションに基づき、ランダムフォレストモデルを用いて免疫能に関与する可能性の高い遺伝子を予測する。
| 操作内容                            | Script                                             |
| ------------------------------- | -------------------------------------------------- |
| DIAMOND出力へのDescription（機能記述）の付加 | `Machine_Learning/run_add_description.sh`           |
| ペア配列に対応するアノテーション行の抽出            | `Machine_Learning/run_Filter_Diamond_Output.sh`      |
| Active/Silent群の注釈データ統合と整列       | `Machine_Learning/run_merge_and_sort.sh`      |
| 二値特徴行列（0/1行列）の作成                | `Machine_Learning/run_generate_matrix.sh` |
| 全ゼロ列の除去による行列最適化                 | `Machine_Learning/filter_zero_columns.sh`                  |
| ランダムフォレストによる分類・性能評価             | `Machine_Learning/run_random_forest.sh`               |
