#!/bin/bash

# Create new tmux session with 2x2 pane layout
tmux new-session -d -s claude_workspace

# Split window into 2x2 grid with equal sizes
tmux split-window -h -p 50
tmux split-window -v -p 50
tmux select-pane -t 0
tmux split-window -v -p 50

# Ensure all panes are equal size
tmux select-layout tiled

# Set pane titles and colors (eye-friendly dark backgrounds)
# CEO (top-left) - Dark purple/pink
tmux select-pane -t 0
tmux send-keys "echo 'CEO Pane'" C-m
tmux select-pane -P 'bg=#1a0d1a,fg=#dda0dd'

# Manager (top-right) - Dark orange/amber
tmux select-pane -t 1
tmux send-keys "echo 'Manager Pane'" C-m
tmux select-pane -P 'bg=#1f1611,fg=#ffb366'

# Reviewer (bottom-left) - Dark blue
tmux select-pane -t 2
tmux send-keys "echo 'Reviewer Pane'" C-m
tmux select-pane -P 'bg=#0f1419,fg=#87ceeb'

# Developer (bottom-right) - Dark green
tmux select-pane -t 3
tmux send-keys "echo 'Developer Pane'" C-m
tmux select-pane -P 'bg=#0d1b0d,fg=#90ee90'

# Start Claude with Sonnet model in CEO pane
tmux select-pane -t 0
tmux send-keys "claude --model sonnet" C-m
sleep 3  # Wait for Claude to start properly
tmux send-keys "cat WorkFlow/instructions_ceo.md" C-m
sleep 2
tmux send-keys "cat WorkFlow/planning.txt" C-m
sleep 2

# Start Claude with Sonnet model in Manager pane
tmux select-pane -t 1
tmux send-keys "claude --model sonnet" C-m
sleep 3  # Wait for Claude to start properly
tmux send-keys "cat WorkFlow/instructions_manager.md" C-m
sleep 2

# Start Claude with Sonnet model in Reviewer pane
tmux select-pane -t 2
tmux send-keys "claude --dangerously-skip-permissions --model sonnet" C-m
sleep 3  # Wait for Claude to start properly
tmux send-keys "cat WorkFlow/instructions_review.md" C-m
sleep 2

# Start Claude with Opus model in Developer pane
tmux select-pane -t 3
tmux send-keys "claude --dangerously-skip-permissions --model opus" C-m
sleep 3  # Wait for Claude to start properly
tmux send-keys "cat WorkFlow/instructions_developer.md" C-m
sleep 2

# Focus on CEO pane to start the workflow
tmux select-pane -t 0

# Send initial message to CEO to start the workflow
sleep 5  # Wait for all panes to be ready
tmux send-keys "planning.txtを確認し、Managerペインに以下の形式で初期指示を送信してください：" C-m
sleep 1
tmux send-keys "「Managerペイン: planning.txtを確認しました。以下のアプリケーション開発を開始します。【プロジェクト内容】[具体的な要求を記述] 要件定義書と外部仕様書の作成を開始してください。」" C-m

# Attach to the session
tmux attach-session -t claude_workspace