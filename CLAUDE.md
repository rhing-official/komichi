# komichi

PDF・CBZ 形式の電子書籍/コミックをローカルで管理・閲覧する Flutter 製クロスプラットフォームリーダー。

キャッチコピー: 「本と、二人きり」

対応OS: Android / Windows / Linux（将来 iOS / macOS）。バックエンドはローカルのみ（クラウド同期なし）。

## ドキュメント

企画書・技術仕様書などの一次情報は Obsidian ボルトが実体で、`docs/` にシンボリックリンクを置いてある（`docs/` 側を編集すれば Obsidian 側にも反映される）。

- [docs/企画書.md](docs/企画書.md) — 要件・機能一覧・開発ロードマップ（v1.0 Draft, 2026年2月時点）
- [docs/技術仕様書.md](docs/技術仕様書.md) — アーキテクチャ・データモデル・ビューア仕様の設計文書
- [docs/開発指示書.md](docs/開発指示書.md) — 初期実装をステップ単位で進めた際の指示書（プロジェクト名は旧称 `kuwa` のまま。実際の pubspec 名は `komichi`）
- [docs/実装済みショートカット.md](docs/実装済みショートカット.md) — 現行のキーボード/マウス操作一覧。企画書のフェーズ計画にない機能（タブ、本棚サイドバー、複数選択）も含む

**注意:** 上記ドキュメントは設計時点のスナップショットであり、実装は次のように乖離している。コードを触る際は下記「既知の乖離点」を優先し、ドキュメントは背景理解に留める。

## 技術スタック

Flutter (Dart) / SDK `>=3.0.0 <4.0.0`

主要パッケージ（[pubspec.yaml](pubspec.yaml)）:

| パッケージ | 用途 |
|---|---|
| pdfx | PDF表示・レンダリング |
| archive | CBZ (ZIP) 展開 |
| flutter_riverpod | 状態管理 |
| hive / hive_flutter | ローカルDB（書籍・設定・本棚） |
| path_provider | ローカルパス取得 |
| file_picker | フォルダ/ファイル選択 |
| photo_view | CBZ画像のピンチズーム |
| window_manager | カスタムタイトルバー・フルスクリーン制御（技術仕様書に記載なし、実装のみ） |
| uuid | ID採番 |
| go_router | **pubspec には存在するが未使用**（下記参照） |

## アーキテクチャ

```
lib/
  main.dart                         # エントリーポイント。windowManager初期化 → Hive初期化・Box open → runApp
  app.dart                          # KomichiApp（テーマ）+ TabShell（タブバー・本棚サイドバー・メイン表示、ルーティングの代わり）
  core/
    db/hive_adapter.dart
    providers/
      tab_provider.dart             # タブ管理・ナビゲーション履歴（undo/redo）★企画書にない追加機能
      selection_provider.dart       # 複数選択（全選択/範囲選択）★同上
      sidebar_focus_provider.dart   # Ctrl+Fでサイドバー検索欄へフォーカスを要求するシグナル★同上
    services/
      file_service.dart
      cbz_service.dart
      pdf_cache_service.dart        # ★技術仕様書にない追加サービス
      thumbnail_service.dart        # ★同上
    theme/app_theme.dart            # 未使用（app.dart が独自にThemeDataを定義）
    utils/sort_utils.dart           # ★同上
  features/
    library/
      models/{book,shelf}.dart (+ .g.dart, Hive生成コード)
      providers/library_provider.dart
      views/{shelf_screen,home_placeholder_screen}.dart  # home_placeholder_screen は新規タブの初期表示★追加機能
      widgets/bookshelf_sidebar.dart  # 常駐サイドバー（本棚一覧・検索・お気に入り・フォルダ追加）★追加機能
      widgets/book_card.dart          # 未使用
    viewer/
      models/read_state.dart
      providers/viewer_provider.dart
      views/viewer_screen.dart
      widgets/{pdf_viewer,cbz_viewer}.dart
      widgets/{overlay_ui,page_slider}.dart  # 未使用
    settings/
      models/app_settings.dart (+ .g.dart)
      providers/settings_provider.dart
      views/settings_screen.dart
```

## 本棚サイドバー（常駐パネル）

画面左または右に固定幅（260px）で常駐する `BookshelfSidebar`（[lib/features/library/widgets/bookshelf_sidebar.dart](lib/features/library/widgets/bookshelf_sidebar.dart)）。旧 `LibraryScreen`（本棚グリッド・検索）と `FileBrowserScreen`（お気に入り・フォルダ追加・削除）を統合したもので、両画面は廃止済み。

- 位置は `AppSettings.sidebarPosition`（設定画面から変更可）
- 本棚一覧の行をタップすると**現在アクティブなタブの中身**が切り替わる（`tabProvider.navigateTo` を呼ぶだけで新規タブは開かない）
- `Ctrl+F` はサイドバー検索欄へのフォーカス要求（`sidebarFocusRequestProvider`）に用途変更
- 新規タブ（`Ctrl+T`）を開いた直後、本棚も本も未選択のときは `HomePlaceholderScreen` を表示

