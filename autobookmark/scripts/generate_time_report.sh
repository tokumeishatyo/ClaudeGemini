#!/bin/bash

# Time report generation script for autodev workflow
# Usage: ./generate_time_report.sh [output_file] [mode]
# mode: manual (default) or auto

LOG_FILE="/workspace/Demo/logs/time_tracking_log.txt"
OUTPUT_FILE="${1:-/workspace/Demo/logs/time_report.txt}"
MODE="${2:-manual}"

# Create logs directory if it doesn't exist
mkdir -p /workspace/Demo/logs

# Check if log file exists
if [ ! -f "$LOG_FILE" ]; then
    echo "Time tracking log file not found: $LOG_FILE"
    exit 1
fi

# Function to convert duration to minutes for calculation
duration_to_minutes() {
    local duration="$1"
    local total_minutes=0
    
    # Extract hours and minutes
    if [[ "$duration" =~ ([0-9]+)h[[:space:]]*([0-9]+)m ]]; then
        local hours="${BASH_REMATCH[1]}"
        local minutes="${BASH_REMATCH[2]}"
        total_minutes=$((hours * 60 + minutes))
    elif [[ "$duration" =~ ([0-9]+)m ]]; then
        total_minutes="${BASH_REMATCH[1]}"
    fi
    
    echo "$total_minutes"
}

# Function to format minutes back to hours and minutes
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

# Function to calculate percentage
calculate_percentage() {
    local part="$1"
    local total="$2"
    if [ $total -eq 0 ]; then
        echo "0%"
    else
        # Use bash arithmetic for percentage calculation
        local percentage=$(( (part * 100) / total ))
        echo "$percentage%"
    fi
}

