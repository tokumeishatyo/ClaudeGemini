# autodev

4つのClaudeインスタンスを使った協働開発ワークフローシステム

## 概要

このシステムは、CEO、Manager、Developer、Reviewerの4つの役割を持つClaudeインスタンスが協働して、アプリケーション開発を行うワークフローです。

## 特徴

- **段階的な品質管理**: 各フェーズで厳格な承認プロセス
- **役割分担の明確化**: 各担当者が専門分野に集中
- **GitHub連携**: ブランチ戦略とプルリクエストワークフロー
- **Opusリミット対応**: 開発中断・再開機能
- **汎用性**: 任意のプロジェクトに適用可能
- **自動ログ**: 全活動の詳細記録
- **🚀 革新的な自動時間分析**: 開発完了後にワンクリックで詳細な時間分析レポートを生成

## システム構成

```
CEO (左上・紫)     Manager (右上・オレンジ)
    ↓                  ↓
Reviewer (左下・青)   Developer (右下・緑)
```

### 役割分担

- **CEO**: 戦略的判断・最終承認・GitHub初期化（作業は行わない）
- **Manager**: プロジェクト管理・情報伝達ハブ（実作業は行わない）
- **Developer**: 実装・文書作成・ブランチ管理（Opusモデル使用）
- **Reviewer**: 品質チェック・承認・プルリクエストレビュー（厳格な審査）

## 事前準備

### 1. **GitHub設定の確認**（必須手動作業）
```bash
# 🚨 **手動作業**: GitHub CLIの認証確認
gh auth status

# 🚨 **手動作業**: 認証されていない場合
gh auth login
# ブラウザが開くので、GitHubにサインインして認証を完了
```

### 2. planning.txtの準備
```bash
# planning.txtを編集
vi /workspace/Demo/WorkFlow/planning.txt
```

planning.txtの記入例：
```markdown
# プロジェクト企画書テンプレート

## プロジェクト概要
Webベースのタスク管理アプリケーションを開発したい

## 目的・背景
チーム内のタスク管理を効率化し、進捗の可視化を図りたい

## 要求機能・仕様
- ユーザー登録・ログイン機能
- タスクの作成・編集・削除
- タスクの進捗管理（未着手・進行中・完了）
- チームメンバーへのタスク割り当て
- ダッシュボード画面

## 制約事項
- 開発期間：2ヶ月以内
- 技術スタック：React + Node.js
- 予算制約：特になし

## 期待される成果
- 使いやすいWebアプリケーション
- モバイル対応
- セキュアな認証システム
```

## 初回起動手順

### 1. ワークスペース起動
```bash
cd /workspace/Demo
./setup_claude_workspace.sh
```

### 2. 各ペインの状態確認
起動後、4つのペインで以下が表示されます：
- **CEO（左上・紫）**: instructions_ceo.mdの内容
- **Manager（右上・オレンジ）**: instructions_manager.mdの内容
- **Reviewer（左下・青）**: instructions_review.mdの内容
- **Developer（右下・緑）**: instructions_developer.mdの内容

### 3. **GitHub初期化**（CEOが実行する手動作業）
ワークスペース起動後、まずCEOがGitHub連携を行います：

#### **ステップ1: GitHub上でのリポジトリ作成**
```bash
# 🚨 **手動作業**: GitHub.comにアクセスして新規リポジトリを作成
# 1. https://github.com にアクセス
# 2. 「New repository」をクリック
# 3. プロジェクト名を入力
# 4. 「Create repository」をクリック
```

#### **ステップ2: テンプレートクローンと初期化**
```bash
# 🚨 **手動作業**: autodevテンプレートのクローン
git clone https://github.com/tokumeishatyo/autodev.git [新しいプロジェクト名]
cd [新しいプロジェクト名]

# 🚨 **手動作業**: .gitディレクトリを削除して新しいプロジェクトとして初期化
rm -rf .git
git init
git add .
git commit -m "Initial commit from autodev template"

# 🚨 **手動作業**: リモートを設定してプッシュ
git remote add origin https://github.com/[YOUR_USERNAME]/[新しいプロジェクト名].git
git push -u origin main
```

