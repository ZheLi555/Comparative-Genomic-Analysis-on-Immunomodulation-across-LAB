#!/bin/bash

# ====== ユーザー設定部分 START ======

# 処理対象の作業ディレクトリ（.fastaファイルなどが格納されているフォルダ）
WORKDIR="/Users/yourname/path/to/your/fasta_folder"

# 実行するRスクリプトのパス（コマンドライン引数でパスを受け取れる形式に変更済みであること）
RSCRIPT_PATH="/Users/yourname/path/to/your_script.R"

# ====== ユーザー設定部分 END ======

# 作業ディレクトリの存在確認
if [ ! -d "$WORKDIR" ]; then
  echo "エラー：作業ディレクトリが存在しません: $WORKDIR"
  exit 1
fi

# Rスクリプトの存在確認
if [ ! -f "$RSCRIPT_PATH" ]; then
  echo "エラー：Rスクリプトが見つかりません: $RSCRIPT_PATH"
  exit 1
fi

# Rスクリプトを実行（作業ディレクトリを引数として渡す）
echo "作業ディレクトリを指定してRスクリプトを実行中: $WORKDIR"
Rscript "$RSCRIPT_PATH" "$WORKDIR"

# 実行結果の確認
if [ $? -eq 0 ]; then
  echo "Rスクリプトが正常に完了しました。"
else
  echo "Rスクリプトの実行に失敗しました。"
fi
