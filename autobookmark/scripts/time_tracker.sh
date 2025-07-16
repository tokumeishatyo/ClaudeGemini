#!/bin/bash

# Time tracking script for autodev workflow
# Usage: ./time_tracker.sh start|end <role> <task_description>

LOG_FILE="/workspace/Demo/logs/time_tracking_log.txt"
CURRENT_TASK_FILE="/workspace/Demo/logs/current_task.txt"

# Create logs directory if it doesn't exist
mkdir -p /workspace/Demo/logs

# Function to log with timestamp
log_with_timestamp() {
    local action="$1"
    local role="$2"
    local task="$3"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    echo "[$timestamp] $action: $role - $task" >> "$LOG_FILE"
}

# Function to calculate duration
calculate_duration() {
    local start_time="$1"
    local end_time="$2"
    
    # Convert to seconds since epoch
    local start_seconds=$(date -d "$start_time" +%s)
    local end_seconds=$(date -d "$end_time" +%s)
    
    local duration=$((end_seconds - start_seconds))
    local hours=$((duration / 3600))
    local minutes=$(((duration % 3600) / 60))
    
    if [ $hours -gt 0 ]; then
        echo "${hours}h ${minutes}m"
    else
        echo "${minutes}m"
    fi
}

case "$1" in
    start)
        if [ -z "$2" ] || [ -z "$3" ]; then
            echo "Usage: $0 start <role> <task_description>"
            exit 1
        fi
        
        role="$2"
        task="$3"
        timestamp=$(date '+%Y-%m-%d %H:%M:%S')
        
        # End previous task if exists
        if [ -f "$CURRENT_TASK_FILE" ]; then
            source "$CURRENT_TASK_FILE"
            if [ -n "$CURRENT_ROLE" ] && [ -n "$CURRENT_TASK" ] && [ -n "$START_TIME" ]; then
                duration=$(calculate_duration "$START_TIME" "$timestamp")
                log_with_timestamp "TASK_END" "$CURRENT_ROLE" "$CURRENT_TASK (Duration: $duration)"
            fi
        fi
        
        # Start new task
        log_with_timestamp "TASK_START" "$role" "$task"
        
        # Save current task info
        cat > "$CURRENT_TASK_FILE" << EOF
CURRENT_ROLE="$role"
CURRENT_TASK="$task"
START_TIME="$timestamp"
EOF
        
        echo "Started tracking: $role - $task"
        ;;
        
    end)
        if [ -f "$CURRENT_TASK_FILE" ]; then
            source "$CURRENT_TASK_FILE"
            if [ -n "$CURRENT_ROLE" ] && [ -n "$CURRENT_TASK" ] && [ -n "$START_TIME" ]; then
                timestamp=$(date '+%Y-%m-%d %H:%M:%S')
                duration=$(calculate_duration "$START_TIME" "$timestamp")
                log_with_timestamp "TASK_END" "$CURRENT_ROLE" "$CURRENT_TASK (Duration: $duration)"
                rm -f "$CURRENT_TASK_FILE"
                echo "Ended tracking: $CURRENT_ROLE - $CURRENT_TASK (Duration: $duration)"
            else
                echo "No current task found"
            fi
        else
            echo "No current task found"
        fi
        ;;
        
    phase_start)
        if [ -z "$2" ]; then
            echo "Usage: $0 phase_start <phase_description>"
            exit 1
        fi
        log_with_timestamp "PHASE_START" "SYSTEM" "$2"
        echo "Phase started: $2"
        ;;
        
    phase_end)
        if [ -z "$2" ]; then
            echo "Usage: $0 phase_end <phase_description>"
            exit 1
        fi
        log_with_timestamp "PHASE_END" "SYSTEM" "$2"
        echo "Phase ended: $2"
        ;;
        
    status)
        if [ -f "$CURRENT_TASK_FILE" ]; then
            source "$CURRENT_TASK_FILE"
            if [ -n "$CURRENT_ROLE" ] && [ -n "$CURRENT_TASK" ] && [ -n "$START_TIME" ]; then
                current_time=$(date '+%Y-%m-%d %H:%M:%S')
                duration=$(calculate_duration "$START_TIME" "$current_time")
                echo "Current task: $CURRENT_ROLE - $CURRENT_TASK (Running: $duration)"
            else
                echo "No current task"
            fi
        else
            echo "No current task"
        fi
        ;;
        
    *)
        echo "Usage: $0 {start|end|phase_start|phase_end|status} [role] [task_description]"
        echo "Examples:"
        echo "  $0 start CEO \"初期指示\""
        echo "  $0 end"
        echo "  $0 phase_start \"Phase 1: 要件定義・外部仕様作成\""
        echo "  $0 phase_end \"Phase 1: 要件定義・外部仕様作成\""
        echo "  $0 status"
        exit 1
        ;;
esac