# FitTasks Project Overview

FitTasks is a modern Android application designed to help users manage their tasks within specific time intervals. A key feature of the app is its ability to calculate the duration allocated to each task based on a given time range (e.g., dividing 37 minutes equally among 5 tasks).

## 振る舞いとルール
- 適宜コミットする。コミットメッセージは日本語にする。
- プッシュは絶対に行わない
- README.mdを適宜更新する。
- README.mdのプロジェクトツリーを適宜更新する。
- 横画面と縦画面両方に対応できるようにUIをレスポンシブルなデザインに必ずする。
- どのタブレット、スマホでみてもUIが崩れないように必ずする。
- README.mdの　## タイマー保守ルールを必ず守る。
- コードには適宜可読性を考慮したコメントを必ず付与する

## 設計ゴール
- 疎結合かつ再利用しやすい用に設計する。
- クリーンアーキテクチャで構築する。
- ユーザーが直感的に操作できるようにモダンで親しみやすいかわいいデザインを心がける
- タスク分解してタスクごとに処理を進める
- 随時タスクの内容や実装内容を別途ファイルとして書き出しログに残す。 

## アプリのユーザーフロー
- アプリを開く
- 所要時間または時間範囲を指定する。例：15:58~翌7:04までという時間範囲の指定方法または30分というように具体的な時間の入力
- タスクを追加する。
- 追加したタスクを所要時間または時間範囲で割ってひとつあたりのタスクの所要時間を算出し、所要時間内ですべてのタスクに持ち時間を定める。
- リストに一覧表示させ、リストの要素をタップするとタイマーが自動スタートし、タスクの所要時間が終わったら次のタスクに自動的に移る。
- ユーザーは画面に表示されたタスク名と、タイマーを見ながら、残りの時間を確認し、作業を進める。
- たくさんタスクを入れるとひとつあたりのタスクの所要時間は少なくなる

## Technology Stack

- **Platform:** Android
- **Language:** Kotlin (Kotlin 2.2.10+)
- **UI Framework:** Jetpack Compose with Material3
- **Build System:** Gradle (Kotlin DSL) with Version Catalogs (`libs.versions.toml`)
- **Minimum SDK:** 27 (Android 8.1)
- **Target SDK:** 36

## Project Structure

- `app/`: Main application module.
  - `src/main/java/com/kasouzou/fittasks/`: Kotlin source code.
    - `MainActivity.kt`: Entry point of the application.
    - `model/`: Data models (e.g., `TaskGroup`, `TaskItem`).
    - `ui/`: Compose-based UI components.
      - `TaskListScreen.kt`: The main list view showing task groups.
      - `components/`: Reusable UI components like `TaskGroupCard`.
      - `theme/`: App-wide styling, colors, and typography.
- `gradle/`: Gradle configuration and wrapper files.
  - `libs.versions.toml`: Centralized dependency management.

## Building and Running

### Development Commands

- **Build Project:**
  ```bash
  ./gradlew assembleDebug
  ```
- **Run Unit Tests:**
  ```bash
  ./gradlew test
  ```
- **Run Android Instrumented Tests:**
  ```bash
  ./gradlew connectedAndroidTest
  ```
- **Install on Device/Emulator:**
  ```bash
  ./gradlew installDebug
  ```
- **Clean Build:**
  ```bash
  ./gradlew clean
  ```

## Development Conventions

- **UI Implementation:** Exclusively uses Jetpack Compose. Follow Material3 design guidelines.
- **Dependency Management:** All dependencies must be defined in `gradle/libs.versions.toml` and referenced using the `libs` catalog.
- **Architecture:** Follow modern Android development practices, emphasizing separation of concerns between data models and UI components.
- **Naming:** Follow standard Kotlin and Android naming conventions (PascalCase for classes, camelCase for variables/functions).
