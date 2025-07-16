#!/bin/bash

# Automatic time analysis from existing logs
# Usage: ./analyze_logs.sh [output_file]

OUTPUT_FILE="${1:-/workspace/Demo/logs/auto_time_analysis.txt}"
LOG_DIR="/workspace/Demo/logs"

# Create logs directory if it doesn't exist
mkdir -p "$LOG_DIR"

# Function to extract timestamp from log entry
extract_timestamp() {
    local log_entry="$1"
    echo "$log_entry" | grep -o '\[.*\]' | tr -d '[]'
}

# Function to calculate duration between two timestamps
calculate_duration() {
    local start_time="$1"
    local end_time="$2"
    
    # Convert to seconds
    local start_seconds=$(date -d "$start_time" +%s 2>/dev/null)
    local end_seconds=$(date -d "$end_time" +%s 2>/dev/null)
    
    if [ -z "$start_seconds" ] || [ -z "$end_seconds" ]; then
        echo "0m"
        return
    fi
    
    local duration=$((end_seconds - start_seconds))
    local hours=$((duration / 3600))
    local minutes=$(((duration % 3600) / 60))
    
    if [ $hours -gt 0 ]; then
        echo "${hours}h ${minutes}m"
    else
        echo "${minutes}m"
    fi
}

# Function to convert duration to minutes
duration_to_minutes() {
    local duration="$1"
    local total_minutes=0
    
    if [[ "$duration" =~ ([0-9]+)h[[:space:]]*([0-9]+)m ]]; then
        local hours="${BASH_REMATCH[1]}"
        local minutes="${BASH_REMATCH[2]}"
        total_minutes=$((hours * 60 + minutes))
    elif [[ "$duration" =~ ([0-9]+)m ]]; then
        total_minutes="${BASH_REMATCH[1]}"
    fi
    
    echo "$total_minutes"
}

# Function to format minutes back to duration
minutes_to_duration() {
    local minutes="$1"
    local hours=$((minutes / 60))
    local remaining_minutes=$((minutes % 60))
    
    if [ $hours -gt 0 ]; then
        echo "${hours}h ${remaining_minutes}m"
    else
        echo "${remaining_minutes}m"
    fi
}

