# Play Store 掲載用アセット

このフォルダは Google Play Console にアップロードするための素材の下書きです。
**Play Consoleへのアップロードが完了したら、このフォルダはリポジトリから削除して構いません**（アプリの動作には不要です）。

## 含まれるファイル

| ファイル | 用途 | 仕様 |
|---|---|---|
| `play-store-icon-512.png` | ストアの高解像度アイコン | 512×512 PNG（`assets/icon_ios.png` から生成） |
| `feature-graphic-1024x500.png` | フィーチャーグラフィック | 1024×500 PNG（アルファなし） |
| `store-listing-ja.md` | アプリ名・説明文の下書き | Play Consoleにそのままコピー&ペースト可 |

## スクリーンショット（未生成・手動で用意してください）

自動生成環境の制約上、実機/エミュレータのスクリーンショットはこの作業では取得できませんでした。
以下の手順で撮影してください。

1. `flutter run -d <device>` で実機またはエミュレータにアプリを起動
2. 以下の2〜4画面を撮影（最低2枚、推奨4〜8枚）
   - トップ画面（前の人数・後ろの人数入力欄）
   - 1分間タイマー画面
   - 計算結果（予想待ち時間）画面
   - アプリの使い方（イントロ）画面
3. 撮影方法:
   - **推奨**: Android Studioの「Extended Controls」→「Screen Record」、またはエミュレータのカメラアイコンでのスクリーンショット機能
   - **非推奨**: `adb shell screencap` はステータスバー・ナビゲーションバーが写り込みやすいため避ける
4. 要件を満たすようにクロップ・リサイズ:
   - 最小辺 320px、最大辺 3840px
   - アスペクト比 16:9 または 9:16
   - 形式: JPEGまたは24bit PNG（アルファなし）

```bash
# 撮影後、アルファチャンネルを除去して要件に合わせる例
sips -s format png --deleteColorManagementProperties screenshot.png
magick screenshot.png -alpha off screenshot-final.png
```
