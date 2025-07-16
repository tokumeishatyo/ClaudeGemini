# 時間記録システム

## 概要
autodevワークフローシステムでの作業時間を詳細に記録し、フェーズ別・役割別の時間分析を行うシステムです。

## 時間記録の方法

### 1. 自動ログ分析（推奨）
開発完了後に既存のログファイルから自動的に時間分析を行います。手動での時間記録は不要です。

### 2. 手動時間記録（オプション）
より詳細な時間記録が必要な場合は、手動で時間記録を行うことも可能です。

## 使用方法

### 1. 時間記録の開始・終了
```bash
# 作業開始
./scripts/time_tracker.sh start <役割> "<作業内容>"

# 作業終了
./scripts/time_tracker.sh end

# 例
./scripts/time_tracker.sh start CEO "初期指示"
./scripts/time_tracker.sh end
```

### 2. フェーズ記録
```bash
# フェーズ開始
./scripts/time_tracker.sh phase_start "<フェーズ名>"

# フェーズ終了
./scripts/time_tracker.sh phase_end "<フェーズ名>"

# 例
./scripts/time_tracker.sh phase_start "Phase 1: 要件定義・外部仕様作成"
./scripts/time_tracker.sh phase_end "Phase 1: 要件定義・外部仕様作成"
```

### 3. 現在の状態確認
```bash
./scripts/time_tracker.sh status
```

### 4. 時間レポート生成

#### 自動ログ分析（推奨）
```bash
# 自動ログ分析レポート生成
./scripts/analyze_logs.sh

# 指定ファイルに出力
./scripts/analyze_logs.sh output_file.txt

# generate_time_report.shの自動モードでも実行可能
./scripts/generate_time_report.sh logs/auto_report.txt auto
```

#### 手動時間記録レポート
```bash
# デフォルト出力（logs/time_report.txt）
./scripts/generate_time_report.sh

# 指定ファイルに出力
./scripts/generate_time_report.sh output_file.txt manual
```

## レポート例

### フェーズ別時間集計
```
Phase 1: 要件定義・外部仕様作成
  - 初期指示: 15m
  - 要件定義書作成: 45m
  - CEO-Manager議論: 1h 15m
  - 最終承認: 15m
  小計: 2h 30m

Phase 2: 詳細仕様・テスト手順書作成
  - 詳細仕様書作成: 50m
  - 文書チェック: 30m
  - 修正指示: 25m
  小計: 1h 45m

Phase 3: 実装・開発
  - ユーザー認証機能実装: 1h 20m
  - データベース設計: 45m
  - API実装: 1h 30m
  - UI実装: 40m
  小計: 4h 15m

Phase 4: テスト・プルリクエスト
  - 総合テスト実施: 50m
  - プルリクエスト作成: 15m
  - プルリクエストレビュー: 20m
  - マージ: 5m
  小計: 1h 30m

Total: 10h 00m
```

### 役割別時間集計
```
CEO: 1h 15m (12.5%)
  - 初期指示: 15m
  - 最終承認: 15m
  - 完了確認: 45m

Manager: 2h 45m (27.5%)
  - 要件定義書作成: 45m
  - 指示・調整: 1h 30m
  - レビュー管理: 30m

Developer: 4h 30m (45%)
  - 詳細仕様書作成: 50m
  - 実装作業: 3h 00m
  - テスト作成: 40m

Reviewer: 1h 30m (15%)
  - 文書チェック: 30m
  - コードレビュー: 40m
  - 総合テスト: 20m
```

## 推奨される記録タイミング

### CEO
- 初期指示開始時・終了時
- 議論・レビュー開始時・終了時
- 承認作業開始時・終了時

### Manager
- 指示・調整作業開始時・終了時
- レビュー依頼作業開始時・終了時
- 文書作成開始時・終了時

### Developer
- 仕様書作成開始時・終了時
- 各実装機能開始時・終了時
- テスト作成開始時・終了時

### Reviewer
- 文書チェック開始時・終了時
- コードレビュー開始時・終了時
- 総合テスト開始時・終了時

## 注意事項

1. **必ず対になる記録**: `start` と `end` は必ず対で実行してください
2. **作業内容の具体性**: 作業内容は具体的に記述してください
3. **フェーズ記録**: 各フェーズの開始・終了も記録してください
4. **定期的なレポート生成**: プロジェクト完了後にレポートを生成してください

## ログファイル

- `logs/time_tracking_log.txt`: 時間記録のログ
- `logs/time_report.txt`: 生成されたレポート
- `logs/current_task.txt`: 現在の作業状態（一時ファイル）

## トラブルシューティング

### 記録が途切れた場合
```bash
# 現在の状態確認
./scripts/time_tracker.sh status

# 必要に応じて強制終了
./scripts/time_tracker.sh end
```

### レポートが生成されない場合
```bash
# ログファイルの確認
ls -la logs/time_tracking_log.txt

# 手動でレポート生成
./scripts/generate_time_report.sh
```