import argparse
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
from sklearn.ensemble import RandomForestClassifier
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import LabelBinarizer
from sklearn.metrics import accuracy_score, roc_curve, auc, classification_report
from numpy import interp
import os

def main():
    parser = argparse.ArgumentParser(description="ランダムフォレストを用いた重要遺伝子解析")
    parser.add_argument("input_csv", help="入力CSVファイル（ラベル付きのpresence matrix）")
    parser.add_argument("roc_pdf", help="ROC曲線出力先PDFパス")
    parser.add_argument("importance_csv", help="特徴量重要度出力CSVパス")
    parser.add_argument("top20_pdf", help="重要特徴Top20の棒グラフ出力先PDFパス")
    args = parser.parse_args()

    # === 1. データ読み込み ===
    df = pd.read_csv(args.input_csv, index_col=0)
    df = df[df["Label"].isin(["active", "silent"])]
    X = df.iloc[:, :-1]
    y = df.iloc[:, -1]
    print("全部データの形状:", X.shape)
    print("ラベルの内訳:\n", y.value_counts())

    # === 2. 検証用に 20% を事前に分離 ===
    X_main, X_val, y_main, y_val = train_test_split(X, y, test_size=0.2, stratify=y, random_state=42)

    # === 3. ランダムフォレストを100回実行 ===
    N = 100
    acc_list = []
    auc_list = []
    tprs = []
    mean_fpr = np.linspace(0, 1, 100)
    feature_importance_sum = np.zeros(X.shape[1])

    for i in range(N):
        X_train, X_test, y_train, y_test = train_test_split(
            X_main, y_main, test_size=0.25, stratify=y_main, random_state=i)

        model = RandomForestClassifier(n_estimators=100, random_state=i)
        model.fit(X_train, y_train)

        y_pred = model.predict(X_test)
        y_prob = model.predict_proba(X_test)[:, 1]

        acc = accuracy_score(y_test, y_pred)
        acc_list.append(acc)

        lb = LabelBinarizer()
        y_test_bin = lb.fit_transform(y_test).ravel()
        fpr, tpr, _ = roc_curve(y_test_bin, y_prob)
        roc_auc = auc(fpr, tpr)
        auc_list.append(roc_auc)

        interp_tpr = interp(mean_fpr, fpr, tpr)
        interp_tpr[0] = 0.0
        interp_tpr[-1] = 1.0
        tprs.append(interp_tpr)

        feature_importance_sum += model.feature_importances_

    # === 4. 平均結果表示 ===
    print("\n==== 100回の平均評価結果 ====")
    print(f"Accuracy: {np.mean(acc_list):.3f} ± {np.std(acc_list):.3f}")
    print(f"AUC     : {np.mean(auc_list):.3f} ± {np.std(auc_list):.3f}")

    # === 5. ROC曲線描画 ===
    mean_tpr = np.mean(tprs, axis=0)
    mean_auc = auc(mean_fpr, mean_tpr)

    plt.figure(figsize=(6, 5))
    plt.plot(mean_fpr, mean_tpr, color='darkorange', lw=2, label=f"Mean ROC (AUC = {mean_auc:.2f})")
    plt.plot([0, 1], [0, 1], linestyle='--', color='navy')
    plt.xlabel("False Positive Rate")
    plt.ylabel("True Positive Rate")
    plt.title("Average ROC Curve over 100 runs")
    plt.legend(loc="lower right")
    plt.tight_layout()
    plt.savefig(args.roc_pdf)
    plt.close()
    print(f"ROC曲線を保存しました → {args.roc_pdf}")

    # === 6. 特徴量重要度 ===
    avg_importance = feature_importance_sum / N
    importance_df = pd.DataFrame({
        "Gene": X.columns,
        "Importance": avg_importance
    }).sort_values(by="Importance", ascending=False)
    importance_df.to_csv(args.importance_csv, index=False)
    print(f"特徴量重要度を保存しました → {args.importance_csv}")

    # 上位20件を可視化
    plt.figure(figsize=(12, 5))
    sns.barplot(x="Importance", y="Gene", data=importance_df.head(20), color="skyblue")
    plt.title("Top 20 Important Features (UniRef90 Genes)")
    plt.tight_layout()
    plt.savefig(args.top20_pdf)
    plt.close()
    print(f"Top20の可視化を保存しました → {args.top20_pdf}")

if __name__ == "__main__":
    main()
