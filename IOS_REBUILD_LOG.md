# iOS Rebuild Log

## 2026-04-02

### 実施内容

- [x] 新規追加・既存編集の両方で、空のタスク名を保存できないよう修正
- [x] タイマーがバックグラウンド復帰後も実時間ベースで進行するよう修正
- [x] `AndroidReference` ディレクトリを削除
- [x] `README.md` のディレクトリツリーと関連ドキュメント表記を現行構成へ更新
- [x] タスク編集画面で、追加前の入力欄や色・重み変更だけでは未保存警告を出さないよう修正
- [x] 戻る警告ダイアログの「保存する」から、空のタスクグループが保存されないよう修正
- [x] `README.md` の編集フロー説明と最近の実装メモを更新

### 実装メモ

- `TaskEditScreen` はタスク名の前後空白を除いた値で妥当性判定するようにし、新規追加ボタンと保存ボタンの両方で空名を弾くよう統一した
- 既存タスク編集行にも必須警告を追加し、空文字や空白だけの状態では保存できないことが画面上で分かるようにした
- `TimerViewModel` は 1 秒 tick の回数ではなく前回更新日時との差分秒数を消費するよう変更し、ホーム遷移や画面ロック中に止まって見える問題を解消した
- `TimerScreen` は `scenePhase` が `.active` に戻った時点でも即座に補正をかけ、復帰直後の表示から残り時間がずれないようにした
- 同じ進行ロジックで 0 秒配分タスクも即時に次タスクへ送るよう整理し、ゼロ秒タスク待ちで 1 秒余計に止まるケースも吸収した
- iOS 移植時の参照資料として残していた `AndroidReference` は、現行コードから直接参照されていないことを確認したうえで削除した
- README は現行リポジトリだけで読めるように、概要文、プロジェクトツリー、関連ドキュメント、リリース前チェックを整理した
- `TaskEditScreen` の未保存判定は、永続化される `startTime` / `endTime` / `taskDrafts` の比較へ絞り、追加前の `taskName`、重み、色選択は下書き扱いとして除外した
- 戻る確認ダイアログの「保存する」は `canSave` を満たす場合だけ表示し、`saveCurrentGroup()` 側にも同じ条件のガードを入れて空グループ保存を防いだ

## 2026-04-01

### 実施内容

- [x] 設定画面からアクセント色トグルを削除
- [x] 設定画面のアクセント色トグル文言を、実装どおりの意味へ修正
- [x] タスク一覧ヒーローの `FitTasks` 文字タイトルを削除
- [x] タスク一覧ヒーローの `FitTasks` 文字を、より太く丸い専用タイトルフォントへ調整
- [x] タスク一覧ヒーローを画像ロゴから文字タイトル表示へ戻した
- [x] タスク一覧ヒーローのロゴ画像を、透過背景付きの `fittask_hero_icon.png` へ差し替え
- [x] スプラッシュスクリーンにダークモード専用の背景と配色を追加
- [x] タスク一覧ヒーローだけカード下地を少し白くし、ロゴ画像の白背景となじむよう調整
- [x] タスク一覧ヒーローのロゴ画像を、`fittask_appbar_icon.png` ベースのカラフルなワードマークへ差し替え
- [x] タスク一覧ヒーローのアプリ名テキストを、専用ロゴ画像アセット表示へ差し替え
- [x] タスク一覧ヒーローカード下に、総タスク数とタスクカード数の2指標を表示
- [x] スプラッシュ中央を、汎用タイマー記号ではなくアプリアイコン表示へ変更
- [x] 起動直後にロゴとタイトルがやわらかく動くスプラッシュ画面を追加
- [x] タスク一覧ヒーローカード下の件数表示を、一覧カード数ではなく全タスク総数へ変更
- [x] タスク一覧ヒーローカード下の「次のタスク」補助ピルを削除
- [x] アプリ全体の背景をうっすらピンク基調へ調整
- [x] タスク編集画面で未保存変更のまま戻る場合に破棄確認ダイアログを追加
- [x] タイマー画面の下余白がスクロール終端へ効いていなかった原因を修正
- [x] タイマー画面のスクロール終端に追加余白を入れ、広告帯の下側が見える量を調整
- [x] タスク追加画面の下部広告帯がキーボード表示で押し上がる挙動を修正
- [x] タスク一覧画面の `ViewBuilder` に混入していた数値リテラルを削除し、ビルドエラーを解消
- [x] タイマー画面の下部広告帯を、タスク一覧画面と同じ浮いた配置へ調整
- [x] タスク追加前の重要度スターが、選択中のタスクカラーに即時追従するよう修正
- [x] 主要テキストを丸みのある書体へ寄せるため、共通タイポグラフィを追加
- [x] タスク一覧カードの狭幅レイアウトで、時間帯と平均時間がタスク名の上に積み上がらないよう修正
- [x] タスク名入力欄が長文入力で横に広がるレイアウト崩れを修正
- [x] タスク追加画面のタスク名入力欄に `n/30` カウンターを追加
- [x] タスク名は入力欄で30文字を超えないよう制御を強化
- [x] タスク一覧画面の左上ツールバーに出ていた `FitTasks` 表示を削除

