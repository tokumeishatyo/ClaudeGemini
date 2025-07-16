# ログ機能について

## 概要
このワークフローシステムでは、各役割（CEO、Manager、Reviewer、Developer）の活動を自動的にログ出力する機能を提供しています。

## ログの種類

### 1. 全体活動ログ (`logs/activity_log.txt`)
すべての役割の以下のツール使用がログされます：
- **Task** - タスク実行
- **TodoWrite** - Todo管理
- **Write** - ファイル作成
- **MultiEdit** - 複数ファイル編集
- **Edit** - ファイル編集

### 2. Developer専用作業ログ (`logs/developer_work_log.txt`)
Developerが以下のファイルを操作した場合に詳細ログが記録されます：
- `docs/coding_log*` - コーディング記録
- `docs/work_notes*` - 作業メモ
- `docs/detailed_spec*` - 詳細仕様書
- `docs/unit_test*` - 単体テスト関連
- `docs/integration_test*` - 統合テスト関連

### 3. Git操作ログ (`logs/git_activity_log.txt`)
すべてのGitコマンドの実行がログされます：
- Git操作の詳細記録
- ブランチ作成・切り替え
- コミット・プッシュ操作
- プルリクエスト関連操作

## ログ設定

### 設定ファイル
`.claude/settings.local.json`にhooksが設定されています：

```json
{
  "hooks": {
    "on_tool_call": {
      "command": "bash",
      "args": ["全体活動ログ出力コマンド"]
    },
    "on_tool_result": {
      "command": "bash",
      "args": ["Developer作業ログ出力コマンド"]
    }
  }
}
```

## ログ出力例

### 全体活動ログ
```
[2024-07-15 14:30:15] Write - /workspace/Demo/docs/requirements.md
[2024-07-15 14:32:20] TodoWrite - Action executed
[2024-07-15 14:35:45] Edit - /workspace/Demo/docs/external_spec.md
```

### Developer作業ログ
```
[2024-07-15 15:10:30] Developer Work Log - docs/coding_log.md: Implementation progress
[2024-07-15 15:25:15] Developer Work Log - docs/detailed_spec.md: File modified
[2024-07-15 15:40:22] Developer Work Log - docs/unit_test_plan.md: Test case creation
```

### Git操作ログ
```
[2024-07-15 16:05:12] Git Command: git checkout -b feature/user-auth
[2024-07-15 16:15:33] Git Command: git add src/auth/login.js
[2024-07-15 16:16:45] Git Command: git commit -m "Add user authentication"
[2024-07-15 16:20:12] Git Command: git push origin feature/user-auth
```

## 注意事項

1. **自動生成** - ログは自動的に生成されます
2. **Git除外** - ログファイルは`.gitignore`に含まれています
3. **タイムスタンプ** - すべてのログにタイムスタンプが付きます
4. **ファイル追記** - 既存のログファイルに追記されます

## トラブルシューティング

### ログが出力されない場合
1. `jq`コマンドがインストールされているか確認
2. `.claude/settings.local.json`の書式が正しいか確認
3. ファイルの書き込み権限があるか確認

### ログファイルの初期化
```bash
# ログファイルを初期化する場合
rm -f /workspace/Demo/logs/activity_log.txt
rm -f /workspace/Demo/logs/developer_work_log.txt
rm -f /workspace/Demo/logs/git_activity_log.txt
```