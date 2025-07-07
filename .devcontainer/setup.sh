#!/bin/bash

# セットアップスクリプト - devcontainer起動時に実行される

echo "🚀 Setting up Claude code and Gemini on tmux development environment for user: klab"

# カスタム.bashrcの確認
if [ -f "/home/klab/.bashrc" ]; then
    echo "📝 Custom .bashrc detected and mounted successfully"
    echo "✅ Using your custom .bashrc configuration"
else
    echo "⚠️  Custom .bashrc not found, creating default"
    echo "# Default .bashrc for klab user" > /home/klab/.bashrc
    echo "export PS1='\\u@\\h:\\w\\$ '" >> /home/klab/.bashrc
fi

# .bashrcの読み込み
source /home/klab/.bashrc
sudo chown klab:klab /home/klab/.bashrc

echo "Install Gemini CLI"
npm install -g @google/gemini-cli

claude mcp add -s local --transport http context7 https://mcp.context7.com/mcp
claude mcp add -s local playwright npx @playwright/mcp@latest