### 4. 自動的にワークフロー開始
GitHub初期化後、自動的にCEOペインにフォーカスが移り、以下が実行されます：

1. **instructions_ceo.md** の内容が表示される
2. **planning.txt** の内容が表示される
3. **CEOペインがアクティブ**になり、作業開始準備が完了

この段階で、CEOは表示されたplanning.txtの内容を確認し、以下のようにManagerに指示を出します：
```
planning.txtを確認しました。
以下のアプリケーション開発を開始します。

【プロジェクト内容】
[planning.txtの内容に基づいて記述]

Managerペイン: planning.txtの内容を確認し、要件定義書と外部仕様書の作成を開始してください。
一度で完成させず、議論を重ねて合意を形成していきます。
まずは初期版を作成してください。
```

### 5. 以降の進行
- ManagerがCEOの指示を受けて要件定義書作成開始
- CEO-Manager間で段階的な議論
- 承認後、Developer・Reviewerが順次参加

## ペイン間の移動方法
```bash
# ペイン移動（tmuxのキーバインド）
Ctrl + B, ←  # 左のペインへ
Ctrl + B, →  # 右のペインへ
Ctrl + B, ↑  # 上のペインへ
Ctrl + B, ↓  # 下のペインへ

# または番号で直接移動
Ctrl + B, 0  # CEOペイン（左上）
Ctrl + B, 1  # Managerペイン（右上）
Ctrl + B, 2  # Reviewerペイン（左下）
Ctrl + B, 3  # Developerペイン（右下）
```

## Opusリミット対応

### 中断時の操作
```bash
# セッションから離脱（セッションは保持）
Ctrl + B, D

# または端末を閉じる（tmuxセッションはバックグラウンドで継続）
```

### 再開時の操作
```bash
# セッション一覧確認
tmux list-sessions

# 既存セッションに再接続
tmux attach-session -t claude_workspace

# 再接続後、Managerペインで復旧確認を実行
```

## 重要なポイント

1. **planning.txtは具体的に書く** - 曖昧だと要件定義が困難
2. **自動的にCEOペインから開始** - ワークスペース起動後、自動的にCEOペインにフォーカス
3. **段階的進行** - 一度に全て決めず、議論を重ねる
4. **各ペインの役割を守る** - 直接やりとりは禁止
5. **tmuxセッションを保持** - 中断・再開時の効率化

## **必須の手動作業まとめ**

### **開発開始前（1回だけ）**
1. **GitHub CLI認証設定**: `gh auth login`
2. **GitHub上での新規リポジトリ作成**: ブラウザでGitHub.comにアクセス
3. **テンプレートクローン・初期化**: CEOが手動でGitコマンド実行

### **開発中（プルリクエスト毎）**
4. **プルリクエストの最終承認**: ReviewerがGitHub上で承認ボタンをクリック

**これらの手動作業は自動化が困難なため、必ず人間が実行してください。**

## 開発フロー概要

### Phase 0: GitHub初期化（手順3）
- CEO：autodevテンプレートクローン
- CEO：.gitディレクトリ削除・新規初期化
- CEO：GitHub新規リポジトリ作成・プッシュ

### Phase 1: 要件定義・外部仕様作成（手順4-8）
- CEO初期指示
- Manager要件定義書・外部仕様書作成
- CEO-Manager議論・改善
- CEO最終承認

### Phase 2: 詳細仕様・テスト手順書作成（手順9-16）
- Manager→Developer詳細仕様書作成指示
- Developer作成（実装開始しない）
- Manager→Reviewer文書チェック依頼
- Reviewer厳格チェック実施
- Manager→Developer修正指示（承認まで繰り返し）

