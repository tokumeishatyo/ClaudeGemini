#!/bin/bash

# セットアップスクリプト - devcontainer起動時に実行される

echo "🚀 Setting up WPF development environment for user: klab"

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

echo "Install Gemini CLI"
npm install -g @google/gemini-cli

# 権限の調整
#chown -R klab:klab /workspace
#chmod -R 755 /workspace

echo "🎉 Setup completed successfully!"
echo "🔍 You can now:"
echo "   - Edit WPF code in the container"
echo "   - Build projects with: dotnet build"
echo "   - Test GUI on your Windows host environment"
echo ""
echo "📁 Workspace: /workspace"
echo "🏠 Home: /home/klab"