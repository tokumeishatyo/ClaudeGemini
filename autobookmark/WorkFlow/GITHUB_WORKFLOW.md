# GitHub連携ワークフロー

## 概要
このドキュメントでは、autodevワークフローシステムにおけるGitHub連携の手順と自動化の範囲を説明します。

## 完全自動化された部分

### 1. ブランチ作成・管理
- **Manager** → **Developer**: 作業ブランチ作成指示
- **Developer**: 自動的にfeature/[機能名]ブランチを作成
- 定期的なコミット・プッシュ

### 2. プルリクエスト管理
- **Manager** → **Developer**: プルリクエスト作成指示
- **Developer**: `gh pr create`コマンドでプルリクエスト作成
- **Manager** → **Reviewer**: プルリクエストレビュー依頼

### 3. マージ処理
- **Reviewer**: プルリクエストの承認
- **Manager** → **Developer**: マージ実行指示
- **Developer**: `gh pr merge`コマンドでマージ

### 4. ログ記録
- すべてのGitコマンドは自動的に`git_activity_log.txt`に記録
- 開発者の作業ログも自動記録

## 手動で行う必要がある部分

### 1. **GitHub上での新規リポジトリ作成**（CEO責任）
```bash
# 🚨 **手動作業**: GitHub.comにアクセスして新規リポジトリを作成
# 1. https://github.com にアクセス
# 2. 「New repository」をクリック
# 3. リポジトリ名を入力
# 4. 「Create repository」をクリック
```

**理由**: GitHub APIを使用したリポジトリ作成は認証情報の管理が必要なため

### 2. **テンプレートクローン・リポジトリ設定**（CEO責任）
```bash
# 🚨 **手動作業**: autodevテンプレートのクローン
git clone https://github.com/tokumeishatyo/autodev.git [新しいプロジェクト名]
cd [新しいプロジェクト名]

# 🚨 **手動作業**: .gitディレクトリを削除して完全に新しいリポジトリとして初期化
rm -rf .git
git init
git add .
git commit -m "Initial commit from autodev template"

# 🚨 **手動作業**: 新しいGitHubリポジトリを作成後、リモートを設定
git remote add origin https://github.com/[YOUR_USERNAME]/[新しいプロジェクト名].git
git push -u origin main
```

**理由**: 
- テンプレートから完全に独立した新しいプロジェクトとして扱う
- Git履歴をクリーンな状態でスタート
- 認証情報の管理

### 3. **プルリクエストの最終承認**（Reviewer責任）
```bash
# 🚨 **手動作業**: GitHub上でプルリクエストの承認
# 1. GitHubのプルリクエストページにアクセス
# 2. 「Files changed」タブでコードを確認
# 3. 「Review changes」をクリック
# 4. 「Approve」を選択して「Submit review」をクリック
```

**理由**: 最終的な品質判断は人間が行う必要があるため

### 4. **GitHub CLI認証設定**（初回のみ）
```bash
# 🚨 **手動作業**: GitHub CLIの認証設定
gh auth login
# ブラウザが開くので、GitHubにサインインして認証を完了
```

**理由**: 個人の認証情報を安全に管理するため

## ワークフロー詳細

### Phase 0: プロジェクト初期化
1. **CEO**: autodevテンプレートをクローン
2. **CEO**: .gitディレクトリを削除し、新しいリポジトリとして初期化
3. **CEO**: GitHub上で新規リポジトリを手動作成
4. **CEO**: リモートリポジトリを設定し、初回プッシュ

### Phase 1-2: 開発フェーズ
1. **Manager**: Developerに作業ブランチ作成を指示
2. **Developer**: `feature/[機能名]`ブランチを作成
3. **Developer**: コーディング・テスト・定期的なプッシュ

### Phase 3: レビュー・マージフェーズ
1. **Manager**: Developerにプルリクエスト作成を指示
2. **Developer**: `gh pr create`でプルリクエスト作成
3. **Manager**: Reviewerにプルリクエストレビューを依頼
4. **Reviewer**: プルリクエストをレビュー・承認（手動）
5. **Manager**: Developerにマージを指示
6. **Developer**: `gh pr merge`でマージ実行

### Phase 4: 次回開発準備
1. **Developer**: ローカルブランチをmainに更新
2. **Developer**: 新しいfeature/[機能名]ブランチを作成
3. 次のコーディングサイクルに進む

## 重要なルール

### 絶対禁止事項
- ❌ **mainブランチでの直接作業**
- ❌ **プルリクエストを通さないマージ**
- ❌ **作業ブランチ作成の省略**

### 必須事項
- ✅ **必ず作業ブランチ（feature/[機能名]）を作成**
- ✅ **すべてのマージはプルリクエスト経由**
- ✅ **Reviewerの承認後のみマージ**
- ✅ **定期的なコミット・プッシュ**

## トラブルシューティング

### コンフリクトが発生した場合
1. **Developer**: mainブランチの最新状態を取得
2. **Developer**: 作業ブランチにマージ
3. **Developer**: コンフリクトを解決
4. **Developer**: 再度プッシュ

### プルリクエストが承認されない場合
1. **Reviewer**: 具体的な修正指示を提供
2. **Manager**: 修正指示をDeveloperに伝達
3. **Developer**: 修正後、再度プッシュ
4. **Reviewer**: 再レビュー

## 監視・ログ

### 自動記録される内容
- すべてのGitコマンドの実行ログ
- 開発者の作業ログ
- ブランチ作成・切り替えの記録
- プルリクエストの作成・マージの記録

### ログファイル
- `git_activity_log.txt`: Gitコマンドの実行ログ
- `activity_log.txt`: 全体的な活動ログ
- `developer_work_log.txt`: 開発者専用の作業ログ

## 注意事項

1. **認証情報の管理**
   - GitHub CLIの認証は事前に設定が必要
   - 個人アクセストークンの適切な管理

2. **リポジトリ権限**
   - 適切なリポジトリ権限の設定
   - コラボレーターの追加

3. **ブランチ保護**
   - mainブランチの保護設定を推奨
   - プルリクエストレビューの必須化

4. **テンプレートリポジトリとの関係**
   - テンプレートから完全に独立した新しいプロジェクトとして扱う
   - Git履歴はクリーンな状態からスタート
   - テンプレートの更新は新しいプロジェクトには影響しない

このワークフローにより、品質管理とGitHub連携を両立した開発プロセスを実現できます。