### Phase 3: 実装・開発（手順17-22）
- Manager→Developer実装開始指示（作業ブランチ作成）
- Developer実装（レビュー依頼中は進行停止）
- Manager→Reviewerコードレビュー・単体テスト依頼
- Reviewer厳格レビュー実施
- 手順17-21をアプリ完成まで繰り返し

### Phase 4: 総合テスト・プルリクエスト（手順23-31）
- Manager→Reviewer総合テスト依頼
- Reviewer総合テスト実施
- Manager→Developerプルリクエスト作成指示
- Manager→Reviewerプルリクエストレビュー依頼
- Reviewer承認後、Developerがマージ実行

### Phase 5: 完了・納品（手順32-36）
- Manager→CEO完了報告
- Manager→DeveloperREADME.md作成依頼
- Manager→ReviewerREADME.mdレビュー依頼
- Manager→CEO最終納品

## ファイル構成
```
/workspace/Demo/
├── setup_claude_workspace.sh （実行スクリプト）
├── README.md （この手順書）
├── .claude/
│   └── settings.local.json （フック設定・ログ機能）
├── .gitignore （ログファイル除外設定）
├── scripts/ （時間記録スクリプト）
│   ├── time_tracker.sh （時間記録スクリプト）
│   └── generate_time_report.sh （レポート生成スクリプト）
├── src/ （ソースコード格納）
│   └── [開発時に生成される実装ファイル]
├── docs/ （仕様書格納）
│   ├── requirements.md （要件定義書）
│   ├── external_spec.md （外部仕様書）
│   ├── detailed_spec.md （詳細仕様書）
│   ├── unit_test_plan.md （単体テスト手順書）
│   ├── integration_test_plan.md （統合テスト手順書）
│   ├── coding_log.md （コーディング記録）
│   ├── work_notes.md （作業メモ）
│   └── opus_limit_log.md （Opus制限ログ）
├── tests/ （テストファイル格納）
│   └── [開発時に生成されるテストファイル]
├── logs/ （ログファイル格納）
│   ├── activity_log.txt （全体活動ログ）
│   ├── developer_work_log.txt （開発者作業ログ）
│   ├── git_activity_log.txt （Git操作ログ）
│   ├── time_tracking_log.txt （時間記録ログ）
│   ├── time_report.txt （時間レポート）
│   └── current_task.txt （現在の作業状態）
└── WorkFlow/ （ワークフロー設定）
    ├── planning.txt （プロジェクト企画書テンプレート）
    ├── prompt.txt （作業手順書）
    ├── instructions_ceo.md （CEO用指示書）
    ├── instructions_manager.md （Manager用指示書）
    ├── instructions_developer.md （Developer用指示書）
    ├── instructions_review.md （Reviewer用指示書）
    ├── GITHUB_WORKFLOW.md （GitHub連携ワークフロー詳細）
    ├── LOGGING.md （ログ機能詳細）
    └── TIME_TRACKING.md （時間記録システム詳細）
```

## 重要な新機能

### GitHub連携
- **完全独立型プロジェクト**: テンプレートから独立した新しいプロジェクト作成
- **ブランチ戦略**: mainブランチ保護、feature/[機能名]での作業必須
- **プルリクエスト**: コードレビューとマージの自動化
- **自動ログ**: Git操作の自動記録

### 自動ログ機能
- **logs/activity_log.txt**: 全体的な活動ログ
- **logs/developer_work_log.txt**: 開発者専用の作業ログ  
- **logs/git_activity_log.txt**: Git操作の詳細ログ

### 🌟 革新的な自動時間分析システム
- **完全自動化**: 開発中の手動操作は一切不要！既存のログから自動的に時間分析
- **詳細な開発効率分析**: フェーズ別・ファイル別・ツール別の詳細な作業時間分析
- **インテリジェントな推定**: 活動回数から開発時間を自動推定
- **ワンクリック分析**: プロジェクト完了後、1つのコマンドで包括的な時間レポートを生成
- **プロジェクト改善指標**: 次回プロジェクトの効率化に活用できる詳細データ