### 実装メモ

- 設定画面からアクセント色トグルを外し、未使用になった `themeDynamic` 文言、`useDynamicAccent` 保存値、`updateDynamicAccent()` を削除して、アプリ全体の tint は常に `FitTasksStyle.primaryAccent` を使う構成へ整理した
- 設定画面の `themeDynamic` は iOS の個別アクセント設定取得ではなく `systemTeal` 切り替えだったため、ローカライズ文言を「システムのアクセント色」系に直し、`AppStore.accentTint` に補足コメントも追加した
- ヒーロー先頭のアプリ名は不要だったため削除し、説明文と件数メトリクスだけを中央配置する構成に整理した
- `FitTasksTypography.heroTitleFont()` を追加し、`ZenMaruGothic-Bold` または丸ゴ系フォールバックを 40pt / black 相当で使うようにして、ヒーローの `FitTasks` をより太くかわいい印象へ寄せた
- ヒーロー画像は視認性が不安定だったため、`TaskListScreen` の先頭を `Text(store.text(.appName))` に戻し、画像用に足していた白背景も撤去した
- `fittask_hero_icon.png` は 1904x544 の透過 PNG として配置されていたため、`FitTasksWordmark.imageset/FitTasksWordmark.png` をこの実ファイルで上書きしてヒーローに反映した
- `SplashScreen` は `colorScheme` を見て、ダークモード時だけ共通の明るい背景ではなく深いネイビー系グラデーションと淡い発光円へ切り替えるようにした
- `GlassCard` 自体は共通部品のため変更せず、`TaskListScreen` の `heroCard` にだけ白の角丸背景を追加してロゴ画像の白場になじませた
- ワークスペース内の `fittask_appbar_icon.png` が 1126x321 の横長ロゴとしてそのまま使えたため、`FitTasksWordmark.imageset/FitTasksWordmark.png` を実ファイル置き換えで更新
- 添付ロゴ画像と同じ 1408x768 PNG を `FitTasksWordmark.imageset` として追加し、`TaskListScreen` のヒーロー先頭で `scaledToFit` 表示するよう変更
- ヒーローカード下は `totalTaskCount` と `taskCardCount` を分けて見せ、横幅が足りない端末では `ViewThatFits` で縦積みに切り替える
- `AppIcon.appiconset` の 1024px PNG をスプラッシュ表示用 `SplashAppIcon.imageset` として複製し、`SplashScreen` 中央へそのまま表示するよう変更
- `LaunchScreen` 自体はアニメーションできないため、`RootView` 最前面へ `SplashScreen` を重ね、初期ロード完了と最低表示時間の両方を満たしたらフェードアウトさせる構成にした
- スプラッシュはピンク基調背景に合わせて、タイマーアイコン入りの丸いバッジを軽く上下させつつ外周をゆっくり脈動させる
- ヒーローカード下の件数は `store.taskGroups.count` ではなく、各 `TaskGroup.tasks.count` を合計した `totalTaskCount` を表示するよう変更
- `TaskListScreen` の `heroCard` ではタスク数だけ残し、意味の薄かった固定文言ピルは撤去して情報密度を整理
- `SceneBackground` の線形グラデーションとぼかし円を全体的にピンク寄りへ寄せ、どの画面でも同じ淡いトーンが出るよう統一
- `TaskEditScreen` は標準の戻るボタンを隠し、同じ見た目の `chevron.left` から未保存変更チェックを通す構成へ変更
- 未保存判定は、開始/終了時刻、追加済みタスク一覧、編集中のタスク名、追加前の重要度・色選択まで含めてスナップショット比較する
- 変更がある状態で戻ると「保存せずに戻る」確認を出し、保存済みまたは未変更ならそのまま一覧へ戻す
- `TimerScreen` はこれまで下余白を `ScrollView` 自体へ付けていたため、スクロール内容の終端余白として効いていなかった
- 下余白は `ScrollView` 内の内容コンテナへ移し、`TaskListScreen` と同じく最下部で広告帯下の背景が少し見える挙動へ合わせた
- `TimerScreen` は広告帯構成自体は一覧画面と同じまま、`ScrollView` 下 padding を 132 へ増やして最下部の見え方を合わせた
- `TaskEditScreen` は広告帯を `safeAreaInset` から外して `ZStack` の下層オーバーレイへ分離し、キーボード回避の影響を受けない構成へ変更
- 広告帯自体には `.ignoresSafeArea(.keyboard, edges: .bottom)` を付け、キーボード表示中も下端固定を維持
- `TaskListScreen` の `safeAreaInset` 内に誤って置かれていた `00` と `2` を削除し、`Static method 'buildExpression' requires that 'Int' conform to 'View'` を解消
- `TimerScreen` の下部広告帯は `TaskListScreen` と同じ `safeAreaInset` 構成へ揃え、広告を画面下端から少し浮かせた
- タイマー画面の `ScrollView` 下 padding も一覧画面と同じ 108 に合わせ、最下部までスクロールしたときに広告帯の下側が少し見える見た目へ調整
- `TaskEditScreen` の追加前プレビューでは、選択済みスター色に `selectedPalette.color` を使うよう変更し、カラー選択と同時に見た目へ反映
- `FitTasksTypography` を追加し、`ZenMaruGothic` が同梱されていれば優先、未同梱時は `HiraMaruProN-W4`、最後に system rounded へフォールバック
- 一覧、編集、言語選択、設定、タイマーの主要ラベルへ共通タイポグラフィを適用し、全体の印象を丸く統一
- `TaskGroupCard` の `compactLayout` を 2 カラム化し、左列に時間帯と平均時間、右列にタスク一覧を配置
- 狭幅時の編集・削除ボタンはカード下部右寄せに移し、主要情報の横並びを維持
- `LimitedTextField` に横方向の hugging/compression priority 調整を入れ、SwiftUI 側も `maxWidth: .infinity` で親幅に追従させた
- `TaskEditScreen` の追加欄と既存タスク編集欄の両方で、警告文の横に現在文字数カウンターを常時表示
- SwiftUI の `TextField` では見た目上 30 文字超の入力が通るケースがあったため、`UITextField` ラッパーで入力自体を制限
- 貼り付け時も残り文字数ぶんだけ反映し、入力欄の見た目上も 30 文字を超えないようにした
- `TaskListScreen` の `ToolbarItem(placement: .topBarLeading)` を撤去し、右上の設定導線のみを残した

