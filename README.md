<div id="top"></div>

# FitTasks

<p style="display: inline">
  <img src="https://img.shields.io/badge/-iOS-0A84FF.svg?logo=apple&style=for-the-badge&logoColor=white">
  <img src="https://img.shields.io/badge/-Swift-FA7343.svg?logo=swift&style=for-the-badge&logoColor=white">
  <img src="https://img.shields.io/badge/-SwiftUI-0A84FF.svg?style=for-the-badge&logoColor=white">
</p>

## 目次

1. [概要](#概要)
2. [環境](#環境)
3. [機能](#機能)
4. [画面 UI 対応表](#画面-ui-対応表)
5. [ディレクトリ構成](#ディレクトリ構成)
6. [関連ドキュメント](#関連ドキュメント)
7. [開発環境構築](#開発環境構築)
8. [トラブルシューティング](#トラブルシューティング)

## 概要

FitTasks は、指定した時間枠の中で複数タスクへ持ち時間を自動配分し、そのまま順番に実行できる iOS ネイティブアプリです。

重視している要件は「翌日またぎの時間計算」「重み付き配分」「長押しスキップ」「多言語切替」で、iPhone / iPad の縦横両対応 UI として Swift / SwiftUI で構築しています。

<p align="right">(<a href="#top">トップへ</a>)</p>

## 環境

| 項目 | 内容 |
| --- | --- |
| プラットフォーム | iOS / iPadOS |
| 言語 | Swift 5 |
| UI | SwiftUI |
| プロジェクト | Xcode Project (`fittasks.xcodeproj`) |
| Deployment Target | iOS 17.0 |
| 対応画面 | iPhone / iPad / 縦画面 / 横画面 |
| 永続化 | `UserDefaults` ベースのローカル保存 |

<p align="right">(<a href="#top">トップへ</a>)</p>

## 機能

- **タスクグループ管理**: 開始時刻・終了時刻・タスクリストの作成 / 編集 / 削除
- **翌日またぎの時間範囲**: `23:30 -> 00:15` のような時間帯でも正しく所要時間を算出
- **重み付き時間配分**: タスクごとの重みに応じて持ち時間を比例配分
- **安全な編集フロー**: 編集対象が未ロードまたは欠損している場合は保存を抑止
- **未保存変更の離脱警告**: タスク編集画面で保存対象の変更がある状態で戻ると、破棄確認を表示
- **自動進行タイマー**: タスク終了時に次タスクへ自動遷移
- **実時間補正タイマー**: バックグラウンド復帰や画面ロック解除後も、実際に経過した時間ぶん残り時間を補正
- **長押しスキップ**: 誤操作防止のため短押しではスキップしない
- **一覧拡張シート**: タイマー中の全タスクをボトムシート相当のシートで広く確認可能
- **多言語対応**: 日本語 / 英語 / 中国語（簡体字） / 韓国語
- **テーマ切替**: System / Light / Dark と iOS アクセントカラー切替
- **背景デザイン**: 全画面で、うっすらピンクを基調にしたやわらかい背景グラデーションを使用
- **広告領域**: `GoogleMobileAds` を Swift Package Manager で組み込み、iOS 下部バナー広告を表示できる構成

<p align="right">(<a href="#top">トップへ</a>)</p>

## 画面 UI 対応表

### メイン画面

| 画面 | 役割 | 対応ファイル | 補足 |
| --- | --- | --- | --- |
| ルート画面 | 初回ロード後に言語選択画面またはタスク一覧画面を出し分け、各画面への遷移を管理 | `fittasks/UI/Screens/RootView.swift` | `NavigationStack` と `AppStore.Route` の遷移定義を保持 |
| スプラッシュ画面 | 起動直後にロゴとタイトルをアニメーション表示 | `fittasks/UI/Screens/SplashScreen.swift` | `RootView` の全画面オーバーレイとして短時間表示 |
| 初回言語選択画面 | 初回起動時に利用言語を選択 | `fittasks/UI/Screens/LanguageSelectionScreen.swift` | セットアップ完了後に一覧画面へ遷移 |
| タスク一覧画面 | 登録済みタスクグループ一覧、開始、編集、削除、設定遷移 | `fittasks/UI/Screens/TaskListScreen.swift` | カード表示は `fittasks/UI/Components/TaskGroupCard.swift` を利用 |
| タスク編集画面 | 時間帯設定、タスク追加、重み設定、色選択、保存 | `fittasks/UI/Screens/TaskEditScreen.swift` | 新規作成と既存編集を兼用 |
| タイマー画面 | 実行中タスク表示、残り時間、再生/停止、長押しスキップ | `fittasks/UI/Screens/TimerScreen.swift` | 縦横でレイアウトを切り替える |
| 設定画面 | 言語変更、テーマ変更、動的アクセント切替 | `fittasks/UI/Screens/SettingsScreen.swift` | 一覧画面右上から遷移 |

### 画面内で開く補助 UI

| UI | 開く場所 | 対応ファイル | 補足 |
| --- | --- | --- | --- |
| 時刻選択シート | タスク編集画面 | `fittasks/UI/Screens/TaskEditScreen.swift` | `TimePickerSheet` として同ファイル内に定義 |
| タイマー中のタスク一覧シート | タイマー画面 | `fittasks/UI/Screens/TimerScreen.swift` | `TaskListSheetContent` として同ファイル内に定義 |
| タスクカード UI | タスク一覧画面 | `fittasks/UI/Components/TaskGroupCard.swift` | 一覧に並ぶ各グループカードの見た目を担当 |
| フッター広告 UI | 一覧、編集、タイマー | `fittasks/UI/Components/FooterBannerAd.swift` | 各画面下部の広告スロット |
| 共通デザイン部品 | 全画面 | `fittasks/UI/Components/DesignSystem.swift` | `GlassCard` など共通スタイル部品を定義 |

<p align="right">(<a href="#top">トップへ</a>)</p>

## ディレクトリ構成

```text
.
├── .gitignore
├── AGENTS.md
├── IOS_REBUILD_LOG.md
├── README.md
├── fittasks
│   ├── .env.example
│   ├── App
│   │   ├── AdMobConfiguration.swift
│   │   ├── AppStore.swift
│   │   └── fittasksApp.swift
│   ├── Assets.xcassets
│   │   ├── AccentColor.colorset
│   │   ├── FitTasksWordmark.imageset
│   │   ├── SplashAppIcon.imageset
│   │   └── AppIcon.appiconset
│   ├── Data
│   │   └── Repositories.swift
│   ├── Domain
│   │   ├── AppPreferences.swift
│   │   └── TaskModels.swift
│   ├── Localization
│   │   └── AppLocalization.swift
│   └── UI
│       ├── Components
│       │   ├── DesignSystem.swift
│       │   ├── FooterBannerAd.swift
│       │   └── TaskGroupCard.swift
│       └── Screens
│           ├── LanguageSelectionScreen.swift
│           ├── RootView.swift
│           ├── SettingsScreen.swift
│           ├── SplashScreen.swift
│           ├── TaskEditScreen.swift
│           ├── TaskListScreen.swift
│           └── TimerScreen.swift
├── fittasks.xcodeproj
│   ├── project.pbxproj
│   └── project.xcworkspace
└── ios_icon
    ├── ios
    └── macos
```

<p align="right">(<a href="#top">トップへ</a>)</p>

## 関連ドキュメント

- [IOS_REBUILD_LOG.md](./IOS_REBUILD_LOG.md): iOS 版再構築の作業ログ

<p align="right">(<a href="#top">トップへ</a>)</p>

## 開発環境構築

1. Xcode をインストールする。
2. `fittasks.xcodeproj` を開く。
3. Signing を設定する。
4. iPhone または iPad シミュレータを選択してビルドする。

CLI 例:

```bash
xcodebuild -scheme fittasks \
  -destination 'generic/platform=iOS Simulator' \
  CODE_SIGNING_ALLOWED=NO build
```

`GoogleMobileAds` は Swift Package Manager 経由で参照する構成です。AdMob のアプリ ID は [Config/Info.plist](./Config/Info.plist) の `GADApplicationIdentifier`、バナー広告 ID は `ADMOB_BANNER_AD_UNIT_ID` から読みます。iOS 側の広告設定値は [fittasks/.env](./fittasks/.env) にも保持し、Xcode の file-system synchronized target でアプリバンドルへ含めたうえで `AdMobConfiguration.swift` から優先参照します。

`fittasks/.env.example` をコピーして `fittasks/.env` を作成し、`APP_ID`/`AD_UNIT_ID` を本番値へ置き換えてください。`fittasks/.env` は `.gitignore` で無視されており、公開リポジトリへ本番 ID を含めないためにコミットしないでください（代わりに `.env.example` を共有してローカルでのみ本番値を設定します）。

<p align="right">(<a href="#top">トップへ</a>)</p>

## トラブルシューティング

- `xcode-select: tool 'xcodebuild' requires Xcode` が出る場合:
  Command Line Tools ではなく Xcode 本体を選択してください。
- App Icon が反映されない場合:
  `fittasks/Assets.xcassets/AppIcon.appiconset` に `ios_icon/ios` の PNG 一式と `Contents.json` が入っているか確認してください。
- 広告がプレースホルダ表示のままの場合:
  Xcode が Swift Package Manager の依存取得を完了しているか確認してください。依存未取得時は `canImport(GoogleMobileAds)` が無効になり、プレースホルダ表示になります。

## リリース前チェック

- `.env` の取り扱い: `fittasks/.env.example` をコピーして `fittasks/.env` を作り、`APP_ID`/`AD_UNIT_ID` を本番値へ書き換えてください。この `.env` は `.gitignore` で無視され、公開リポジトリへ本番 ID が含まれないようにしてください。必要なら本番値は安全なチャネルで共有し、ローカルだけに保存します。

## 最近の実装メモ

- 2026-05-04: 下部 AdMob バナーの一時非表示フラグを解除し、バンドル済み `.env` の本番広告 ID を読み込んで広告表示へ復旧
- 2026-05-01: スクリーンショット撮影用に、下部広告枠を `AdMobConfiguration.isBannerTemporarilyHidden` で一時非表示に変更
- 2026-04-02: 既存タスク編集画面で、新しいタスク名を入力したまま追加せずに戻る場合も未保存警告を出すよう修正
- 2026-04-02: タスク名は、新規追加時も既存タスク編集時も空文字や空白だけでは保存できないよう入力検証を追加
- 2026-04-02: タイマーは、ホーム遷移・画面ロック・バックグラウンド復帰後も実時間ぶん残り時間を補正するよう修正
- 2026-04-02: iOS 移植時の参照資料として残していた `AndroidReference` を削除し、README の構成と関連ドキュメント表記を現行リポジトリに合わせて整理
- 2026-04-02: タスク編集画面は、追加前の入力欄や色・重みの下書き変更だけでは未保存警告を出さず、離脱前保存でも空タスクカードを生成しないよう修正
- 2026-04-01: 設定画面からアクセント色トグルを削除し、関連する設定値と文言も整理
- 2026-04-01: 設定画面のアクセント色トグルは、実装どおり「システムのアクセント色」に文言を修正
- 2026-04-01: タスク一覧ヒーローの `FitTasks` 文字タイトルを削除し、説明文と件数表示だけの構成へ整理
- 2026-04-01: タスク一覧ヒーローの `FitTasks` 文字は、より太く丸い専用タイトルフォントへ調整
- 2026-04-01: タスク一覧ヒーローは画像ロゴをやめ、可読性優先で文字タイトル表示へ戻した
- 2026-04-01: タスク一覧ヒーローのロゴ画像を、透過背景付きの `fittask_hero_icon.png` に差し替え
- 2026-04-01: スプラッシュスクリーンはダークモード時だけ専用の深い背景色と淡い光彩に切り替わるよう調整
- 2026-04-01: タスク一覧ヒーローだけカード下地を少し白くし、ロゴ画像の白背景となじむよう調整
- 2026-04-01: タスク一覧ヒーローのロゴ画像を、`fittask_appbar_icon.png` ベースのカラフルなワードマークへ差し替え
- 2026-04-01: タスク一覧ヒーローの `FitTasks` テキストを、カラフルな文字ロゴ画像アセットへ差し替え
- 2026-04-01: タイマー画面の下余白は `ScrollView` 本体ではなく内容側へ付けるよう修正し、広告帯下の見え方を正常化
- 2026-04-01: タイマー画面は下端の見え方を揃えるため、スクロール終端の下余白を追加で確保
- 2026-04-01: タスク追加画面の広告帯をスクロール層から分離し、キーボード表示でも下端固定のままに調整
- 2026-04-01: タスク一覧画面の下部広告帯まわりに混入していた数値リテラルを削除し、`ViewBuilder` エラーを解消
- 2026-04-01: タイマー画面の下部広告帯をタスク一覧画面と同じ浮いた配置へ揃え、最下部までスクロールしたときに帯の下側も見える構成へ調整
- 2026-04-01: タスク追加前の重要度スターも、選択中カラーに即時追従するよう調整
- 2026-04-01: 主要テキストを丸みのある書体へ寄せ、`ZenMaruGothic` 同梱時は優先適用、未同梱時は iOS の丸ゴ系へフォールバックする仕組みを追加
- 2026-04-01: タスク一覧カードの狭幅レイアウトを調整し、時間帯と平均時間を左列、タスク名を右列に寄せた
- 2026-04-01: タスク名入力欄の UIKit ラッパーが横方向に広がらないよう、レイアウト優先度と幅指定を調整
- 2026-04-01: タスク追加画面のタスク名入力欄に `n/30` カウンターを追加し、入力欄で30文字を超えないよう制御を強化
- 2026-04-01: タスク編集画面で未保存変更がある状態の戻る操作に、破棄確認ダイアログを追加
- 2026-04-01: アプリ全体の背景を、うっすらピンク基調のグラデーションへ調整
- 2026-04-01: タスク一覧ヒーローカード下の補助ピルから、用途不明だった「次のタスク」表示を削除
- 2026-04-01: タスク一覧ヒーローカード下の件数表示を、一覧カード数ではなく全カード内タスクの総数へ変更
- 2026-04-01: タスク一覧ヒーローカード下に、総タスク数とタスクカード数の2指標を並べて表示
- 2026-04-01: 起動直後にロゴとタイトルがやわらかく動くスプラッシュ画面を追加
- 2026-04-01: スプラッシュ中央の汎用タイマー記号をやめ、アプリアイコン画像を表示する構成へ変更
- 2026-04-01: タスク一覧画面の左上ツールバーに出ていた `FitTasks` 表示を削除
- 2026-03-30: 旧 Android 版の仕様と Kotlin 実装を基に、SwiftUI による iOS ネイティブ版へ再構築
- 2026-03-30: iPhone / iPad の縦横両対応レイアウト、タイマーの長押しスキップ、初回言語選択を追加
- 2026-03-30: `ios_icon/ios` のアイコン群を `AppIcon.appiconset` に適用

## タイマー保守ルール

- スキップは誤操作防止のため長押し前提。短押しでスキップ処理を呼ばない。
- `fittasks/Domain/TaskModels.swift` の配分ロジック、`fittasks/UI/Screens/TimerScreen.swift` の `TimerViewModel` を変更する際は、少なくとも次を確認する:
  - 重み付き配分の合計秒数がグループ総秒数と一致すること
  - 翌日またぎの時間帯で即終了しないこと
  - バックグラウンド復帰や画面ロック解除後に、残り時間が実時間どおり補正されること
  - 完了遷移と戻る確認ダイアログが壊れていないこと
- Xcode の Unit Test ターゲットは今後追加予定。追加後はタイマーまわりの変更前に必ず自動テストを通すこと。

<p align="right">(<a href="#top">トップへ</a>)</p>