# Generate analysis report
generate_analysis() {
    local report_date=$(date '+%Y-%m-%d %H:%M:%S')
    
    echo "=== 自動時間分析レポート ===" > "$OUTPUT_FILE"
    echo "生成日時: $report_date" >> "$OUTPUT_FILE"
    echo "分析対象: 既存のログファイル" >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"
    
    # Analyze activity log if exists
    if [ -f "$LOG_DIR/activity_log.txt" ]; then
        echo "=== 活動ログ分析 ===" >> "$OUTPUT_FILE"
        echo "" >> "$OUTPUT_FILE"
        
        # Count tool usage
        declare -A tool_counts
        declare -A tool_times
        
        while IFS= read -r line; do
            if [[ "$line" =~ \[([^\]]+)\][[:space:]]+([A-Za-z]+) ]]; then
                local timestamp="${BASH_REMATCH[1]}"
                local tool="${BASH_REMATCH[2]}"
                
                if [ -n "${tool_counts[$tool]}" ]; then
                    tool_counts[$tool]=$((${tool_counts[$tool]} + 1))
                else
                    tool_counts[$tool]=1
                fi
            fi
        done < "$LOG_DIR/activity_log.txt"
        
        echo "ツール使用回数:" >> "$OUTPUT_FILE"
        for tool in "${!tool_counts[@]}"; do
            echo "  - $tool: ${tool_counts[$tool]}回" >> "$OUTPUT_FILE"
        done
        echo "" >> "$OUTPUT_FILE"
    fi
    
    # Analyze developer work log if exists
    if [ -f "$LOG_DIR/developer_work_log.txt" ]; then
        echo "=== 開発者作業ログ分析 ===" >> "$OUTPUT_FILE"
        echo "" >> "$OUTPUT_FILE"
        
        declare -A file_counts
        
        while IFS= read -r line; do
            if [[ "$line" =~ Developer\ Work\ Log\ -\ ([^:]+): ]]; then
                local file_path="${BASH_REMATCH[1]}"
                
                if [ -n "${file_counts[$file_path]}" ]; then
                    file_counts[$file_path]=$((${file_counts[$file_path]} + 1))
                else
                    file_counts[$file_path]=1
                fi
            fi
        done < "$LOG_DIR/developer_work_log.txt"
        
        echo "ファイル編集回数:" >> "$OUTPUT_FILE"
        for file in "${!file_counts[@]}"; do
            echo "  - $file: ${file_counts[$file]}回" >> "$OUTPUT_FILE"
        done
        echo "" >> "$OUTPUT_FILE"
    fi
    
    # Analyze git activity log if exists
    if [ -f "$LOG_DIR/git_activity_log.txt" ]; then
        echo "=== Git活動ログ分析 ===" >> "$OUTPUT_FILE"
        echo "" >> "$OUTPUT_FILE"
        
        declare -A git_commands
        
        while IFS= read -r line; do
            if [[ "$line" =~ Git\ Command:\ ([^[:space:]]+) ]]; then
                local command="${BASH_REMATCH[1]}"
                
                if [ -n "${git_commands[$command]}" ]; then
                    git_commands[$command]=$((${git_commands[$command]} + 1))
                else
                    git_commands[$command]=1
                fi
            fi
        done < "$LOG_DIR/git_activity_log.txt"
        
        echo "Git コマンド使用回数:" >> "$OUTPUT_FILE"
        for cmd in "${!git_commands[@]}"; do
            echo "  - $cmd: ${git_commands[$cmd]}回" >> "$OUTPUT_FILE"
        done
        echo "" >> "$OUTPUT_FILE"
    fi
    
    # Estimate development phases based on log patterns
    echo "=== 推定開発フェーズ分析 ===" >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"
    
    # Phase 1: Requirements and specifications
    local phase1_activities=0
    if [ -f "$LOG_DIR/activity_log.txt" ]; then
        phase1_activities=$(grep -c "requirements\|planning\|spec" "$LOG_DIR/activity_log.txt" 2>/dev/null)
        [ -z "$phase1_activities" ] && phase1_activities=0
    fi
    
    # Phase 2: Implementation
    local phase2_activities=0
    if [ -f "$LOG_DIR/developer_work_log.txt" ]; then
        phase2_activities=$(wc -l < "$LOG_DIR/developer_work_log.txt" 2>/dev/null)
        [ -z "$phase2_activities" ] && phase2_activities=0
    fi
    
    # Phase 3: Testing and deployment
    local phase3_activities=0
    if [ -f "$LOG_DIR/git_activity_log.txt" ]; then
        phase3_activities=$(grep -c "test\|commit\|push" "$LOG_DIR/git_activity_log.txt" 2>/dev/null)
        [ -z "$phase3_activities" ] && phase3_activities=0
    fi
    
    echo "推定作業量 (活動回数ベース):" >> "$OUTPUT_FILE"
    echo "  Phase 1 (要件定義・仕様作成): ${phase1_activities}回" >> "$OUTPUT_FILE"
    echo "  Phase 2 (実装・開発): ${phase2_activities}回" >> "$OUTPUT_FILE"
    echo "  Phase 3 (テスト・デプロイ): ${phase3_activities}回" >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"
    
    # Time estimation based on activity patterns
    echo "=== 推定作業時間 ===" >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"
    
    # Rough time estimation (5 minutes per activity on average)
    local total_activities=$((phase1_activities + phase2_activities + phase3_activities))
    local estimated_minutes=$((total_activities * 5))
    
    if [ $estimated_minutes -gt 0 ]; then
        echo "総推定作業時間: $(minutes_to_duration $estimated_minutes)" >> "$OUTPUT_FILE"
        echo "  - Phase 1: $(minutes_to_duration $((phase1_activities * 5)))" >> "$OUTPUT_FILE"
        echo "  - Phase 2: $(minutes_to_duration $((phase2_activities * 5)))" >> "$OUTPUT_FILE"
        echo "  - Phase 3: $(minutes_to_duration $((phase3_activities * 5)))" >> "$OUTPUT_FILE"
    else
        echo "総推定作業時間: 0m" >> "$OUTPUT_FILE"
        echo "  - Phase 1: 0m" >> "$OUTPUT_FILE"
        echo "  - Phase 2: 0m" >> "$OUTPUT_FILE"
        echo "  - Phase 3: 0m" >> "$OUTPUT_FILE"
    fi
    echo "" >> "$OUTPUT_FILE"
    
    echo "注意: この推定は活動回数に基づく概算であり、実際の作業時間とは異なる場合があります。" >> "$OUTPUT_FILE"
    echo "より正確な時間測定には、手動での時間記録 (time_tracker.sh) を使用してください。" >> "$OUTPUT_FILE"
}

# Check if any log files exist
if [ ! -f "$LOG_DIR/activity_log.txt" ] && [ ! -f "$LOG_DIR/developer_work_log.txt" ] && [ ! -f "$LOG_DIR/git_activity_log.txt" ]; then
    echo "Warning: No log files found. Please run the development workflow first to generate logs."
    echo "Available log files should be:"
    echo "  - $LOG_DIR/activity_log.txt"
    echo "  - $LOG_DIR/developer_work_log.txt"
    echo "  - $LOG_DIR/git_activity_log.txt"
    exit 1
fi

# Generate the analysis
generate_analysis

echo "Automatic time analysis generated: $OUTPUT_FILE"