## 要件

- tmux
- Claude CLI
- GitHub CLI (`gh`)
- Bash
- jq (ログ処理用)

## 注意事項

- Reviewer↔Developer間の直接やりとりは禁止
- 各段階で必ず承認を得る
- **mainブランチでの直接作業は絶対禁止**
- **プルリクエストを通さないマージは禁止**
- OpusリミットはManager経由で管理
- tmuxセッションを保持して作業継続

## ライセンス

MIT License

## 作成者

Claude Code を使用して作成

---

これで開発プロジェクトが開始されます。最初はCEO→Managerの要件定義段階から始まり、段階的に全体が動き出します。

## 🚀 革新的な自動時間分析機能

### 🌟 なぜ画期的なのか？

従来の開発では、作業時間の記録や分析は**手動で面倒**でした。autodevは**世界初**の完全自動時間分析システムを実現！

#### ✅ **従来の問題**
- 開発中に時間記録を忘れる
- 手動記録による中断とストレス
- 分析レポート作成の手間
- 不正確な時間データ

#### 🎯 **autodevの革新**
- **完全自動**: 開発中の手動操作ゼロ
- **高精度**: 全活動を自動記録
- **瞬時分析**: 1コマンドで詳細レポート
- **継続改善**: データ駆動の開発最適化

### 📊 時間分析の使い方

#### **Step 1: 通常通り開発**
```bash
# 通常の開発作業を実行（時間記録は自動）
./setup_claude_workspace.sh
# CEO→Manager→Developer→Reviewerの協働開発
```

#### **Step 2: プロジェクト完了後に分析**
```bash
# 魔法のワンクリック分析！
./scripts/analyze_logs.sh

# 結果確認
cat logs/auto_time_analysis.txt
```

#### **Step 3: 詳細レポートの活用**
```
=== 自動時間分析レポート ===
生成日時: 2025-07-15 16:27:06

=== 活動ログ分析 ===
ツール使用回数:
  - Write: 12回
  - Edit: 8回
  - Task: 3回

=== 開発者作業ログ分析 ===
ファイル編集回数:
  - src/app.js: 5回
  - docs/requirements.md: 3回
  - tests/app.test.js: 2回

=== 推定開発フェーズ分析 ===
推定作業量 (活動回数ベース):
  Phase 1 (要件定義・仕様作成): 6回
  Phase 2 (実装・開発): 12回
  Phase 3 (テスト・デプロイ): 4回

=== 推定作業時間 ===
総推定作業時間: 1h 50m
  - Phase 1: 30m
  - Phase 2: 1h 0m
  - Phase 3: 20m
```

### 🎯 活用シーン

#### **個人開発者**
- 開発効率の客観的測定
- 時間配分の最適化
- スキル向上の指標

#### **チーム開発**
- プロジェクト工数の正確な把握
- 各フェーズのボトルネック特定
- 次回プロジェクトの見積もり精度向上

#### **プロジェクト管理**
- 開発プロセスの可視化
- 品質と効率のバランス分析
- データドリブンな改善施策

### 🌟 他にはない独自機能

1. **ゼロオーバーヘッド**: 開発に集中、時間記録は自動
2. **多次元分析**: フェーズ×ツール×ファイル×時間の4次元分析
3. **インテリジェント推定**: 活動パターンから作業時間を自動推定
4. **継続改善**: 累積データによる開発プロセス最適化

### 💡 今すぐ体験

```bash
# autodevを試して、革新的な自動時間分析を体験！
git clone https://github.com/tokumeishatyo/autodev.git
cd autodev
./setup_claude_workspace.sh

# 開発完了後
./scripts/analyze_logs.sh
```

**🚀 開発の未来は、完全自動化された時間分析と共に始まります！**