# Generate the report
generate_report() {
    local temp_file=$(mktemp)
    local report_date=$(date '+%Y-%m-%d %H:%M:%S')
    
    echo "=== 開発時間レポート ===" > "$OUTPUT_FILE"
    echo "生成日時: $report_date" >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"
    
    # Parse log file and extract task durations
    grep "TASK_END" "$LOG_FILE" | while IFS= read -r line; do
        # Extract using awk for better parsing
        role=$(echo "$line" | awk -F'TASK_END: ' '{print $2}' | awk -F' - ' '{print $1}')
        task=$(echo "$line" | awk -F' - ' '{print $2}' | awk -F' \\(Duration:' '{print $1}')
        duration=$(echo "$line" | awk -F'Duration: ' '{print $2}' | awk -F'\\)' '{print $1}')
        
        if [ -n "$role" ] && [ -n "$task" ] && [ -n "$duration" ]; then
            echo "$role|$task|$duration" >> "$temp_file"
        fi
    done
    
    # Phase-based grouping (simplified for now)
    echo "=== フェーズ別時間集計 ===" >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"
    
    # Calculate role-based times
    declare -A role_times
    declare -A role_tasks
    declare -A task_details
    local total_minutes=0
    
    if [ -f "$temp_file" ]; then
        while IFS='|' read -r role task duration; do
            local minutes=$(duration_to_minutes "$duration")
            total_minutes=$((total_minutes + minutes))
            
            # Sum up by role
            if [ -n "${role_times[$role]}" ]; then
                role_times[$role]=$((${role_times[$role]} + minutes))
            else
                role_times[$role]=$minutes
            fi
            
            # Store task details
            if [ -n "${role_tasks[$role]}" ]; then
                role_tasks[$role]="${role_tasks[$role]}
  - $task: $(minutes_to_duration $minutes)"
            else
                role_tasks[$role]="  - $task: $(minutes_to_duration $minutes)"
            fi
            
            # Store individual task for detailed breakdown
            task_details["$task"]="$minutes"
        done < "$temp_file"
    fi
    
    # Group tasks by phase (basic categorization)
    local phase1_minutes=0
    local phase2_minutes=0
    local phase3_minutes=0
    local phase4_minutes=0
    
    echo "Phase 1: 要件定義・外部仕様作成" >> "$OUTPUT_FILE"
    for task in "${!task_details[@]}"; do
        if [[ "$task" =~ (初期指示|要件定義|議論|承認|外部仕様) ]]; then
            local minutes=${task_details[$task]}
            phase1_minutes=$((phase1_minutes + minutes))
            echo "  - $task: $(minutes_to_duration $minutes)" >> "$OUTPUT_FILE"
        fi
    done
    if [ $phase1_minutes -gt 0 ]; then
        echo "  小計: $(minutes_to_duration $phase1_minutes)" >> "$OUTPUT_FILE"
    fi
    echo "" >> "$OUTPUT_FILE"
    
    echo "Phase 2: 詳細仕様・テスト手順書作成" >> "$OUTPUT_FILE"
    for task in "${!task_details[@]}"; do
        if [[ "$task" =~ (詳細仕様|テスト手順|仕様書作成|文書チェック) ]]; then
            local minutes=${task_details[$task]}
            phase2_minutes=$((phase2_minutes + minutes))
            echo "  - $task: $(minutes_to_duration $minutes)" >> "$OUTPUT_FILE"
        fi
    done
    if [ $phase2_minutes -gt 0 ]; then
        echo "  小計: $(minutes_to_duration $phase2_minutes)" >> "$OUTPUT_FILE"
    fi
    echo "" >> "$OUTPUT_FILE"
    
    echo "Phase 3: 実装・開発" >> "$OUTPUT_FILE"
    for task in "${!task_details[@]}"; do
        if [[ "$task" =~ (実装|コーディング|開発|機能|API|UI|データベース) ]]; then
            local minutes=${task_details[$task]}
            phase3_minutes=$((phase3_minutes + minutes))
            echo "  - $task: $(minutes_to_duration $minutes)" >> "$OUTPUT_FILE"
        fi
    done
    if [ $phase3_minutes -gt 0 ]; then
        echo "  小計: $(minutes_to_duration $phase3_minutes)" >> "$OUTPUT_FILE"
    fi
    echo "" >> "$OUTPUT_FILE"
    
    echo "Phase 4: テスト・プルリクエスト" >> "$OUTPUT_FILE"
    for task in "${!task_details[@]}"; do
        if [[ "$task" =~ (総合テスト|テスト実施|プルリクエスト|マージ|レビュー) ]]; then
            local minutes=${task_details[$task]}
            phase4_minutes=$((phase4_minutes + minutes))
            echo "  - $task: $(minutes_to_duration $minutes)" >> "$OUTPUT_FILE"
        fi
    done
    if [ $phase4_minutes -gt 0 ]; then
        echo "  小計: $(minutes_to_duration $phase4_minutes)" >> "$OUTPUT_FILE"
    fi
    echo "" >> "$OUTPUT_FILE"
    
    # Other tasks (not categorized)
    local other_minutes=0
    echo "その他の作業:" >> "$OUTPUT_FILE"
    for task in "${!task_details[@]}"; do
        if [[ ! "$task" =~ (初期指示|要件定義|議論|承認|外部仕様|詳細仕様|テスト手順|仕様書作成|文書チェック|実装|コーディング|開発|機能|API|UI|データベース|総合テスト|テスト実施|プルリクエスト|マージ|レビュー) ]]; then
            local minutes=${task_details[$task]}
            other_minutes=$((other_minutes + minutes))
            echo "  - $task: $(minutes_to_duration $minutes)" >> "$OUTPUT_FILE"
        fi
    done
    if [ $other_minutes -gt 0 ]; then
        echo "  小計: $(minutes_to_duration $other_minutes)" >> "$OUTPUT_FILE"
    fi
    echo "" >> "$OUTPUT_FILE"
    
    echo "Total: $(minutes_to_duration $total_minutes)" >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"
    
    # Role-based summary
    echo "=== 役割別時間集計 ===" >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"
    
    for role in "${!role_times[@]}"; do
        local minutes=${role_times[$role]}
        local percentage=$(calculate_percentage $minutes $total_minutes)
        echo "$role: $(minutes_to_duration $minutes) ($percentage)" >> "$OUTPUT_FILE"
        echo "${role_tasks[$role]}" >> "$OUTPUT_FILE"
        echo "" >> "$OUTPUT_FILE"
    done
    
    # Clean up
    rm -f "$temp_file"
}

# Percentage calculations using bash arithmetic - no external dependencies needed

# Generate the report based on mode
if [ "$MODE" = "auto" ]; then
    # Run automatic log analysis
    ./scripts/analyze_logs.sh "$OUTPUT_FILE"
else
    # Run manual time tracking report
    generate_report
    echo "Time report generated: $OUTPUT_FILE"
fi