## 既知の乖離点（企画書/技術仕様書 vs 実装）

- **ルーティング**: 技術仕様書は GoRouter によるルート定義（`/`, `/shelf/:id`, `/viewer/:id`, `/settings`）を想定しているが、実装は `app.dart` の `TabShell` が `IndexedStack` + `tab_provider.dart` の独自タブ状態で画面を切り替えている。ブラウザ的な戻る/進む履歴（`TabItem.history` / `historyIndex`）もここで管理。`go_router` は依存関係に残るが未使用。
- **マルチタブ・複数選択**: 企画書のフェーズ計画（Phase 1〜4）には出てこないが、`tab_provider.dart` / `selection_provider.dart` として先行実装済み。詳細な操作は [docs/実装済みショートカット.md](docs/実装済みショートカット.md) が正。
- **タブモード廃止**: かつて存在した `AppSettings.tabMode`（`fixedLibrary`/`independent`の切り替え）は廃止し、常に「本はそのタブ内で開く」動作に統一した。`TabMode` enum自体は既存Hiveデータの後方互換デコード用にコード上残っているが、新規に参照してはならない。
- **ウィンドウ管理**: `window_manager` でカスタムタイトルバー（`TitleBarStyle.hidden` + 独自の最小化/最大化/閉じるボタン）と、ビューアのUIオーバーレイ非表示時の自動フルスクリーン化を実装。技術仕様書には記載なし。
- **プロジェクト名**: 開発指示書内は旧称 `kuwa` のままだが、pubspec.yaml の `name` は `komichi`。

## データモデル（Hive）

- **Book**: id(UUID), title, filePath, shelfId, format(pdf|cbz), totalPages, lastPage, isFinished, addedAt, thumbnailPath — [lib/features/library/models/book.dart](lib/features/library/models/book.dart)
- **Shelf**: id, name, folderPath, bookCount — [lib/features/library/models/shelf.dart](lib/features/library/models/shelf.dart)
- **AppSettings**: pageDirection(leftToNext|rightToNext), theme(system|light|dark), sidebarPosition(left|right) — [lib/features/settings/models/app_settings.dart](lib/features/settings/models/app_settings.dart)

モデル変更時は `.g.dart` の再生成が必要（下記コマンド）。Hiveは自己記述的バイナリ形式のため、フィールドを削除する際は型アダプタの登録だけ残す等、既存ローカルデータの後方互換に注意すること（`TabMode`/`TabModeAdapter` が実例）。

## 開発コマンド

```bash
flutter pub get                                              # 依存関係取得
flutter pub run build_runner build --delete-conflicting-outputs  # Hiveアダプタ(.g.dart)再生成
flutter analyze                                               # 静的解析
flutter test                                                  # テスト実行
flutter run -d linux    # / -d windows / -d android           # 実行
flutter build linux     # / build windows / build apk         # ビルド
```

## 主要な操作仕様

### ビューア画面タップ3分割

| エリア | デフォルト動作 |
|---|---|
| 左1/3 | 前のページ（設定でページめくり方向を反転可） |
| 中央1/3 | UIオーバーレイ表示/非表示 |
| 右1/3 | 次のページ |

最終ページで「次へ」操作すると「次の本を開く」ボタンを中央表示。同フォルダ内でファイル名昇順の次ファイルへ遷移。

### キーボード操作（[docs/実装済みショートカット.md](docs/実装済みショートカット.md) が正。技術仕様書の一覧は初期設計版）

| キー | 動作 |
|---|---|
| `←` / `→` | 前/次ページ |
| `Ctrl+←` / `Ctrl+→` | 最初/最後のページへ |
| `Shift+←` / `Shift+→` | 同フォルダ内の前/次の本を開く |
| `Space` | UIオーバーレイ表示切り替え |
| `Esc` | タブ内で1つ上の階層に戻る（タブは閉じない） |
| `Alt+←` / `Alt+→` | タブ内ナビゲーション履歴の戻る/進む |
| `Ctrl+Tab` / `Ctrl+Shift+Tab` | 右/左のタブへ切り替え |
| `Ctrl+T` | 新規本棚タブを開く |
| `Ctrl+W` | 現在のタブを閉じる |
| `Ctrl+I` | 設定タブを開く |
| `Ctrl+F` | サイドバーの検索欄にフォーカス |
| `Ctrl+A` | 表示中フォルダ/ファイルを全選択 |
| `Ctrl+クリック` / `Shift+クリック` | 個別選択の追加/解除・範囲選択 |
| マウス中ボタンクリック | タブを閉じる/本を新タブで開く |
| マウスの戻る/進むボタン | タブ内ナビゲーション履歴の戻る/進む |

- ユーザーが書き換えたコードに関して、プログラムが動かなくなる場合を除き、修正しない
- git push,pullは全て https://github.com/rhing-official/komichi で行う
- コミュニケーションは日本語で行う
- トークンの取得や管理者権限が不要なターミナルの実行など、全般的な処理は全てClaude Codeが行う