## 2026-03-31

### 実施内容

- [x] タスク保存後の遷移処理を `onClose()` から `dismiss()` に修正
- [x] タスク作成画面と設定画面の追加 `chevron.left` を削除し、システム標準の戻るボタンのみを使用
- [x] タスク作成画面と設定画面の「戻る」文字ボタンを削除し、`<` アイコンのみに統一
- [x] AdMob 用の `.env` を iOS ターゲット配下へ移動
- [x] iOS 側に `AdMobConfiguration.swift` を追加し、AdMob キーは `Config/Info.plist` に定義
- [x] `GoogleMobileAds` の初期化とバナー広告読み込みを iOS 側へ接続
- [x] タイマー画面の戻る導線を `<` ボタンに統一
- [x] タイマー画面でシステム戻るボタンを隠し、確認ダイアログ付きの戻り処理へ統一
- [x] タスク編集画面の過去タスク名 UI を削除
- [x] `TaskEditScreen.swift`、`AppStore.swift`、`AppLocalization.swift` の関連定義を整理
- [x] SwiftUI の画面構成を再確認
- [x] `README.md` に各画面 UI と対応ファイルの一覧表を追加
- [x] メイン画面とシート系補助 UI を分けて整理
- [x] タイマー中のライブ編集導線を削除
- [x] `TimerScreen.swift` のライブ編集シートと関連更新処理を削除
- [x] `README.md` とローカライズ定義を現行仕様に合わせて更新

### 実装メモ

- `TaskEditScreen` の保存完了後は `@Environment(\.dismiss)` で閉じるようにし、削除済みの `onClose` 参照を解消
- タスク編集画面と設定画面では独自ツールバーを撤去し、`NavigationStack` 標準の戻る表示へ一本化
- タスク編集画面と設定画面の戻り操作は、表示を `chevron.left` のみに整理しつつ VoiceOver 用ラベルは維持
- `AndroidReference/.env` にあった AdMob 設定は `fittasks/.env` へ移し、iOS ターゲット側の広告設定として扱う
- 同期フォルダ配下の `Info.plist` は重複ビルド要因になるため使わず、ターゲット同期外の `Config/Info.plist` を参照する
- `FitTasksApp` 起動時に `MobileAds.shared.start()` を呼び、`FooterBannerAd` は `AdMobConfiguration` からバナー ID を読む
- タイマー画面では文字の「戻る」ボタンを廃止し、`chevron.left` のみを表示する
- 画面左上の戻り操作は必ず `handleBackRequest()` を通るようにして警告ダイアログを統一
- タスク名候補の横スクロール表示は廃止し、編集画面は手入力のみの構成に整理
- 画面遷移の起点は `fittasks/UI/Screens/RootView.swift`
- 画面本体に加えて、`TaskEditScreen.swift` と `TimerScreen.swift` の同一ファイル内に定義されたシート UI も一覧へ含めた
- 共通 UI 部品として `TaskGroupCard.swift`、`FooterBannerAd.swift`、`DesignSystem.swift` を参照先として明記した
- タイマー画面は一覧拡張シートのみを残し、実行中の編集導線は持たない構成に整理
- ライブ編集専用だった `AppLocalization.liveEditButton` を削除
- タイマー中のタスクグループ差し替え処理も不要になったため `TimerViewModel` から除去

## 2026-03-30

### 解析対象

- `AGENTS.md`
- `README.md`
- `AndroidReference` 配下の Markdown 一式
- `AndroidReference` 配下の主要 Kotlin 参照コード

### 実施内容

- [x] Android 版の機能と保守ルールを整理
- [x] `fittasks.xcodeproj` を iOS / iPadOS 前提の設定へ調整
- [x] SwiftUI ベースの iOS ネイティブアプリを再構築
- [x] タスク一覧 / タスク編集 / タイマー / 設定 / 初回言語選択を実装
- [x] 翌日またぎ時間計算と重み付き配分ロジックを Swift に移植
- [x] タイマー画面に長押しスキップ、一覧拡張、進行中編集を実装
- [x] `ios_icon/ios` の App Icon を適用
- [x] README を iOS 版に更新し、プロジェクトツリーを更新

### 実装メモ

- 永続化は iOS 単体で完結するよう `UserDefaults` ベースで実装
- Android 版の `TaskGroup` 配分ロジックを踏襲し、最低 1 秒保証と端数再配分を維持
- Android 版のタイマー保守ルールに合わせ、短押しスキップを禁止
- AdMob SDK はこの環境で追加できないため、`FooterBannerAd` はプレースホルダと `canImport(GoogleMobileAds)` 分岐で実装

### 検証メモ

- `xcodebuild` によるビルド確認を試行したが、作業環境の `xcode-select` が Command Line Tools を向いており、Xcode 本体が利用できなかった
- そのため最終的な iOS ビルド確認は、Xcode 本体が入った環境で実施する前提
